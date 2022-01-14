local HAS_DEVICONS = pcall(require, "nvim-web-devicons")
local HAS_LSPKIND, lspkind = pcall(require, "lspkind")

local default_options = {
  -- Priority list of preferred backends for aerial.
  -- This can be a filetype map (see :help aerial-filetype-map)
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

  -- Disable aerial on files with this many lines
  disable_max_lines = 10000,

  -- A list of all symbols to display. Set to false to display all symbols.
  -- This can be a filetype map (see :help aerial-filetype-map)
  -- To see all available values, see :help SymbolKind
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Module",
    "Method",
    "Struct",
  },

  -- Enum: split_width, full_width, last, none
  -- Determines line highlighting mode when multiple splits are visible
  -- split_width   Each open window will have its cursor location marked in the
  --               aerial buffer. Each line will only be partially highlighted
  --               to indicate which window is at that location.
  -- full_width    Each open window will have its cursor location marked as a
  --               full-width highlight in the aerial buffer.
  -- last          Only the most-recently focused window will have its location
  --               marked in the aerial buffer.
  -- none          Do not show the cursor locations in the aerial window.
  highlight_mode = "split_width",

  -- When jumping to a symbol, highlight the line for this many ms.
  -- Set to false to disable
  highlight_on_jump = 300,

  -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
  -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
  -- default collapsed icon. The default icon set is determined by the
  -- "nerd_font" option below.
  -- If you have lspkind-nvim installed, aerial will use it for icons.
  icons = {},

  -- When you fold code with za, zo, or zc, update the aerial tree as well.
  -- Only works when manage_folds = true
  link_folds_to_tree = false,

  -- Fold code when you open/collapse symbols in the tree.
  -- Only works when manage_folds = true
  link_tree_to_folds = true,

  -- Use symbol tree for folding. Set to true or false to enable/disable
  -- 'auto' will manage folds if your previous foldmethod was 'manual'
  manage_folds = false,

  -- The maximum width of the aerial window
  max_width = 40,

  -- The minimum width of the aerial window.
  -- To disable dynamic resizing, set this to be equal to max_width
  min_width = 10,

  -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
  -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
  nerd_font = "auto",

  -- Call this function when aerial attaches to a buffer.
  -- Useful for setting keymaps. Takes a single `bufnr` argument.
  on_attach = nil,

  -- Automatically open aerial when entering supported buffers.
  -- This can be a function (see :help aerial-open-automatic)
  open_automatic = false,

  -- The character that fills the empty space between the end of the
  -- symbol name and the edge of the aerial window
  -- (leaving this as "" will cause partial highlighting on current symbol)
  padchar = " ",

  -- Set to true to only open aerial at the far right/left of the editor
  -- Default behavior opens aerial relative to current window
  placement_editor_edge = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

  -- When true, aerial will automatically close after jumping to a symbol
  close_on_select = false,

  -- Show box drawing characters for the tree hierarchy
  show_guides = false,

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

-- stylua: ignore
local plain_icons = {
  Array         = "[a]",
  Boolean       = "[b]",
  Class         = "[C]",
  Constant      = "[const]",
  Constructor   = "[Co]",
  Enum          = "[E]",
  EnumMember    = "[em]",
  Event         = "[Ev]",
  Field         = "[Fld]",
  File          = "[File]",
  Function      = "[F]",
  Interface     = "[I]",
  Key           = "[K]",
  Method        = "[M]",
  Module        = "[Mod]",
  Namespace     = "[NS]",
  Null          = "[-]",
  Number        = "[n]",
  Object        = "[o]",
  Operator      = "[+]",
  Package       = "[Pkg]",
  Property      = "[P]",
  String        = "[str]",
  Struct        = "[S]",
  TypeParameter = "[T]",
  Variable      = "[V]",
  Collapsed     = "▶",
}

-- stylua: ignore
local nerd_icons = {
  Class       = " ",
  Color       = " ",
  Constant    = " ",
  Constructor = " ",
  Enum        = " ",
  EnumMember  = " ",
  Event       = " ",
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
  String      = "s]",
  Struct      = " ",
  Text        = " ",
  Unit        = "塞",
  Value       = " ",
  Variable    = " ",
  Collapsed   = " ",
}

local M = {}

local function split(string, pattern)
  local ret = {}
  for token in string.gmatch(string, "[^" .. pattern .. "]+") do
    table.insert(ret, token)
  end
  return ret
end

M.get_filetypes = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
  return split(ft, "\\.")
end

local function create_filetype_opt_getter(option, default)
  if type(option) ~= "table" or vim.tbl_islist(option) then
    return function()
      return option
    end
  else
    return function(bufnr)
      for _, ft in ipairs(M.get_filetypes(bufnr)) do
        if option[ft] ~= nil then
          return option[ft]
        end
      end
      return option["_"] and option["_"] or default
    end
  end
end

