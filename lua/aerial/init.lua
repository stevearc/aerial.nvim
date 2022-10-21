local autocommands = require("aerial.autocommands")
local backends = require("aerial.backends")
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

local function list_complete(choices)
  return function(arg)
    return vim.tbl_filter(function(dir)
      return vim.startswith(dir, arg)
    end, choices)
  end
end
local commands = {
  {
    cmd = "AerialToggle",
    args = "`left/right/float`",
    func = "toggle",
    def = {
      desc = "Open or close the aerial window. With `!` cursor stays in current window",
      nargs = "?",
      bang = true,
      complete = list_complete({ "left", "right", "float" }),
    },
  },
  {
    cmd = "AerialOpen",
    args = "`left/right/float`",
    func = "open",
    def = {
      desc = "Open the aerial window. With `!` cursor stays in current window",
      nargs = "?",
      bang = true,
      complete = list_complete({ "left", "right", "float" }),
    },
  },
  {
    cmd = "AerialOpenAll",
    func = "open_all",
    def = {
      desc = "Open an aerial window for each visible window.",
    },
  },
  {
    cmd = "AerialClose",
    func = "close",
    def = {
      desc = "Close the aerial window.",
    },
  },
  {
    cmd = "AerialCloseAll",
    func = "close_all",
    def = {
      desc = "Close all visible aerial windows.",
    },
  },
  {
    cmd = "AerialCloseAllButCurrent",
    func = "close_all_but_current",
    def = {
      desc = "Close all visible aerial windows except for the one currently focused or for the currently focused window.",
    },
  },
  {
    cmd = "AerialNext",
    func = "next",
    def = {
      desc = "Jump forwards {count} symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialPrev",
    func = "prev",
    def = {
      desc = "Jump backwards [count] symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialNextUp",
    func = "next_up",
    def = {
      desc = "Jump up the tree [count] levels, moving forwards in the file (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialPrevUp",
    func = "next_up",
    def = {
      desc = "Jump up the tree [count] levels, moving backwards in the file (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialGo",
    func = "go",
    def = {
      desc = 'Jump to the [count] symbol (default 1). If with [!] and inside aerial window, the cursor will stay in the aerial window. [split] can be "v" to open a new vertical split, or "h" to open a horizontal split. [split] can also be a raw vim command, such as "belowright split". This command respects switchbuf=uselast',
      count = 1,
      bang = true,
      nargs = "?",
    },
  },
  {
    cmd = "AerialTreeOpen",
    func = "tree_open",
    def = {
      desc = "Expand the tree at the current location. If with [!] then will expand recursively.",
      bang = true,
    },
  },
  {
    cmd = "AerialTreeClose",
    func = "tree_close",
    def = {
      desc = "Collapse the tree at the current location. If with [!] then will collapse recursively.",
      bang = true,
    },
  },
  {
    cmd = "AerialTreeToggle",
    func = "tree_toggle",
    def = {
      desc = "Toggle the tree at the current location. If with [!] then will toggle recursively.",
      bang = true,
    },
  },
  {
    cmd = "AerialTreeOpenAll",
    func = "tree_open_all",
    def = {
      desc = "Expand all the tree nodes.",
    },
  },
  {
    cmd = "AerialTreeCloseAll",
    func = "tree_close_all",
    def = {
      desc = "Collapse all the tree nodes.",
    },
  },
  {
    cmd = "AerialTreeSyncFolds",
    func = "tree_sync_folds",
    def = {
      desc = "Sync code folding with current tree state. This ignores the link_tree_to_folds setting.",
    },
  },
  {
    cmd = "AerialTreeSetCollapseLevel",
    func = "tree_set_collapse_level",
    def = {
      desc = "Collapse symbols at a depth greater than N (0 collapses all)",
      nargs = 1,
    },
  },
  {
    cmd = "AerialInfo",
    func = "info",
    def = {
      desc = "Print out debug info related to aerial.",
    },
  },
}

---@param mod string Name of aerial module
---@param fn string Name of function to wrap
local function lazy(mod, fn)
  return function(...)
    -- do_setup()
    return require(string.format("aerial.%s", mod))[fn](...)
  end
end

local function create_commands()
  for _, v in pairs(commands) do
    vim.api.nvim_create_user_command(v.cmd, lazy("command", v.func), v.def)
  end
end

M.setup = function(opts)
  if vim.fn.has("nvim-0.8") == 0 then
    vim.notify_once(
      "aerial is deprecated for Neovim <0.8. Please use the nvim-0.5 branch or upgrade Neovim",
      vim.log.levels.ERROR
    )
    return
  end
  config.setup(opts)
  autocommands.on_enter_buffer()
  local group = vim.api.nvim_create_augroup("AerialSetup", {})
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    desc = "Aerial update windows and attach backends",
    pattern = "*",
    group = group,
    callback = function()
      require("aerial.autocommands").on_enter_buffer()
    end,
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Aerial mark LSP backend as available",
    pattern = "*",
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      require("aerial.backends.lsp").on_attach(client, args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("LspDetach", {
    desc = "Aerial mark LSP backend as unavailable",
    pattern = "*",
    group = group,
    callback = function(args)
      require("aerial.backends.lsp").on_detach(args.data.client_id, args.buf)
    end,
  })
  create_commands()
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

---Open the aerial window for the current buffer.
---@param opts nil|table
---    focus boolean If true, jump to aerial window if it is opened (default true)
---    direction "left"|"right"|"float" Direction to open aerial window
M.open = function(opts, old_direction)
  was_closed = false
  opts = opts or {}
  if type(opts) ~= "table" then
    vim.notify_once(
      "Deprecated(aerial.open): The parameters to this function have changed (see :help aerial.open)\nThese parameters will be unsupported on 2023-02-01",
      vim.log.levels.WARN
    )
    local focus = opts
    if focus == "" then
      focus = true
    elseif focus == "!" then
      focus = false
    end
    opts = {
      focus = focus,
      direction = old_direction,
    }
  else
    opts = vim.tbl_extend("keep", opts, {
      focus = true,
    })
  end
  window.open(opts.focus, opts.direction)
end

M.open_all = window.open_all

-- Jump to the aerial window for the current buffer, if it is open
M.focus = function()
  window.focus()
end

---Open or close the aerial window for the current buffer.
---@param opts nil|table
---    focus boolean If true, jump to aerial window if it is opened (default true)
---    direction "left"|"right"|"float" Direction to open aerial window
M.toggle = function(opts, old_direction)
  opts = opts or {}
  if type(opts) ~= "table" then
    vim.notify_once(
      "Deprecated(aerial.toggle): The parameters to this function have changed (see :help aerial.toggle)\nThese parameters will be unsupported on 2023-02-01",
      vim.log.levels.WARN
    )
    local focus = opts
    if focus == "" then
      focus = true
    elseif focus == "!" then
      focus = false
    end
    opts = {
      focus = focus,
      direction = old_direction,
    }
  else
    opts = vim.tbl_extend("keep", opts, {
      focus = true,
    })
  end

  local opened = window.toggle(opts.focus, opts.direction)
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

---@deprecated
M.on_attach = function(...)
  vim.notify_once(
    "Deprecated(aerial.on_attach): you no longer need to call this function\nThis function will be removed on 2023-02-01",
    vim.log.levels.WARN
  )
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
  vim.notify_once(
    "Deprecated(aerial.register_attach_cb): pass `on_attach` to aerial.setup() instead (see :help aerial)\nThis function will be removed on 2023-02-01",
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

_G.aerial_foldexpr = fold.foldexpr

return M
