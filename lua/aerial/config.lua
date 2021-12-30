local has_devicons = pcall(require, "nvim-web-devicons")

local default_options = {
  -- Priority list of preferred backends for aerial
  backends = { "lsp", "treesitter", "markdown" },

  -- Enum: persist, close, auto, global
  --   persist - aerial window will stay open until closed
  --   close   - aerial window will close when original file is no longer visible
  --   auto    - aerial window will stay open as long as there is a visible
  --             buffer to attach to
  --   global  - same as 'persist', and will always show symbols for the current buffer
  close_behavior = "auto",

  -- Set to false to remove the default keybindings for the aerial buffer
  default_bindings = true,

  -- Enum: prefer_right, prefer_left, right, left, float
  -- Determines the default direction to open the aerial window. The 'prefer'
  -- options will open the window in the other direction *if* there is a
  -- different buffer in the way of the preferred direction
  default_direction = "prefer_right",

  -- A list of all symbols to display. Set to false to display all symbols.
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Method",
    "Struct",
  },

  -- Enum: split_width, full_width, last, none
  -- Determines line highlighting mode when multiple buffers are visible
  highlight_mode = "split_width",

  -- When jumping to a symbol, highlight the line for this many ms
  -- Set to 0 or false to disable
  highlight_on_jump = 300,

  -- Fold code when folding the tree. Only works when manage_folds is enabled
  link_tree_to_folds = true,

  -- Fold the tree when folding code. Only works when manage_folds is enabled
  link_folds_to_tree = false,

  -- Use symbol tree for folding. Set to true or false to enable/disable
  -- 'auto' will manage folds if your previous foldmethod was 'manual'
  manage_folds = false,

  -- The maximum width of the aerial window
  max_width = 40,

  -- The minimum width of the aerial window.
  -- To disable dynamic resizing, set this to be equal to max_width
  min_width = 10,

  -- Set default symbol icons to use Nerd Font icons (see https://www.nerdfonts.com/)
  nerd_font = "auto",

  -- Whether to open aerial automatically when entering a buffer.
  -- Can also be specified per-filetype as a map (see below)
  open_automatic = false,

  -- If open_automatic is true, only open aerial if the source buffer is at
  -- least this long
  open_automatic_min_lines = 0,

  -- If open_automatic is true, only open aerial if there are at least this many symbols
  open_automatic_min_symbols = 0,

  -- Set to true to only open aerial at the far right/left of the editor
  -- Default behavior opens aerial relative to current window
  placement_editor_edge = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

  -- If close_on_select is true, aerial will automatically close after jumping to a symbol
  close_on_select = false,

  -- Options for opening aerial in a floating win
  float = {
    -- Controls border appearance. Passed to nvim_open_win
    border = "rounded",

    -- Controls row offset from cursor. Passed to nvim_open_win
    row = 1,

    -- Controls col offset from cursor. Passed to nvim_open_win
    col = 0,

    -- The maximum height of the floating aerial window
    max_height = 100,

    -- The minimum height of the floating aerial window
    -- To disable dynamic resizing, set this to be equal to max_height
    min_height = 4,
  },

  lsp = {
    -- Fetch document symbols when LSP diagnostics change.
    -- If you set this to false, you will need to manually fetch symbols
    diagnostics_trigger_update = true,

    -- Set to false to not update the symbols when there are LSP errors
    update_when_errors = true,
  },

  treesitter = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },

  markdown = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },
}

local function split(string, pattern)
  local ret = {}
  for token in string.gmatch(string, "[^" .. pattern .. "]+") do
    table.insert(ret, token)
  end
  return ret
end

local function getkey(t, path)
  local cur = t
  for _, piece in ipairs(path) do
    if cur == nil then
      return nil
    end
    cur = cur[piece]
  end
  return cur
end

-- config options that are valid as bools, but don't have bools as the default
local addl_bool_opts = {
  highlight_mode = true,
  highlight_on_jump = true,
  manage_folds = true,
  nerd_font = true,
  post_jump_cmd = true,
}

-- Returns (sanitized) value or the default if value is nil
local function option_or_default(path, value)
  -- People are used to using 1/0 for v:true/v:false in vimscript
  local default_value = getkey(default_options, path)
  if type(default_value) == "boolean" or getkey(addl_bool_opts, path) then
    if value == 0 then
      value = false
    elseif value == 1 then
      return true
    end
  end
  if value == nil then
    return default_value
  else
    return value
  end
end

local function get_option(path)
  -- First look in the g:aerial_<name> variables
  local varname = "aerial_" .. table.concat(path, "_")
  local ret = vim.g[varname]
  -- This is for backwards compatibility with lsp options that used to be in the
  -- global namespace
  local no_lsp_path
  if ret == nil and path[1] == "lsp" then
    no_lsp_path = vim.list_slice(path)
    table.remove(no_lsp_path, 1)
    varname = "aerial_" .. table.concat(no_lsp_path, "_")
    ret = vim.g[varname]
  end

  if ret == nil then
    ret = getkey((vim.g.aerial or {}), path)
  end
  -- For the same backwards compatibility as above
  if ret == nil and path[1] == "lsp" then
    ret = getkey((vim.g.aerial or {}), no_lsp_path)
  end

  return option_or_default(path, ret)
