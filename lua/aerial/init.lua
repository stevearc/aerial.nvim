local M = {}

local was_closed = nil

---@diagnostic disable undefined-doc-param

---Reload global or apply provided configuration
---@param opts? table empty for defaults, nothing for global config, custom for custom
M.setup = function(opts)
  require("aerial.config").setup(opts or vim.g.aerial_nvim_config)
end

---Returns true if aerial is open for the current window or buffer (returns false inside an aerial buffer)
---@param opts? table
---    bufnr? integer
---    winid? integer
---@return boolean
M.is_open = function(opts)
  return require("aerial.window").is_open(opts)
end

---Close the aerial window.
M.close = function()
  was_closed = true
  require("aerial.window").close()
end

---Close all visible aerial windows.
M.close_all = require("aerial.window").close_all

---Close all visible aerial windows except for the one currently focused or for the currently focused window.
M.close_all_but_current = require("aerial.window").close_all_but_current

---Open the aerial window for the current buffer.
---@param opts? table
---    focus boolean If true, jump to aerial window if it is opened (default true)
---    direction "left"|"right"|"float" Direction to open aerial window
M.open = function(opts)
  was_closed = false
  opts = vim.tbl_extend("keep", opts or {}, {
    focus = true,
  })
  require("aerial.window").open(opts.focus, opts.direction)
end

---Open aerial in an existing window
---@param target_win integer The winid to open the aerial buffer
---@param source_win integer The winid that contains the source buffer
---@note
--- This can be used to create custom layouts, since you can create and position the window yourself
M.open_in_win = function(target_win, source_win)
  was_closed = false
  local source_bufnr = vim.api.nvim_win_get_buf(source_win)
  require("aerial.window").open_aerial_in_win(source_bufnr, source_win, target_win)
end

---Open an aerial window for each visible window.
M.open_all = require("aerial.window").open_all

---Jump to the aerial window for the current buffer, if it is open
M.focus = require("aerial.window").focus

---Open or close the aerial window for the current buffer.
---@param opts? table
---    focus boolean If true, jump to aerial window if it is opened (default true)
---    direction "left"|"right"|"float" Direction to open aerial window
M.toggle = function(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    focus = true,
  })
  local opened = require("aerial.window").toggle(opts.focus, opts.direction)
  was_closed = not opened
  return opened
end

---Refresh the symbols for a buffer
---@param bufnr? integer
---@note
--- Symbols will usually get refreshed automatically when needed. You should only need to
--- call this if you change something in the config (e.g. by setting vim.b.aerial_backends)
M.refetch_symbols = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local backends = require("aerial.backends")
  if not backends.attach(bufnr, true) then
    local backend = backends.get(bufnr)
    if backend then
      backend.fetch_symbols(bufnr)
    else
      error("No aerial backend for buffer")
    end
  end
end

---Jump to a specific symbol.
---@param opts? table
---    index? integer The symbol to jump to. If nil, will jump to the symbol under the cursor (in the aerial buffer)
---    split? string Jump to the symbol in a new split. Can be "v" for vertical or "h" for horizontal. Can also be a raw command to execute (e.g. "belowright split")
---    jump? boolean If false and in the aerial window, do not leave the aerial window. (Default true)
M.select = require("aerial.navigation").select

---Jump forwards in the symbol list.
---@param step? integer Number of symbols to jump by (default 1)
M.next = require("aerial.navigation").next

---Jump backwards in the symbol list.
---@param step? integer Number of symbols to jump by (default 1)
M.prev = require("aerial.navigation").prev

local nav_up = require("aerial.navigation").up

---Jump to a symbol higher in the tree, moving forwards
---@param count? integer How many levels to jump up (default 1)
M.next_up = function(count)
  nav_up(1, count)
end

---Jump to a symbol higher in the tree, moving backwards
---@param count? integer How many levels to jump up (default 1)
M.prev_up = function(count)
  nav_up(-1, count)
end

