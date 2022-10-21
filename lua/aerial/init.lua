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
    cmd = "AerialCloseAllButCurrent",
    func = "close_all_but_current",
    deprecated = {
      alternative = "aerial.close_all_but_current()",
      help = "aerial.close_all_but_current",
    },
    defn = {
      desc = "Close all visible aerial windows except for the one currently focused or for the currently focused window.",
    },
  },
  {
    cmd = "AerialNext",
    func = "next",
    defn = {
      desc = "Jump forwards {count} symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialPrev",
    func = "prev",
    defn = {
      desc = "Jump backwards [count] symbols (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialNextUp",
    func = "next_up",
    deprecated = {
      alternative = "aerial.up()",
      help = "aerial.up",
    },
    defn = {
      desc = "Jump up the tree [count] levels, moving forwards in the file (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialPrevUp",
    func = "next_up",
    deprecated = {
      alternative = "aerial.up()",
      help = "aerial.up",
    },
    defn = {
      desc = "Jump up the tree [count] levels, moving backwards in the file (default 1).",
      count = 1,
    },
  },
  {
    cmd = "AerialGo",
    func = "go",
    defn = {
      desc = "Jump to the [count] symbol (default 1).",
      count = 1,
      bang = true,
      nargs = "?",
    },
    long_desc = 'If with [!] and inside aerial window, the cursor will stay in the aerial window. [split] can be "v" to open a new vertical split, or "h" to open a horizontal split. [split] can also be a raw vim command, such as "belowright split". This command respects |switchbuf|=uselast',
  },
  {
    cmd = "AerialTreeOpen",
    func = "tree_open",
    deprecated = {
      alternative = "aerial.tree_open()",
      help = "aerial.tree_cmd",
    },
    defn = {
      desc = "Expand the tree at the current location. If with [!] then will expand recursively.",
      bang = true,
    },
  },
  {
    cmd = "AerialTreeClose",
    func = "tree_close",
    deprecated = {
      alternative = "aerial.tree_close()",
      help = "aerial.tree_close",
    },
    defn = {
      desc = "Collapse the tree at the current location. If with [!] then will collapse recursively.",
      bang = true,
    },
  },
  {
    cmd = "AerialTreeToggle",
    func = "tree_toggle",
    deprecated = {
      alternative = "aerial.tree_toggle()",
      help = "aerial.tree_toggle",
    },
    defn = {
      desc = "Toggle the tree at the current location. If with [!] then will toggle recursively.",
      bang = true,
    },
  },
  {
    cmd = "AerialTreeOpenAll",
    func = "tree_open_all",
    deprecated = {
      alternative = "aerial.tree_open_all()",
      help = "aerial.tree_open_all",
    },
    defn = {
      desc = "Expand all the tree nodes.",
    },
  },
  {
    cmd = "AerialTreeCloseAll",
    func = "tree_close_all",
    deprecated = {
      alternative = "aerial.tree_close_all()",
      help = "aerial.tree_close_all",
    },
    defn = {
      desc = "Collapse all the tree nodes.",
    },
  },
  {
    cmd = "AerialTreeSyncFolds",
    func = "tree_sync_folds",
    deprecated = {
      alternative = "aerial.tree_sync_folds()",
      help = "aerial.tree_sync_folds",
    },
    defn = {
      desc = "Sync code folding with current tree state. This ignores the link_tree_to_folds setting.",
    },
  },
  {
    cmd = "AerialTreeSetCollapseLevel",
    func = "tree_set_collapse_level",
    args = "N",
    deprecated = {
      alternative = "aerial.tree_set_collapse_level()",
      help = "aerial.tree_set_collapse_level",
    },
    defn = {
      desc = "Collapse symbols at a depth greater than N (0 collapses all)",
      nargs = 1,
    },
  },
  {
    cmd = "AerialInfo",
    func = "info",
    defn = {
      desc = "Print out debug info related to aerial.",
    },
  },
}

local do_setup

---@param mod string Name of aerial module
---@param fn string Name of function to wrap
local function lazy(mod, fn)
  return function(...)
    do_setup()
    return require(string.format("aerial.%s", mod))[fn](...)
  end
end

local function create_commands()
  for _, v in pairs(commands) do
    local callback = lazy("command", v.func)
    if v.deprecated then
      local msg = string.format(":%s is deprecated.", v.cmd)
      if type(v.deprecated) == "table" then
        if v.deprecated.alternative then
          msg = string.format("%s Please use %s instead", msg, v.deprecated.alternative)
        end
        if v.deprecated.help then
          msg = string.format("%s (see :help %s)", msg, v.deprecated.help)
        end
      end
      msg = msg .. "\nThis command will be removed on 2023-02-01"
      callback = function(...)
        vim.notify_once(msg, vim.log.levels.WARN)
        lazy("command", v.func)(...)
      end
    end
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
    return
  end
  require("aerial.config").setup(pending_opts)
  create_autocmds()
  require("aerial.highlight").create_highlight_groups()
  require("aerial.autocommands").on_enter_buffer()
  pending_opts = nil
  initialized = true
end

---Initialize aerial
---@param opts nil|table
M.setup = function(opts)
  if vim.fn.has("nvim-0.8") == 0 then
    vim.notify_once(
      "aerial is deprecated for Neovim <0.8. Please use the nvim-0.5 branch or upgrade Neovim",
      vim.log.levels.ERROR
    )
    return
  end
  pending_opts = opts or {}
  create_commands()

  local is_lazy = pending_opts.lazy_load == true
  if not is_lazy then
    create_autocmds()
  end

  if initialized then
    do_setup()
  end
end

---Returns true if aerial is open for the current window or buffer (returns false inside an aerial buffer)
---@param opts nil|table
---    bufnr nil|integer
---    winid nil|integer
---@return boolean
M.is_open = function(opts)
  do_setup()
  if type(opts) == "number" then
    -- For backwards compatibility
    opts = { bufnr = opts }
    vim.notify_once(
      "Deprecated(aerial.is_open): The parameters to this function have changed (see :help aerial.is_open)\nThese parameters will be unsupported on 2023-02-01",
      vim.log.levels.WARN
    )
  end
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

local function convert_open_args(fn_name, opts, old_direction)
  if type(opts) ~= "table" then
    vim.notify_once(
      string.format(
        "Deprecated(%s): The parameters to this function have changed (see :help %s)\nThese parameters will be unsupported on 2023-02-01",
        fn_name,
        fn_name
      ),
      vim.log.levels.WARN
    )
    local focus = opts
    if focus == "" then
      focus = true
    elseif focus == "!" then
      focus = false
    end
    return {
      focus = focus,
      direction = old_direction,
    }
  else
    return vim.tbl_extend("keep", opts, {
      focus = true,
    })
  end
end
---Open the aerial window for the current buffer.
---@param opts nil|table
---    focus boolean If true, jump to aerial window if it is opened (default true)
---    direction "left"|"right"|"float" Direction to open aerial window
M.open = function(opts, old_direction)
  do_setup()
  was_closed = false
  opts = convert_open_args("aerial.open", opts or {}, old_direction)
  require("aerial.window").open(opts.focus, opts.direction)
end

---Open an aerial window for each visible window.
M.open_all = lazy("window", "open_all")

---Jump to the aerial window for the current buffer, if it is open
M.focus = lazy("window", "focus")

---Open or close the aerial window for the current buffer.
---@param opts nil|table
---    focus boolean If true, jump to aerial window if it is opened (default true)
---    direction "left"|"right"|"float" Direction to open aerial window
M.toggle = function(opts, old_direction)
  do_setup()
  opts = convert_open_args("aerial.toggle", opts or {}, old_direction)
  local opened = require("aerial.window").toggle(opts.focus, opts.direction)
  was_closed = not opened
  return opened
end

---Jump to a specific symbol.
---@param opts nil|table
---    index nil|integer The symbol to jump to. If nil, will jump to the symbol under the cursor (in the aerial buffer)
---    split nil|string Jump to the symbol in a new split. Can be "v" for vertical or "h" for horizontal. Can also be a raw command to execute (e.g. "belowright split")
---    jump nil|boolean If false and in the aerial window, do not leave the aerial window. (Default true)
M.select = lazy("navigation", "select")

---Jump forwards in the symbol list.
---@param step nil|integer Number of symbols to jump by (default 1)
M.next = lazy("navigation", "next")

---Jump backwards in the symbol list.
---@param step nil|integer Number of symbols to jump by (default 1)
M.prev = lazy("navigation", "prev")

---Jump to a symbol higher in the tree
---@deprecated
---@param direction integer -1 for backwards or 1 for forwards
---@param count nil|integer How many levels to jump up (default 1)
M.up = function(...)
  do_setup()
  vim.notify_once(
    "Deprecated(aerial.up): use aerial.next_up and aerial.prev_up instead\nThis function will be removed on 2023-02-01",
    vim.log.levels.WARN
  )
  require("aerial.navigation").up(...)
end

---Jump to a symbol higher in the tree, moving forwards
---@param count nil|integer How many levels to jump up (default 1)
M.next_up = function(count)
  do_setup()
  require("aerial.navigation").up(1, count)
end

---Jump to a symbol higher in the tree, moving backwards
---@param count nil|integer How many levels to jump up (default 1)
M.prev_up = function(count)
  do_setup()
  require("aerial.navigation").up(-1, count)
end

---@deprecated
M.on_attach = function(...)
  vim.notify_once(
    "Deprecated(aerial.on_attach): you no longer need to call this function\nThis function will be removed on 2023-02-01",
    vim.log.levels.WARN
  )
end

---Get a list representing the symbol path to the current location.
---@param exact nil|boolean If true, only return symbols if we are exactly inside the hierarchy. When false, will return the closest symbol.
---@return table[]
---@note
--- Returns empty list if none found or in an invalid buffer.
--- Items have the following keys:
---     name   The name of the symbol
---     kind   The SymbolKind of the symbol
---     icon   The icon that represents the symbol
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
    })
    item = item.parent
  end
  return ret
