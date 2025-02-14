local M = {}

---@diagnostic disable undefined-doc-param

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
    defn = {
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
    defn = {
      desc = "Open the aerial window. With `!` cursor stays in current window",
      nargs = "?",
      bang = true,
      complete = list_complete({ "left", "right", "float" }),
    },
  },
  {
    cmd = "AerialOpenAll",
    func = "open_all",
    defn = {
      desc = "Open an aerial window for each visible window.",
    },
  },
  {
    cmd = "AerialClose",
    func = "close",
    defn = {
      desc = "Close the aerial window.",
    },
  },
  {
    cmd = "AerialCloseAll",
    func = "close_all",
    defn = {
      desc = "Close all visible aerial windows.",
    },
  },
  {
    cmd = "AerialNext",
    func = "next",
    meta = { retry_on_setup = true },
    defn = {
      desc = "Jump forwards {count} symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialPrev",
    func = "prev",
    meta = { retry_on_setup = true },
    defn = {
      desc = "Jump backwards [count] symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialGo",
    func = "go",
    meta = { retry_on_setup = true },
    defn = {
      desc = "Jump to the [count] symbol (default 1).",
      count = 1,
      bang = true,
      nargs = "?",
    },
    long_desc = 'If with [!] and inside aerial window, the cursor will stay in the aerial window. [split] can be "v" to open a new vertical split, or "h" to open a horizontal split. [split] can also be a raw vim command, such as "belowright split". This command respects |switchbuf|=uselast',
  },
  {
    cmd = "AerialInfo",
    func = "info",
    defn = {
      desc = "Print out debug info related to aerial.",
    },
  },
  {
    cmd = "AerialNavToggle",
    func = "nav_toggle",
    defn = {
      desc = "Open or close the aerial nav window.",
    },
  },
  {
    cmd = "AerialNavOpen",
    func = "nav_open",
    defn = {
      desc = "Open the aerial nav window.",
    },
  },
  {
    cmd = "AerialNavClose",
    func = "nav_close",
    defn = {
      desc = "Close the aerial nav window.",
    },
  },
}

local do_setup

local pending_funcs = {}
---@private
M.process_pending_fn_calls = function()
  for _, func_bundle in ipairs(pending_funcs) do
    local bufnr, mod, fn, args = unpack(func_bundle)
    if vim.api.nvim_get_current_buf() == bufnr then
      require(string.format("aerial.%s", mod))[fn](vim.F.unpack_len(args))
    end
  end
  pending_funcs = {}
end

---@param mod string Name of aerial module
---@param fn string Name of function to wrap
---@param retry_on_setup? boolean If true, will retry the function on attach if aerial is not setup yet
local function lazy(mod, fn, retry_on_setup)
  return function(...)
    if do_setup() and retry_on_setup then
      ---When aerial first starts up it may take a bit of time before we get symbols for a buffer.
      ---Since lazy-loading puts off initialization, we can lose the first command (e.g. AerialNext
      ---will trigger initialization and load symbols, but there are no symbols yet so it will be a
      ---no-op). To fix this, we stick these commands in a pending queue and retry them after aerial
      ---attaches to a buffer.
      table.insert(pending_funcs, { vim.api.nvim_get_current_buf(), mod, fn, vim.F.pack_len(...) })
      vim.defer_fn(function()
        -- Timeout: if we don't consume these soon, we should clear them
        pending_funcs = {}
      end, 1000)
    end
    return require(string.format("aerial.%s", mod))[fn](...)
  end
end

local function create_commands()
  for _, v in pairs(commands) do
    local callback = lazy("command", v.func, vim.tbl_get(v, "meta", "retry_on_setup"))
    vim.api.nvim_create_user_command(v.cmd, callback, v.defn)
  end
end

local function create_autocmds()
  local group = vim.api.nvim_create_augroup("AerialSetup", {})
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    desc = "Aerial update windows and attach backends",
    pattern = "*",
    group = group,
    callback = function()
      do_setup()
      require("aerial.autocommands").on_enter_buffer()
    end,
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Aerial mark LSP backend as available",
    pattern = "*",
    group = group,
    callback = function(args)
      do_setup()
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      require("aerial.backends.lsp").on_attach(client, args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("LspDetach", {
    desc = "Aerial mark LSP backend as unavailable",
    pattern = "*",
    group = group,
    callback = function(args)
      do_setup()
      require("aerial.backends.lsp").on_detach(args.data.client_id, args.buf)
    end,
  })
end

local pending_opts
local initialized = false
do_setup = function()
  if not pending_opts then
    return false
  end
  require("aerial.config").setup(pending_opts)
  create_autocmds()
  require("aerial.highlight").create_highlight_groups()
  require("aerial.autocommands").on_enter_buffer()
  pending_opts = nil
  initialized = true
  return true
end

---Initialize aerial
---@param opts? table
M.setup = function(opts)
  if vim.fn.has("nvim-0.9") == 0 then
    vim.notify_once(
      "aerial is deprecated for Neovim <0.9. Please use a nvim-0.x branch or upgrade Neovim",
      vim.log.levels.ERROR
    )
    return
  end
  pending_opts = opts or {}
  create_commands()

  local is_lazy = pending_opts.lazy_load == true
    or (
      pending_opts.lazy_load == nil
      and pending_opts.on_attach == nil
      and not pending_opts.open_automatic
    )
  pending_opts.lazy_load = is_lazy
  if not is_lazy then
    create_autocmds()
  end

  if initialized then
    do_setup()
  end
end

---Synchronously complete setup (if lazy-loaded)
M.sync_load = function()
  do_setup()
end

---Returns true if aerial is open for the current window or buffer (returns false inside an aerial buffer)
---@param opts? table
---    bufnr? integer
---    winid? integer
---@return boolean
M.is_open = function(opts)
  do_setup()
  return require("aerial.window").is_open(opts)
end

---Close the aerial window.
M.close = function()
  do_setup()
  was_closed = true
  require("aerial.window").close()
end

---Close all visible aerial windows.
M.close_all = lazy("window", "close_all")

---Close all visible aerial windows except for the one currently focused or for the currently focused window.
M.close_all_but_current = lazy("window", "close_all_but_current")

---@class (exact) aerial.openOpts
---@field focus? boolean If true, jump to aerial window if it is opened (default true)
---@field direction? "left"|"right"|"float" Direction to open aerial window

---Open the aerial window for the current buffer.
---@param opts? aerial.openOpts
M.open = function(opts)
  do_setup()
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
  do_setup()
  was_closed = false
  local source_bufnr = vim.api.nvim_win_get_buf(source_win)
  require("aerial.window").open_aerial_in_win(source_bufnr, source_win, target_win)
end

---Open an aerial window for each visible window.
M.open_all = lazy("window", "open_all")

---Jump to the aerial window for the current buffer, if it is open
M.focus = lazy("window", "focus")

---Open or close the aerial window for the current buffer.
---@param opts? aerial.openOpts
M.toggle = function(opts)
  do_setup()
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
  do_setup()
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

---@class (exact) aerial.selectOpts
---@field index? integer The symbol to jump to. If nil, will jump to the symbol under the cursor (in the aerial buffer)
---@field split? string Jump to the symbol in a new split. Can be "v" for vertical or "h" for horizontal. Can also be a raw command to execute (e.g. "belowright split")
---@field jump? boolean If false and in the aerial window, do not leave the aerial window. (Default true)

---Jump to a specific symbol.
---@param opts? aerial.selectOpts
M.select = lazy("navigation", "select", true)

---Jump forwards in the symbol list.
---@param step? integer Number of symbols to jump by (default 1)
M.next = lazy("navigation", "next", true)

---Jump backwards in the symbol list.
---@param step? integer Number of symbols to jump by (default 1)
M.prev = lazy("navigation", "prev", true)

local nav_up = lazy("navigation", "up", true)

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

---Open a document symbol picker using snacks.nvim
---@param opts? snacks.picker.Config
M.snacks_picker = function(opts)
  M.sync_load()
  require("aerial.snacks").pick_symbol(opts)
end

---@class aerial.SymbolView : aerial.SymbolBase
---@field icon string

---Get a list representing the symbol path to the current location.
---@param exact? boolean If true, only return symbols if we are exactly inside the hierarchy. When false, will return the closest symbol.
---@return aerial.SymbolView[]
---@note
--- Returns empty list if none found or in an invalid buffer.
M.get_location = function(exact)
  do_setup()
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
      scope = item.scope,
    })
    item = item.parent
  end
  return ret
