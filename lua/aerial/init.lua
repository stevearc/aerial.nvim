local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local fold = require("aerial.fold")
local nav = require("aerial.navigation")
local render = require("aerial.render")
local tree = require("aerial.tree")
local util = require("aerial.util")
local window = require("aerial.window")

local M = {}

M.setup = config.setup

-- Returns true if aerial is open for the current buffer
-- (returns false inside an aerial buffer)
M.is_open = function(bufnr)
  return window.is_open(bufnr)
end

-- Close the aerial window for the current buffer, or the current window if it
-- is an aerial buffer
M.close = function()
  window.close()
end

-- Open the aerial window for the current buffer.
-- focus (bool): If true, jump to aerial window
-- direction (enum): "left", "right", or "float"
M.open = function(focus, direction)
  -- We get empty strings from the vim command
  if focus == "" then
    focus = true
  elseif focus == "!" then
    focus = false
  end
  if direction == "" then
    direction = nil
  end
  window.open(focus, direction)
end

-- Jump to the aerial window for the current buffer, if it is open
M.focus = function()
  window.focus()
end

-- Open or close the aerial window for the current buffer.
-- focus (bool): If true, jump to aerial window if it is opened
-- direction (enum): "left", "right", or "float"
M.toggle = function(focus, direction)
  -- We get empty strings from the vim command
  if focus == "" then
    focus = true
  elseif focus == "!" then
    focus = false
  end
  if direction == "" then
    direction = nil
  end
  return window.toggle(focus, direction)
end

-- Jump to a specific symbol. "opts" can have the following keys:
-- index (int): The symbol to jump to. If nil, will jump to the symbol under
--              the cursor (in the aerial buffer)
-- split (str): Jump to the symbol in a new split. Can be "v" for vertical or
--              "h" for horizontal. Can also be a raw command to execute (e.g.
--              "belowright split")
-- jump (bool): If false and in the aerial window, do not leave the aerial
--              window. (Default true)
M.select = function(opts)
  nav.select(opts)
end

-- Jump forwards or backwards in the symbol list.
-- step (int): Number of symbols to jump by (default 1)
M.next = function(step)
  nav.next(step)
end

-- Jump up the tree
-- direction (int): -1 for backwards or 1 for forwards
-- count (int): How many levels to jump up (default 1)
M.up = function(direction, count)
  nav.up(direction, count)
end

-- This LSP on_attach function must be called in order to use the LSP backend
M.on_attach = function(...)
  require("aerial.backends.lsp").on_attach(...)
end

-- Returns a list representing the symbol path to the current location.
-- Returns empty list if none found or in an invalid buffer.
-- Items have the following keys:
--     name   The name of the symbol
--     kind   The SymbolKind of the symbol
--     icon   The icon that represents the symbol
M.get_location = function()
  if not data:has_symbols(0) then
    return {}
  end
  local winid = vim.api.nvim_get_current_win()
  local bufdata = data[0]
  local pos = bufdata.positions[winid]
  if not pos then
    return {}
  end
  local item = bufdata:item(pos.lnum)
  local ret = {}
  while item do
    table.insert(ret, 1, {
      kind = item.kind,
      icon = config.get_icon(item.kind),
      name = item.name,
    })
    item = item.parent
  end
  return ret
end

local function _post_tree_mutate(new_cursor_pos)
  render.update_aerial_buffer()
  window.update_all_positions()
  if util.is_aerial_buffer() then
    if new_cursor_pos then
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos, 0 })
    end
  else
    window.update_position(0, true)
  end
end

-- Collapse all nodes in the symbol tree
M.tree_close_all = function()
  local new_cursor_pos
  local bufdata = data[0]
  if util.is_aerial_buffer() then
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local root = bufdata:get_root_of(bufdata:item(lnum))
    tree.close_all(bufdata)
    new_cursor_pos = bufdata:indexof(root)
  else
    tree.close_all(bufdata)
  end
  if config.link_tree_to_folds then
    M.sync_folds()
  end
  _post_tree_mutate(new_cursor_pos)
end

-- Expand all nodes in the symbol tree
M.tree_open_all = function()
  tree.open_all(data[0])
  if config.link_tree_to_folds then
    M.sync_folds()
  end
  _post_tree_mutate()
end

-- Perform an action on the symbol tree.
-- action (enum): can be one of the following:
--   open    Open the tree at the selected location
--   close   Collapse the tree at the selected location
--   toggle  Toggle the collapsed state at the selected location
-- opts (table): can contain the following values:
--   index    The index of the symbol to perform the action on.
--            Defaults to cursor location.
--   fold     If false, do not modify folds regardless of
--            'link_tree_to_folds' setting. (default true)
--   recurse  If true, perform the action recursively on all children
--            (default false)
--   bubble   If true and current symbol has no children, perform the
--            action on the nearest parent (default true)
M.tree_cmd = function(action, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    index = nil,
    fold = true,
  })
  local index
  if opts.index then
    index = opts.index
  elseif util.is_aerial_buffer() then
    index = vim.api.nvim_win_get_cursor(0)[1]
  else
    index = window.get_position_in_win().lnum
  end
  local lnum = data[0]:item(index).lnum
  local did_update, new_cursor_pos = tree.edit_tree_node(data[0], action, index, opts)
  if did_update then
    if config.link_tree_to_folds and opts.fold then
      fold.fold_action(action, lnum, {
        recurse = opts.recurse,
      })
    end
    _post_tree_mutate(new_cursor_pos)
  end
end

-- Sync code folding with the current tree state.
-- Ignores the 'link_tree_to_folds' config option.
M.sync_folds = function()
  local mywin = vim.api.nvim_get_current_win()
  if util.is_aerial_buffer() then
    local bufnr = util.get_source_buffer()
    for _, winid in ipairs(util.get_fixed_wins(bufnr)) do
      fold.sync_tree_folds(winid)
    end
  else
    local bufnr = vim.api.nvim_get_current_buf()
    for _, winid in ipairs(util.get_fixed_wins(bufnr)) do
      fold.sync_tree_folds(winid)
    end
  end
  util.go_win_no_au(mywin)
end

-- Register a callback to be called when aerial is attached to a buffer.
M.register_attach_cb = function(callback)
  vim.notify(
    "Deprecated(register_attach_cb): pass `on_attach` to aerial.setup() instead (see :help aerial)",
    vim.log.levels.WARN
  )
  config.on_attach = callback
end

-- Print out debug information for aerial
M.info = function()
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")
  print("Aerial Info")
  print("-----------")
  print(string.format("Filetype: %s", filetype))
  print("Configured backends:")
  for _, name in ipairs(config.backends(0)) do
    local line = "  " .. name
    local supported, err = backends.is_supported(0, name)
    if supported then
      line = line .. " (supported)"
    else
      line = line .. " (not supported) [" .. err .. "]"
    end
    if backends.is_backend_attached(0, name) then
      line = line .. " (attached)"
    end
    print(line)
  end
  print(string.format("Show symbols: %s", config.get_filter_kind_map()))
end

return M
