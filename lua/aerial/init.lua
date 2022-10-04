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
      au WinEnter,BufEnter * lua require'aerial.autocommands'.on_enter_buffer()
    aug END
  ]])
  command.create_commands()
  highlight.create_highlight_groups()
end

---Returns true if aerial is open for the current buffer
---(returns false inside an aerial buffer)
---@param opts? {bufnr?: integer, winid?: integer}
---@return boolean
M.is_open = function(opts)
  if type(opts) == "number" then
    -- For backwards compatibility
    opts = { bufnr = opts }
  end
  return window.is_open(opts)
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
      lnum = item.selection_range and item.selection_range.lnum or item.lnum,
      col = item.selection_range and item.selection_range.col or item.col,
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
      if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == aer_bufnr then
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
  local bufnr = util.get_buffers(0)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  print("Aerial Info")
  print("-----------")
  print(string.format("Filetype: %s", filetype))
  print("Configured backends:")
  for _, line in ipairs(backends.get_status_lines(bufnr)) do
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

local function lsp_rename(bufnr, position, new_name, options, callback)
  options = options or {}
  local clients = vim.lsp.get_active_clients({
    bufnr = bufnr,
    name = options.name,
  })
  if options.filter then
    clients = vim.tbl_filter(options.filter, clients)
  end

  -- Clients must at least support rename, prepareRename is optional
  clients = vim.tbl_filter(function(client)
    return client.supports_method("textDocument/rename")
  end, clients)

  if #clients == 0 then
    vim.notify("[LSP] Rename, no matching language servers with rename capability.")
  end

  local cword
  local function get_cword()
    if not cword then
      local aerial_pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_buf_call(bufnr, function()
        local prev_pos = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, position)
        cword = vim.fn.expand("<cword>")
        vim.api.nvim_win_set_cursor(0, prev_pos)
      end)
      vim.api.nvim_win_set_cursor(0, aerial_pos)
    end
    return cword
  end

  local function get_text_at_range(range, offset_encoding)
    return vim.api.nvim_buf_get_text(
      bufnr,
      range.start.line,
      util._get_line_byte_from_position(bufnr, range.start, offset_encoding),
      range["end"].line,
      util._get_line_byte_from_position(bufnr, range["end"], offset_encoding),
      {}
    )[1]
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, position[1] - 1, position[1], true)[1]
  if not line then
    error("Invalid buffer position")
  end
  local function make_position_params(offset_encoding)
    local col = vim.lsp.util._str_utfindex_enc(line, position[2], offset_encoding)
    return {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      position = { line = position[1] - 1, character = col },
    }
  end

  local try_use_client
  try_use_client = function(idx, client)
    if not client then
      callback()
      return
    end

    local function rename(name)
      local params = make_position_params(client.offset_encoding)
      params.newName = name
      local handler = client.handlers["textDocument/rename"]
        or vim.lsp.handlers["textDocument/rename"]
      client.request("textDocument/rename", params, function(...)
        handler(...)
        try_use_client(next(clients, idx))
      end, bufnr)
    end

    if client.supports_method("textDocument/prepareRename") then
      local params = make_position_params(client.offset_encoding)
      client.request("textDocument/prepareRename", params, function(err, result)
        if err or result == nil then
          if next(clients, idx) then
            try_use_client(next(clients, idx))
          else
            local msg = err and ("Error on prepareRename: " .. (err.message or ""))
              or "Nothing to rename"
            vim.notify(msg, vim.log.levels.INFO)
          end
          return
        end

        if new_name then
          rename(new_name)
          return
        end

        local prompt_opts = {
          prompt = "New Name: ",
        }
        -- result: Range | { range: Range, placeholder: string }
        if result.placeholder then
          prompt_opts.default = result.placeholder
        elseif result.start then
          prompt_opts.default = get_text_at_range(result, client.offset_encoding)
        elseif result.range then
          prompt_opts.default = get_text_at_range(result.range, client.offset_encoding)
        else
          prompt_opts.default = cword
        end
        vim.ui.input(prompt_opts, function(input)
          if not input or #input == 0 then
            return
          end
          rename(input)
        end)
      end, bufnr)
    else
      assert(
        client.supports_method("textDocument/rename"),
        "Client must support textDocument/rename"
      )
      if new_name then
        rename(new_name)
        return
      end

      local prompt_opts = {
        prompt = "New Name: ",
        default = get_cword(),
      }
      vim.ui.input(prompt_opts, function(input)
        if not input or #input == 0 then
          return
        end
        rename(input)
      end)
    end
  end

  try_use_client(next(clients))
end

M.rename = function(new_name, options)
  if not util.is_aerial_buffer() then
    error("aerial.rename() must be called from inside the aerial buffer")
  end
  local bufnr = util.get_source_buffer()
  if not data:has_symbols(bufnr) then
    vim.notify("No symbols found", vim.log.levels.ERROR)
    return
  end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local item = data:get_or_create(bufnr):item(lnum)
  local lnum = item.selection_range and item.selection_range.lnum or item.lnum
  local col = item.selection_range and item.selection_range.col or item.col
  lsp_rename(bufnr, { lnum, col }, new_name, options, function()
    local backend = backends.get(bufnr)
    backend.fetch_symbols(bufnr)
  end)
end

_G.aerial_foldexpr = fold.foldexpr

return M