---Get a list representing the symbol path to the current location.
---@param exact? boolean If true, only return symbols if we are exactly inside the hierarchy. When false, will return the closest symbol.
---@return table[]
---@note
--- Returns empty list if none found or in an invalid buffer.
--- Items have the following keys:
---     name   The name of the symbol
---     kind   The SymbolKind of the symbol
---     icon   The icon that represents the symbol
M.get_location = function(exact)
  local config = require("aerial.config")
  local data = require("aerial.data")
  local window = require("aerial.window")
  -- exact defaults to true
  if exact == nil then
    exact = true
  end
  if not data.has_symbols(0) then
    return {}
  end
  local winid = vim.api.nvim_get_current_win()
  local bufdata = data.get_or_create(0)
  local cur = vim.api.nvim_win_get_cursor(winid)
  local pos = window.get_symbol_position(bufdata, cur[1], cur[2], true)
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

---Collapse all nodes in the symbol tree
---@param bufnr? integer
M.tree_close_all = require("aerial.tree").close_all

---Expand all nodes in the symbol tree
---@param bufnr? integer
M.tree_open_all = require("aerial.tree").open_all

---Set the collapse level of the symbol tree
---@param bufnr integer
---@param level integer 0 is all closed, use 99 to open all
M.tree_set_collapse_level = require("aerial.tree").set_collapse_level

---Increase the fold level of the symbol tree
---@param bufnr integer
---@param count? integer
M.tree_increase_fold_level = require("aerial.tree").increase_fold_level

---Decrease the fold level of the symbol tree
---@param bufnr integer
---@param count? integer
M.tree_decrease_fold_level = require("aerial.tree").decrease_fold_level

---Open the tree at the selected location
---@param opts? table
---    index? integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold? boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse? boolean If true, perform the action recursively on all children (default false)
---    bubble? boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_open = require("aerial.tree").open

---Collapse the tree at the selected location
---@param opts? table
---    index? integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold? boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse? boolean If true, perform the action recursively on all children (default false)
---    bubble? boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_close = require("aerial.tree").close

---Toggle the collapsed state at the selected location
---@param opts? table
---    index? integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold? boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse? boolean If true, perform the action recursively on all children (default false)
---    bubble? boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_toggle = require("aerial.tree").toggle

---Check if the nav windows are open
---@return boolean
M.nav_is_open = require("aerial.nav_view").is_open

---Open the nav windows
M.nav_open = require("aerial.nav_view").open

---Close the nav windows
M.nav_close = require("aerial.nav_view").close

---Toggle the nav windows open/closed
M.nav_toggle = require("aerial.nav_view").toggle

---Clear aerial's tree-sitter query cache
M.treesitter_clear_query_cache = require("aerial.backends.treesitter.helpers").clear_query_cache

---Sync code folding with the current tree state.
---@param bufnr? integer
---@note
--- Ignores the 'link_tree_to_folds' config option.
M.sync_folds = function(bufnr)
  local fold = require("aerial.fold")
  local util = require("aerial.util")
  local mywin = vim.api.nvim_get_current_win()
  local source_buf, _ = util.get_buffers(bufnr)
  for _, winid in ipairs(util.get_fixed_wins(source_buf)) do
    fold.sync_tree_folds(winid)
  end
  util.go_win_no_au(mywin)
end

---Get debug info for aerial
---@return table
M.info = function()
  local util = require("aerial.util")
  local bufnr = util.get_buffers(0) or 0
  local filetype = vim.bo[bufnr].filetype
  local ignored, message = util.is_ignored_win()
  return {
    ignore = {
      ignored = ignored,
      message = message,
    },
    filetype = filetype,
    filter_kind_map = require("aerial.config").get_filter_kind_map(bufnr),
    backends = require("aerial.backends").get_status(bufnr),
  }
end

---Returns the number of symbols for the buffer
---@param bufnr integer
---@return integer
M.num_symbols = function(bufnr)
  bufnr = bufnr or 0
  local data = require("aerial.data")
  if data.has_symbols(bufnr) then
    return data.get_or_create(bufnr):count({ skip_hidden = false })
  else
    return 0
  end
end

---Returns true if the user has manually closed aerial. Will become false if the user opens aerial again.
---@param default? boolean
---@return nil|boolean
M.was_closed = function(default)
  if was_closed == nil then
    return default
  else
    return was_closed
  end
end

_G.aerial_foldexpr = require("aerial.fold").foldexpr

return M
