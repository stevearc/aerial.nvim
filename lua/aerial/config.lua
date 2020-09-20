local M = {}

M.open_automatic = {
  ['_'] = false,
}

M.filter_kind = {
  ['Function'] = true,
  ['Class'] = true,
  ['Constructor'] = true,
  ['Method'] = true,
  ['Struct'] = true,
  ['Enum'] = true,
}

M.kind_abbr = {
  File = 'File';
  Module = 'Mod';
  Namespace = 'NS';
  Package = 'Pkg';
  Class = 'C';
  Method = 'M';
  Property = 'P';
  Field = 'Fld';
  Constructor = 'Co';
  Enum = 'E';
  Interface = 'I';
  Function = 'F';
  Variable = 'V';
  Constant = 'const';
  String = 'str';
  Number = 'num';
  Boolean = 'bool';
  Array = 'arr';
  Object = 'obj';
  Key = 'K';
  Null = 'null';
  EnumMember = 'em';
  Struct = 'S';
  Event = 'Ev';
  Operator = 'Op';
  TypeParameter = 'T';
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

M.get_width = function()
  local width = vim.g.aerial_width
  if width == nil then return 40 else return width end
end

M.get_kind_abbr = function(kind)
  abbr = M.kind_abbr[kind]
  if abbr == nil then
    return kind
  end
  return abbr
end

return M
