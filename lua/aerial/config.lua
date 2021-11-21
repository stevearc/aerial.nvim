local M = {}
local has_devicons = pcall(require, "nvim-web-devicons")

-- Copy this to the README after modification
local default_options = {
  -- Priority list of preferred backends for aerial
  backends = { "lsp", "treesitter" },

  -- Enum: persist, close, auto, global
  --   persist - aerial window will stay open until closed
  --   close   - aerial window will close when original file is no longer visible
  --   auto    - aerial window will stay open as long as there is a visible
  --             buffer to attach to
  --   global  - same as 'persist', and will always show symbols for the current buffer
  close_behavior = "auto",

  -- Set to false to remove the default keybindings for the aerial buffer
  default_bindings = true,

  -- Enum: prefer_right, prefer_left, right, left
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
  manage_folds = "auto",

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

  lsp = {
    -- Fetch document symbols when LSP diagnostics change.
    -- If you set this to false, you will need to manually fetch symbols
    diagnostics_trigger_update = true,

    -- Set to false to not update the symbols when there are LSP errors
    update_when_errors = true,
  },

  treesitter = {
    -- How long to wait after a buffer change before updating
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

local function getkey(t, key)
  local cur = t[key]
  if cur ~= nil then
    return cur
  end
  -- This is for backwards compatibility with lsp options that used to be in the
  -- global namespace
  if string.find(key, "lsp%.") == 1 then
    cur = getkey(t, string.sub(key, 5))
    if cur ~= nil then
      return cur
    end
  end

  local pieces = split(key, "\\.")
  cur = t
  for _, piece in ipairs(pieces) do
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
  filter_kind = true,
}

local function get_option(opt)
  local ret = vim.g[string.format("aerial_%s", string.gsub(opt, "%.", "_"))]
  if ret == nil then
    ret = getkey((vim.g.aerial or {}), opt)
  end
  -- People are used to using 1/0 for v:true/v:false in vimscript
  if type(getkey(default_options, opt)) == "boolean" or getkey(addl_bool_opts, opt) then
    if ret == 0 then
      ret = false
    elseif ret == 1 then
      return true
    end
  end
  if ret == nil then
    return getkey(default_options, opt)
  else
    return ret
  end
end

setmetatable(M, {
  __index = function(_, opt)
    return get_option(opt)
  end,
})

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

local function get_table_opt(opt, key, default_key, default)
  return get_table_default(get_option(opt), key, default_key, default)
end

M.include_kind = function(kind, filetype)
  local fk = M.filter_kind
  if type(fk) == "table" and not vim.tbl_islist(fk) then
    local filetype_fk = fk[filetype]
    if filetype_fk == nil then
      filetype_fk = fk["_"]
      if filetype_fk == nil then
        filetype_fk = default_options.filter_kind
      end
    end
    fk = filetype_fk
  end
  return not fk or vim.tbl_contains(fk, kind)
end

M.open_automatic = function()
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  local ret = get_table_opt("open_automatic", ft, "_", false)
  -- People are used to using 0 for v:false in vimscript
  return ret and ret ~= 0
end

M.get_backends = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
  return get_table_opt("backends", ft, "_", {})
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
  Class         = '';
  Constructor   = '';
  Constant      = '[c]';
  Enum          = '';
  EnumMember    = '[e]';
  Event         = '[E]';
  Field         = '[F]';
  File          = '';
  Function      = '';
  Interface     = '';
  Method        = '';
  Module        = '[M]';
  Package       = '';
  String        = '[s]';
  Struct        = '';
  Collapsed     = '';
}

local HAS_LSPKIND, lspkind = pcall(require, "lspkind")

local _last_checked = 0
local _last_icons = {}
M.get_icon = function(kind, collapsed)
  local icons = _last_icons
  if os.time() - _last_checked > 5 then
    local default
    local nerd_font = get_option("nerd_font")
    if nerd_font == "auto" then
      nerd_font = has_devicons
    end
    if nerd_font then
      default = vim.tbl_extend("keep", nerd_icons, plain_icons)
    else
      default = plain_icons
    end
    icons = vim.tbl_extend("keep", M.icons or {}, default)
    _last_icons = icons
    _last_checked = os.time()
  end

  if collapsed then
    return get_table_default(icons, kind .. "Collapsed", "Collapsed", kind)
  else
    if HAS_LSPKIND then
      return lspkind.symbolic(kind, { with_text = false })
        or get_table_default(icons, kind, nil, kind)
    else
      return get_table_default(icons, kind, nil, kind)
    end
  end
end

return M
