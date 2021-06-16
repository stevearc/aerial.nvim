local M = {}
local has_devicons = pcall(require, 'nvim-web-devicons')

M.open_automatic = {
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

local _kind_abbr = nil

local default_abbr = {
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
}

local icons_abbr = {
  Class         = '';
  Constructor   = '';
  Enum          = '';
  Function      = '';
  Interface     = '';
  Method        = '';
  Struct        = '';
}

M.get_highlight_on_jump = function()
  local value = vim.g.aerial_highlight_on_jump
  if value == nil then return true else return value end
end

M.get_update_when_errors = function()
  local val = vim.g.aerial_update_when_errors
  if val == nil then return true else return val end
end

M.get_open_automatic = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, 'filetype')
  local ret = M.open_automatic[ft]
  if ret == nil then
    return M.open_automatic['_']
  end
  return ret
end

M.get_open_automatic_min_lines = function()
  local min_lines = vim.g.aerial_open_automatic_min_lines
  if min_lines == nil then return 0 else return min_lines end
end

M.get_open_automatic_min_symbols = function()
  local min_symbols = vim.g.aerial_open_automatic_min_symbols
  if min_symbols == nil then return 0 else return min_symbols end
end

M.get_automatic_direction = function()
  return vim.g.aerial_automatic_direction
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

M.get_highlight_group = function()
  local hl = vim.g.aerial_highlight_group
  if hl == nil then return 'QuickFixLine' else return hl end
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

local function get_kind_abbr()
  if not _kind_abbr then
    if M.get_use_icons() then
      _kind_abbr = vim.tbl_extend('keep', icons_abbr, default_abbr)
    else
      _kind_abbr = default_abbr
    end
  end
  return _kind_abbr
end

M.set_kind_abbr = function(kind_or_mapping, abbr)
  if type(kind_or_mapping) == 'table' then
    _kind_abbr = vim.tbl_extend('keep', kind_or_mapping, get_kind_abbr())
  else
    local kind_abbr = get_kind_abbr()
    kind_abbr[kind_or_mapping] = abbr
    _kind_abbr = kind_abbr
  end
end

M.get_kind_abbr = function(kind)
  local abbr = get_kind_abbr()[kind]
  return abbr and abbr or kind
end

return M