end

local Config = {}
function Config:new(path)
  return setmetatable({
    __path = path or {},
  }, {
    __index = function(t, key)
      local ret = rawget(Config, key)
      if ret then
        return ret
      end
      local keypath = vim.list_extend({}, t.__path)
      vim.list_extend(keypath, split(key, "\\."))
      ret = get_option(keypath)
      if type(ret) == "table" and (vim.tbl_isempty(ret) or not vim.tbl_islist(ret)) then
        return t:new(keypath)
      end
      return ret
    end,
  })
end

local M = Config:new()

M.get_filetypes = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
  return split(ft, "\\.")
end

local function create_filetype_opt_getter(path)
  if type(path) ~= "table" then
    path = { path }
  end
  return function(bufnr)
    local ret = get_option(path)
    if type(ret) == "table" then
      local found = false
      for _, ft in ipairs(M.get_filetypes(bufnr)) do
        if ret[ft] then
          found = true
          ret = ret[ft]
          break
        end
      end
      if not found then
        ret = ret["_"] or default_options[path]
      end
    end
    return option_or_default(path, ret)
  end
end

M.backends = create_filetype_opt_getter("backends")
M.open_automatic = create_filetype_opt_getter("open_automatic")

M.get_filter_kind_map = function(bufnr)
  local fk = M.filter_kind
  if type(fk) == "table" and not vim.tbl_islist(fk) then
    local found = false
    for _, filetype in ipairs(M.get_filetypes(bufnr)) do
      if fk[filetype] then
        fk = fk[filetype]
        found = true
        break
      end
    end
    if not found then
      fk = fk["_"] or default_options.filter_kind
    end
  end

  if fk == false or fk == 0 then
    return setmetatable({}, {
      __index = function()
        return true
      end,
      __tostring = function()
        return "all symbols"
      end,
    })
  else
    local ret = {}
    for _, kind in ipairs(fk) do
      ret[kind] = true
    end
    return setmetatable(ret, {
      __tostring = function()
        return table.concat(fk, ", ")
      end,
    })
  end
end

-- stylua: ignore
local plain_icons = {
  Array         = '[a]';
  Boolean       = '[b]';
  Class         = '[C]';
  Constant      = '[const]';
  Constructor   = '[Co]';
  Enum          = '[E]';
  EnumMember    = '[em]';
  Event         = '[Ev]';
  Field         = '[Fld]';
  File          = '[File]';
  Function      = '[F]';
  Interface     = '[I]';
  Key           = '[K]';
  Method        = '[M]';
  Module        = '[Mod]';
  Namespace     = '[NS]';
  Null          = '[-]';
  Number        = '[n]';
  Object        = '[o]';
  Operator      = '[+]';
  Package       = '[Pkg]';
  Property      = '[P]';
  String        = '[str]';
  Struct        = '[S]';
  TypeParameter = '[T]';
  Variable      = '[V]';
  Collapsed     = '▶';
}

-- stylua: ignore
local nerd_icons = {
  Class       = " ",
  Color       = " ",
  Constant    = " ",
  Constructor = " ",
  Enum        = " ",
  EnumMember  = " ",
  Event       = "",
  Field       = " ",
  File        = " ",
  Folder      = " ",
  Function    = " ",
  Interface   = " ",
  Keyword     = " ",
  Method      = " ",
  Module      = " ",
  Operator    = " ",
  Package     = " ",
  Property    = " ",
  Reference   = " ",
  Snippet     = " ",
  String      = "s]";
  Struct      = " ",
  Text        = " ",
  Unit        = "塞",
  Value       = " ",
  Variable    = " ",
  Collapsed   = " ";
}

local function get_table_default(tab, key, default_key, default)
  if type(tab) ~= "table" or vim.tbl_islist(tab) then
    return tab
  end
  local ret = tab[key]
  if ret == nil and default_key then
    ret = tab[default_key]
  end
  if ret == nil then
    return default
  else
    return ret
  end
end

-- Only exposed for tests
M._get_icons = function()
  local default
  local nerd_font = M.nerd_font
  if nerd_font == "auto" then
    nerd_font = has_devicons
  end
  if nerd_font then
    default = vim.tbl_extend("keep", nerd_icons, plain_icons)
  else
    default = plain_icons
  end
  return vim.tbl_extend("keep", get_option({ "icons" }) or {}, default)
end

local HAS_LSPKIND, lspkind = pcall(require, "lspkind")
local _last_checked = 0
local _last_icons = {}
M.get_icon = function(kind, collapsed)
  if HAS_LSPKIND and not collapsed then
    local icon = lspkind.symbolic(kind, { with_text = false })
    if icon then
      return icon
    end
  end

  local icons = _last_icons
  if os.time() - _last_checked > 5 then
    icons = M._get_icons()
    _last_icons = icons
    _last_checked = os.time()
  end

  if collapsed then
    return get_table_default(icons, kind .. "Collapsed", "Collapsed", kind)
  else
    return get_table_default(icons, kind, nil, kind)
  end
end

return M
