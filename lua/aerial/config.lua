local HAS_DEVICONS = pcall(require, "nvim-web-devicons")
local HAS_LSPKIND, lspkind = pcall(require, "lspkind")

local default_options = {
  -- Priority list of preferred backends for aerial.
  -- This can be a filetype map (see :help aerial-filetype-map)
  backends = { "treesitter", "lsp", "markdown" },

  layout = {
    -- These control the width of the aerial window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a list of mixed types.
    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
    max_width = { 40, 0.2 },
    width = nil,
    min_width = 10,

    -- Enum: prefer_right, prefer_left, right, left, float
    -- Determines the default direction to open the aerial window. The 'prefer'
    -- options will open the window in the other direction *if* there is a
    -- different buffer in the way of the preferred direction
    default_direction = "prefer_right",

    -- Enum: edge, group, window
    --   edge   - open aerial at the far right/left of the editor
    --   group  - open aerial to the right/left of the group of windows containing the current buffer
    --   window - open aerial to the right/left of the current window
    placement = "window",
  },

  -- Enum: persist, close, auto, global
  --   persist - aerial window will stay open until closed
  --   close   - aerial window will close when original file is no longer visible
  --   auto    - aerial window will stay open as long as there is a visible
  --             buffer to attach to
  --   global  - same as 'persist', and will always show symbols for the current buffer
  close_behavior = "auto",

  -- Set to false to remove the default keybindings for the aerial buffer
  default_bindings = true,

  -- Disable aerial on files with this many lines
  disable_max_lines = 10000,

  -- Disable aerial on files this size or larger (in bytes)
  disable_max_size = 2000000, -- Default 2MB

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
  -- Determines line highlighting mode when multiple splits are visible.
  -- split_width   Each open window will have its cursor location marked in the
  --               aerial buffer. Each line will only be partially highlighted
  --               to indicate which window is at that location.
  -- full_width    Each open window will have its cursor location marked as a
  --               full-width highlight in the aerial buffer.
  -- last          Only the most-recently focused window will have its location
  --               marked in the aerial buffer.
  -- none          Do not show the cursor locations in the aerial window.
  highlight_mode = "split_width",

  -- Highlight the closest symbol if the cursor is not exactly on one.
  highlight_closest = true,

  -- Highlight the symbol in the source buffer when cursor is in the aerial win
  highlight_on_hover = false,

  -- When jumping to a symbol, highlight the line for this many ms.
  -- Set to false to disable
  highlight_on_jump = 300,

  -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
  -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
  -- default collapsed icon. The default icon set is determined by the
  -- "nerd_font" option below.
  -- If you have lspkind-nvim installed, it will be the default icon set.
  -- This can be a filetype map (see :help aerial-filetype-map)
  icons = {},

  -- Control which windows and buffers aerial should ignore.
  -- If close_behavior is "global", focusing an ignored window/buffer will
  -- not cause the aerial window to update.
  -- If open_automatic is true, focusing an ignored window/buffer will not
  -- cause an aerial window to open.
  -- If open_automatic is a function, ignore rules have no effect on aerial
  -- window opening behavior; it's entirely handled by the open_automatic
  -- function.
  ignore = {
    -- Ignore unlisted buffers. See :help buflisted
    unlisted_buffers = true,

    -- List of filetypes to ignore.
    filetypes = {},

    -- Ignored buftypes.
    -- Can be one of the following:
    -- false or nil - No buftypes are ignored.
    -- "special"    - All buffers other than normal buffers are ignored.
    -- table        - A list of buftypes to ignore. See :help buftype for the
    --                possible values.
    -- function     - A function that returns true if the buffer should be
    --                ignored or false if it should not be ignored.
    --                Takes two arguments, `bufnr` and `buftype`.
    buftypes = "special",

    -- Ignored wintypes.
    -- Can be one of the following:
    -- false or nil - No wintypes are ignored.
    -- "special"    - All windows other than normal windows are ignored.
    -- table        - A list of wintypes to ignore. See :help win_gettype() for the
    --                possible values.
    -- function     - A function that returns true if the window should be
    --                ignored or false if it should not be ignored.
    --                Takes two arguments, `winid` and `wintype`.
    wintypes = "special",
  },

  -- When you fold code with za, zo, or zc, update the aerial tree as well.
  -- Only works when manage_folds = true
  link_folds_to_tree = false,

  -- Fold code when you open/collapse symbols in the tree.
  -- Only works when manage_folds = true
  link_tree_to_folds = true,

  -- Use symbol tree for folding. Set to true or false to enable/disable
  -- 'auto' will manage folds if your previous foldmethod was 'manual'
  manage_folds = false,

  -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
  -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
  nerd_font = "auto",

  -- Call this function when aerial attaches to a buffer.
  -- Useful for setting keymaps. Takes a single `bufnr` argument.
  on_attach = nil,

  -- Call this function when aerial first sets symbols on a buffer.
  -- Takes a single `bufnr` argument.
  on_first_symbols = nil,

  -- Automatically open aerial when entering supported buffers.
  -- This can be a function (see :help aerial-open-automatic)
  open_automatic = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

  -- When true, aerial will automatically close after jumping to a symbol
  close_on_select = false,

  -- Show box drawing characters for the tree hierarchy
  show_guides = false,

  -- The autocmds that trigger symbols update (not used for LSP backend)
  update_events = "TextChanged,InsertLeave",

  -- Customize the characters used when show_guides = true
  guides = {
    -- When the child item has a sibling below it
    mid_item = "├─",
    -- When the child item is the last in the list
    last_item = "└─",
    -- When there are nested child guides to the right
    nested_top = "│ ",
    -- Raw indentation
    whitespace = "  ",
  },

  -- Options for opening aerial in a floating win
  float = {
    -- Controls border appearance. Passed to nvim_open_win
    border = "rounded",

    -- Enum: cursor, editor, win
    --   cursor - Opens float on top of the cursor
    --   editor - Opens float centered in the editor
    --   win    - Opens float centered in the window
    relative = "cursor",

    -- These control the height of the floating window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a list of mixed types.
    -- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
    max_height = 0.9,
    height = nil,
    min_height = { 8, 0.1 },

    override = function(conf)
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      return conf
    end,
  },

  lsp = {
    -- Fetch document symbols when LSP diagnostics update.
    -- If false, will update on buffer changes.
    diagnostics_trigger_update = true,

    -- Set to false to not update the symbols when there are LSP errors
    update_when_errors = true,

    -- How long to wait (in ms) after a buffer change before updating
    -- Only used when diagnostics_trigger_update = false
    update_delay = 300,
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

M.get_filetypes = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
  return vim.split(ft, "%.")
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

local function compat_move_option(opts, key, nested_key)
  -- TODO: deprecation warning for users to move the option
  if opts[key] ~= nil then
    opts[nested_key] = opts[nested_key] or {}
    opts[nested_key][key] = opts[key]
    opts[key] = nil
  end
end

M.setup = function(opts)
  opts = opts or {}

  -- For backwards compatibility
  opts.layout = opts.layout or {}
  compat_move_option(opts, "max_width", "layout")
  compat_move_option(opts, "width", "layout")
  compat_move_option(opts, "min_width", "layout")
  compat_move_option(opts, "default_direction", "layout")
  if opts.placement_editor_edge ~= nil then
    -- TODO: deprecation warning
    opts.layout.placement = opts.placement_editor_edge and "edge" or "window"
  end
  compat_move_option(opts, "placement_editor_edge", "layout")

  local newconf = vim.tbl_deep_extend("force", default_options, opts)
  if newconf.nerd_font == "auto" then
    newconf.nerd_font = HAS_DEVICONS or HAS_LSPKIND
  end

  -- Undocumented use_lspkind option for tests. End users can simply provide
  -- their own icons
  if newconf.use_lspkind == nil then
    newconf.use_lspkind = true
  end

  -- If not managing folds, don't link either direction
  if newconf.manage_folds == false then
    newconf.link_tree_to_folds = false
    newconf.link_folds_to_tree = false
  end

  -- for backwards compatibility
  for k, _ in pairs(default_options.lsp) do
    if newconf[k] ~= nil then
      newconf.lsp[k] = newconf[k]
      newconf[k] = nil
    end
  end
  newconf.default_icons = newconf.nerd_font and nerd_icons or plain_icons

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
    newconf.open_automatic = function(bufnr)
      return open_automatic and not require("aerial.util").is_ignored_buf(bufnr)
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

  if newconf.float.row or newconf.float.col then
    vim.notify(
      "Deprecated: Aerial float.row and float.col are no longer used. Use float.override to customize layout",
      vim.log.levels.WARN
    )
  end

  for k, v in pairs(newconf) do
    M[k] = v
  end
  M.backends = create_filetype_opt_getter(M.backends, default_options.backends)
  local get_filter_kind_list =
    create_filetype_opt_getter(M.filter_kind, default_options.filter_kind)
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
end

local function get_icon(kind, filetypes)
  for _, ft in ipairs(filetypes) do
    local icon_map = M.icons[ft]
    local icon = icon_map and icon_map[kind]
    if icon then
      return icon
    end
  end
  return M.icons[kind]
end

M.get_icon = function(bufnr, kind, collapsed)
  if collapsed then
    kind = kind .. "Collapsed"
  end
  local icon
  -- Slight optimization for users that don't specify icons
  if not vim.tbl_isempty(M.icons) then
    local filetypes = M.get_filetypes(bufnr)
    table.insert(filetypes, "_")
    icon = get_icon(kind, filetypes)
    if not icon and collapsed then
      icon = get_icon("Collapsed", filetypes)
    end
    if icon then
      return icon
    end
  end

  if HAS_LSPKIND and M.use_lspkind and not collapsed then
    icon = lspkind.symbolic(kind, { with_text = false })
    if icon and icon ~= "" then
      return icon
    end
  end
  icon = M.default_icons[kind]
  if not icon and collapsed then
    icon = M.default_icons.Collapsed
  end
  return icon or " "
end

return M