M.setup = function(opts)
  local newconf = vim.tbl_deep_extend("force", default_options, opts or {})
  if newconf.nerd_font == "auto" then
    newconf.nerd_font = HAS_DEVICONS or HAS_LSPKIND
  end
  -- TODO for backwards compatibility
  for k, _ in pairs(default_options.lsp) do
    if newconf[k] ~= nil then
      newconf.lsp[k] = newconf[k]
      newconf[k] = nil
    end
  end
  newconf.icons = vim.tbl_deep_extend(
    "keep",
    newconf.icons or {},
    newconf.nerd_font and nerd_icons or plain_icons
  )

  -- Much of this logic is for backwards compatibility and can be removed in the
  -- future
  local open_automatic_min_symbols = newconf.open_automatic_min_symbols or 0
  local open_automatic_min_lines = newconf.open_automatic_min_lines or 0
  if
    newconf.open_automatic_min_lines
    or newconf.open_automatic_min_symbols
    or type(newconf.open_automatic) == "table"
  then
    vim.notify(
      "Deprecated: open_automatic should be a boolean or function. See :help aerial-open-automatic",
      vim.log.levels.WARN
    )
    newconf.open_automatic_min_symbols = nil
    newconf.open_automatic_min_lines = nil
  end
  if type(newconf.open_automatic) == "boolean" then
    local open_automatic = newconf.open_automatic
    newconf.open_automatic = function()
      return open_automatic
    end
  elseif type(newconf.open_automatic) ~= "function" then
    local open_automatic_fn = create_filetype_opt_getter(newconf.open_automatic, false)
    newconf.open_automatic = function(bufnr)
      if
        vim.api.nvim_buf_line_count(bufnr) < open_automatic_min_lines
        or require("aerial").num_symbols(bufnr) < open_automatic_min_symbols
      then
        return false
      end
      return open_automatic_fn(bufnr)
    end
  end

  for k, v in pairs(newconf) do
    M[k] = v
  end
  M.backends = create_filetype_opt_getter(M.backends, default_options.backends)
  local get_filter_kind_list = create_filetype_opt_getter(
    M.filter_kind,
    default_options.filter_kind
  )
  M.get_filter_kind_map = function(bufnr)
    local fk = get_filter_kind_list(bufnr)
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

  -- Clear the metatable that looks up the vim.g.aerial values
  setmetatable(M, {})
end

local bool_opts = {
  close_on_select = true,
  default_bindings = true,
  diagnostics_trigger_update = true,
  highlight_mode = true,
  highlight_on_jump = true,
  link_folds_to_tree = true,
  link_tree_to_folds = true,
  manage_folds = true,
  nerd_font = true,
  open_automatic = true,
  placement_editor_edge = true,
  post_jump_cmd = true,
  update_when_errors = true,
}

local function calculate_opts()
  local opts
  local found_var = false
  if vim.g.aerial then
    opts = vim.g.aerial
    found_var = true
  else
    opts = vim.deepcopy(default_options)
  end

  local function walk(prefix, obj)
    for k, v in pairs(obj) do
      local found, var = pcall(vim.api.nvim_get_var, prefix .. k)
      -- This is for backwards compatibility with lsp options that used to be in the
      -- global namespace
      if not found and prefix == "aerial_lsp_" then
        found, var = pcall(vim.api.nvim_get_var, "aerial_" .. k)
      end
      if found then
        found_var = true
        -- Convert 0/1 to true/false for backwards compatibility
        if bool_opts[k] and type(var) ~= "boolean" then
          vim.notify(
            string.format(
              "Deprecated: aerial expects a boolean for option '%s'",
              k,
              vim.log.levels.WARN
            )
          )
          var = var ~= 0
        end
        obj[k] = var
      elseif type(v) == "table" and not vim.tbl_islist(v) then
        walk(prefix .. k .. "_", v)
      end
    end
  end
  walk("aerial_", opts)

  if found_var then
    vim.notify(
      "Deprecated: aerial should no longer be configured with g:aerial, you should use require('aerial').setup(). See :help aerial for more details",
      vim.log.levels.WARN
    )
  end
  return opts
end

-- For backwards compatibility: if we search for config values and we haven't
-- yet called setup(), call setup with the config values pulled from global vars
setmetatable(M, {
  __index = function(t, key)
    M.setup(calculate_opts())
    return rawget(M, key)
  end,
})

-- Exposed for tests
M._get_icon = function(kind, collapsed)
  if collapsed then
    kind = kind .. "Collapsed"
  end
  local ret = M.icons[kind]
  if ret ~= nil then
    return ret
  end
  if collapsed then
    ret = M.icons["Collapsed"]
  end
  return ret or " "
end

M.get_icon = function(kind, collapsed)
  if HAS_LSPKIND and not collapsed then
    local icon = lspkind.symbolic(kind, { with_text = false })
    if icon then
      return icon
    end
  end
  return M._get_icon(kind, collapsed)
end

return M