end

---Collapse all nodes in the symbol tree
---@param bufnr? integer
M.tree_close_all = lazy("tree", "close_all")

---Expand all nodes in the symbol tree
---@param bufnr? integer
M.tree_open_all = lazy("tree", "open_all")

---Set the collapse level of the symbol tree
---@param bufnr integer
---@param level integer 0 is all closed, use 99 to open all
M.tree_set_collapse_level = lazy("tree", "set_collapse_level")

---Increase the fold level of the symbol tree
---@param bufnr integer
---@param count? integer
M.tree_increase_fold_level = lazy("tree", "increase_fold_level")

---Decrease the fold level of the symbol tree
---@param bufnr integer
---@param count? integer
M.tree_decrease_fold_level = lazy("tree", "decrease_fold_level")

---Open the tree at the selected location
---@param opts? table
---    index? integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold? boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse? boolean If true, perform the action recursively on all children (default false)
---    bubble? boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_open = lazy("tree", "open")

---Collapse the tree at the selected location
---@param opts? table
---    index? integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold? boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse? boolean If true, perform the action recursively on all children (default false)
---    bubble? boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_close = lazy("tree", "close")

---Toggle the collapsed state at the selected location
---@param opts? table
---    index? integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold? boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse? boolean If true, perform the action recursively on all children (default false)
---    bubble? boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_toggle = lazy("tree", "toggle")

---Check if the nav windows are open
---@return boolean
M.nav_is_open = lazy("nav_view", "is_open")

---Open the nav windows
M.nav_open = lazy("nav_view", "open")

---Close the nav windows
M.nav_close = lazy("nav_view", "close")

---Toggle the nav windows open/closed
M.nav_toggle = lazy("nav_view", "toggle")

---Clear aerial's tree-sitter query cache
M.treesitter_clear_query_cache = lazy("backends.treesitter.helpers", "clear_query_cache")

---Sync code folding with the current tree state.
---@param bufnr? integer
---@note
--- Ignores the 'link_tree_to_folds' config option.
M.sync_folds = function(bufnr)
  do_setup()
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
  do_setup()
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
  do_setup()
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

_G.aerial_foldexpr = lazy("fold", "foldexpr")

---Used for documentation generation
---@private
M.get_all_commands = function()
  local cmds = vim.deepcopy(commands)
  for _, v in ipairs(cmds) do
    -- Remove all function values from the command definition so we can serialize it
    for k, param in pairs(v.defn) do
      if type(param) == "function" then
        v.defn[k] = nil
      end
    end
  end
  return cmds
end

return M