end

---Collapse all nodes in the symbol tree
---@param bufnr nil|integer
M.tree_close_all = lazy("tree", "close_all")

---Expand all nodes in the symbol tree
---@param bufnr nil|integer
M.tree_open_all = lazy("tree", "open_all")

---Set the collapse level of the symbol tree
---@param bufnr integer
---@param level integer 0 is all closed, use 99 to open all
M.tree_set_collapse_level = lazy("tree", "set_collapse_level")

---Open the tree at the selected location
---@param opts nil|table
---    index nil|integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold nil|boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse nil|boolean If true, perform the action recursively on all children (default false)
---    bubble nil|boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_open = lazy("tree", "open")

---Collapse the tree at the selected location
---@param opts nil|table
---    index nil|integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold nil|boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse nil|boolean If true, perform the action recursively on all children (default false)
---    bubble nil|boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_close = lazy("tree", "close")

---Toggle the collapsed state at the selected location
---@param opts nil|table
---    index nil|integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold nil|boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse nil|boolean If true, perform the action recursively on all children (default false)
---    bubble nil|boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
M.tree_toggle = lazy("tree", "toggle")

---Sync code folding with the current tree state.
---@param bufnr integer
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

---Register a callback to be called when aerial is attached to a buffer.
---@deprecated
M.register_attach_cb = function(callback)
  do_setup()
  vim.notify_once(
    "Deprecated(aerial.register_attach_cb): pass `on_attach` to aerial.setup() instead (see :help aerial)\nThis function will be removed on 2023-02-01",
    vim.log.levels.WARN
  )
  require("aerial.config").on_attach = callback
end

---Get debug info for aerial
---@return table
M.info = function()
  do_setup()
  local util = require("aerial.util")
  local bufnr = util.get_buffers(0)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return {
    filetype = filetype,
    filter_kind_map = require("aerial.config").get_filter_kind_map(),
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
    return data.get_or_create(bufnr):count()
  else
    return 0
  end
end

---Returns true if the user has manually closed aerial. Will become false if the user opens aerial again.
---@param default nil|boolean
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
