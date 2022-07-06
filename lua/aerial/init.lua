local autocommands = require("aerial.autocommands")
local backends = require("aerial.backends")
local command = require("aerial.command")
local config = require("aerial.config")
local data = require("aerial.data")
local fold = require("aerial.fold")
local highlight = require("aerial.highlight")
local nav = require("aerial.navigation")
local render = require("aerial.render")
local tree = require("aerial.tree")
local util = require("aerial.util")
local window = require("aerial.window")

local M = {}

local was_closed = nil
M.setup = function(opts)
  config.setup(opts)
  autocommands.on_enter_buffer()
  vim.cmd([[
    aug AerialEnterBuffer
      au!
      au BufEnter * lua require'aerial.autocommands'.on_enter_buffer()
    aug END
  ]])
  command.create_commands()
  highlight.create_highlight_groups()
end

-- Returns true if aerial is open for the current buffer
-- (returns false inside an aerial buffer)
M.is_open = function(bufnr)
  return window.is_open(bufnr)
end

-- Close the aerial window for the current buffer, or the current window if it
-- is an aerial buffer
M.close = function()
  was_closed = true
  window.close()
end

M.close_all = window.close_all

M.close_all_but_current = window.close_all_but_current

-- Open the aerial window for the current buffer.
-- focus (bool): If true, jump to aerial window
-- direction (enum): "left", "right", or "float"
M.open = function(focus, direction)
  was_closed = false
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

M.open_all = window.open_all

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
  local opened = window.toggle(focus, direction)
  was_closed = not opened
  return opened
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
-- exact (bool): If true, only return symbols if we are exactly inside the
--               hierarchy. When false, will return the closest symbol.
-- Returns empty list if none found or in an invalid buffer.
-- Items have the following keys:
--     name   The name of the symbol
--     kind   The SymbolKind of the symbol
--     icon   The icon that represents the symbol
M.get_location = function(exact)
  -- exact defaults to true
  if exact == nil then
    exact = true
  end
  if not data:has_symbols(0) then
    return {}
  end
  local winid = vim.api.nvim_get_current_win()
  local bufdata = data[0]
  local pos = bufdata.positions[winid]
  if not pos then
    return {}
  end
  local item
  if exact then
    item = pos.exact_symbol
  else
    item = pos.closest_symbol
  end
  local ret = {}
  while item do
    table.insert(ret, 1, {
      kind = item.kind,
      icon = config.get_icon(0, item.kind),
      name = item.name,
    })
    item = item.parent
  end
  return ret
end

local function _post_tree_mutate(bufnr, new_cursor_pos)
  bufnr = bufnr or 0
  render.update_aerial_buffer(bufnr)
  local mywin = vim.api.nvim_get_current_win()
  window.update_all_positions(bufnr, mywin)
  local _, aer_bufnr = util.get_buffers(bufnr)
  if new_cursor_pos then
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(winid) == aer_bufnr then
        vim.api.nvim_win_set_cursor(winid, { new_cursor_pos, 0 })
      end
    end
  end
end

---Collapse all nodes in the symbol tree
---@param bufnr integer
M.tree_close_all = function(bufnr)
  bufnr = util.get_buffers(bufnr or 0)
  if not data:has_symbols(bufnr) then
    return
  end
  data[bufnr]:clear_collapsed()
  M.tree_set_collapse_level(bufnr, 0)
end

---Expand all nodes in the symbol tree
---@param bufnr integer
M.tree_open_all = function(bufnr)
  bufnr = util.get_buffers(bufnr or 0)
  if not data:has_symbols(bufnr) then
    return
  end
  data[bufnr]:clear_collapsed()
  M.tree_set_collapse_level(bufnr, 99)
end

---0 is all closed, use 99 to open all
---@param bufnr integer
---@param level integer
M.tree_set_collapse_level = function(bufnr, level)
  bufnr = util.get_buffers(bufnr or 0)
  if not data:has_symbols(bufnr) then
    return
  end
  data[bufnr].collapse_level = level
  if config.link_tree_to_folds then
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(winid) == bufnr then
        vim.api.nvim_win_set_option(winid, "foldlevel", level)
      end
    end
  end
  _post_tree_mutate(bufnr)
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
  local item
  if opts.index then
    index = opts.index
  elseif util.is_aerial_buffer() then
    index = vim.api.nvim_win_get_cursor(0)[1]
  else
    local pos = window.get_position_in_win()
    index = pos.lnum
    item = pos.exact_symbol
  end
  if item == nil then
    item = data[0]:item(index)
  end
  if not item then
    return
  end
  local lnum = item.lnum
  local did_update, new_cursor_pos = tree.edit_tree_node(data[0], action, index, opts)
  if did_update then
    if config.link_tree_to_folds and opts.fold then
      fold.fold_action(action, lnum, {
        recurse = opts.recurse,
      })
    end
    _post_tree_mutate(0, new_cursor_pos)
  end
end

---Sync code folding with the current tree state.
---Ignores the 'link_tree_to_folds' config option.
---@param bufnr integer
M.sync_folds = function(bufnr)
  local mywin = vim.api.nvim_get_current_win()
  local source_buf, _ = util.get_buffers(bufnr)
  for _, winid in ipairs(util.get_fixed_wins(source_buf)) do
    fold.sync_tree_folds(winid)
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

---Print out debug information for aerial
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

---Returns the number of symbols for the buffer
---@param bufnr integer
---@return integer
M.num_symbols = function(bufnr)
  bufnr = bufnr or 0
  if not data:has_symbols(bufnr) then
    return 0
  end
  return data[bufnr]:count()
end

---Returns true if the user has manually closed aerial.
---Will become false if the user opens aerial again.
---@param default? boolean
---@return boolean|nil
M.was_closed = function(default)
  if was_closed == nil then
    return default
  else
    return was_closed
  end
end

_G.aerial_foldexpr = fold.foldexpr

return M
