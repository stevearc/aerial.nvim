local M = {}
local has_devicons = pcall(require, 'nvim-web-devicons')

local open_automatic = {
  ['_'] = false,
}

M.filter_kind = {
  Class       = true,
  Constructor = true,
  Enum        = true,
  Function    = true,
  Interface   = true,
  Method      = true,
  Struct      = true,
}

local icons = nil

local plain_icons = {
  Array         = '[arr]';
  Boolean       = '[bool]';
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
  Null          = '[null]';
  Number        = '[num]';
  Object        = '[obj]';
  Operator      = '[Op]';
  Package       = '[Pkg]';
  Property      = '[P]';
  String        = '[str]';
  Struct        = '[S]';
  TypeParameter = '[T]';
  Variable      = '[V]';
  Collapsed     = '▶';
}

local nerd_icons = {
  Class         = '';
  Constructor   = '';
  Enum          = '';
  Function      = '';
  Interface     = '';
  Method        = '';
  Struct        = '';
  Collapsed     = '';
}

M.get_highlight_on_jump = function()
  local value = vim.g.aerial_highlight_on_jump
  if value == nil then return true else return value end
end

M.get_update_when_errors = function()
  local val = vim.g.aerial_update_when_errors
  if val == nil then return true else return val end
end

M.set_open_automatic = function(ft_or_mapping, bool)
  if type(ft_or_mapping) == 'table' then
    open_automatic = ft_or_mapping
  else
    open_automatic[ft_or_mapping] = bool
  end
end

M.get_open_automatic = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, 'filetype')
  local ret = open_automatic[ft]
  return ret == nil and open_automatic['_'] or ret
end

M.get_default_direction = function()
  local dir = vim.g.aerial_default_direction
  return dir == nil and 'prefer_right' or dir
end

M.get_open_automatic_min_lines = function()
  local min_lines = vim.g.aerial_open_automatic_min_lines
  if min_lines == nil then return 0 else return min_lines end
end

M.get_open_automatic_min_symbols = function()
  local min_symbols = vim.g.aerial_open_automatic_min_symbols
  if min_symbols == nil then return 0 else return min_symbols end
end

M.get_diagnostics_trigger_update = function()
  local update = vim.g.aerial_diagnostics_trigger_update
  if update == nil then return true else return update end
end

M.get_highlight_mode = function()
  local mode = vim.g.aerial_highlight_mode
  if mode == nil then
    return 'split_width'
  elseif mode == 'last' or mode == 'full_width' or mode == 'split_width' then
    return mode
  end
  error("Unrecognized highlight mode '" .. mode .. "'")
  return 'split_width'
end

M.get_min_width = function()
  local width = vim.g.aerial_min_width
  if width == nil then return 10 else return width end
end

M.get_max_width = function()
  local width = vim.g.aerial_max_width
  if width == nil then return 40 else return width end
end

M.get_use_icons = function()
  local use_icons = vim.g.aerial_use_icons
  if use_icons == nil then return has_devicons else return use_icons end
end

local function get_icons()
  if not icons then
    if M.get_use_icons() then
      icons = vim.tbl_extend('keep', nerd_icons, plain_icons)
    else
      icons = plain_icons
    end
  end
  return icons
end

M.set_icon = function(kind_or_mapping, icon)
  if type(kind_or_mapping) == 'table' then
    icons = vim.tbl_extend('keep', kind_or_mapping, get_icons())
  else
    get_icons()[kind_or_mapping] = icon
  end
end

M.get_icon = function(kind, collapsed)
  local abbrs = get_icons()
  local abbr
  if collapsed then
    abbr = abbrs[kind .. 'Collapsed'] or abbrs['Collapsed']
  else
    abbr = abbrs[kind]
  end
  return abbr and abbr or kind
end

return M
