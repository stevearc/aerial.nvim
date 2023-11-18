local config = require("aerial.config")
local M = {}

---@param group1 string
---@param group2 string
local function link(group1, group2)
  vim.api.nvim_set_hl(0, group1, { link = group2, default = true })
end

local symbol_kinds = {
  "Array",
  "Boolean",
  "Class",
  "Constant",
  "Constructor",
  "Enum",
  "EnumMember",
  "Event",
  "Field",
  "File",
  "Function",
  "Interface",
  "Key",
  "Method",
  "Module",
  "Namespace",
  "Null",
  "Number",
  "Object",
  "Operator",
  "Package",
  "Property",
  "String",
  "Struct",
  "TypeParameter",
  "Variable",
}

---@param symbol aerial.Symbol
---@param is_icon boolean
---@param is_collapsed boolean
---@return nil|string
M.get_highlight = function(symbol, is_icon, is_collapsed)
  local hl_group = config.get_highlight(symbol, is_icon, is_collapsed)
  if hl_group then
    return hl_group
  end

  -- If the symbol has a non-public scope, use that as the highlight group (e.g. AerialPrivate)
  if symbol.scope and not is_icon and symbol.scope ~= "public" then
    return string.format("Aerial%s", symbol.scope:gsub("^%l", string.upper))
  end

  return string.format("Aerial%s%s", symbol.kind, is_icon and "Icon" or "")
end

local get_hl_by_name
if vim.fn.has("nvim-0.9") == 1 then
  get_hl_by_name = function(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
  end
else
  get_hl_by_name = function(name)
    ---@diagnostic disable-next-line undefined-field
    local result = vim.api.nvim_get_hl_by_name(name, true)
    result.fg = result.foreground
    result.bg = result.background
    return result
  end
end

M.create_highlight_groups = function()
  -- Use Normal colors for AerialNormal, while stripping bold/italic/etc
  local normal_defn = get_hl_by_name("Normal")
  -- The default text highlight
  vim.api.nvim_set_hl(0, "AerialNormal", {
    fg = normal_defn.fg,
    ctermfg = normal_defn.ctermfg,
    blend = normal_defn.blend,
    default = true,
  })

  -- Set another group for NormalFloat, for use in the nav view
  local normal_float_defn = get_hl_by_name("NormalFloat")
  -- Don't set the background for the float so that it blends nicely with the cursorline
  vim.api.nvim_set_hl(0, "AerialNormalFloat", {
    fg = normal_float_defn.fg,
    ctermfg = normal_float_defn.ctermfg,
    blend = normal_float_defn.blend,
    default = true,
  })

  -- The line that shows where your cursor(s) are
  link("AerialLine", "QuickFixLine")
  link("AerialLineNC", "AerialLine")

  -- Highlight groups for private and protected functions/fields/etc
  link("AerialPrivate", "Comment")
  link("AerialProtected", "Comment")

  -- Use Comment colors for AerialGuide, while stripping bold/italic/etc
  local comment_defn = get_hl_by_name("Comment")
  -- The guides when show_guide = true
  vim.api.nvim_set_hl(0, "AerialGuide", {
    fg = comment_defn.fg,
    ctermfg = comment_defn.ctermfg,
    blend = comment_defn.blend,
    default = true,
  })
  for i = 1, 9 do
    link(string.format("AerialGuide%d", i), "AerialGuide")
  end

  -- The name of the symbol
  for _, symbol_kind in ipairs(symbol_kinds) do
    link(string.format("Aerial%s", symbol_kind), "AerialNormal")
  end

  -- The icon displayed to the left of the symbol
  link("AerialArrayIcon", "Identifier")
  link("AerialBooleanIcon", "Identifier")
  link("AerialClassIcon", "Type")
  link("AerialConstantIcon", "Constant")
  link("AerialConstructorIcon", "Special")
  link("AerialEnumIcon", "Type")
  link("AerialEnumMemberIcon", "Identifier")
  link("AerialEventIcon", "Identifier")
  link("AerialFieldIcon", "Identifier")
  link("AerialFileIcon", "Identifier")
  link("AerialFunctionIcon", "Function")
  link("AerialInterfaceIcon", "Type")
  link("AerialKeyIcon", "Identifier")
  link("AerialMethodIcon", "Function")
  link("AerialModuleIcon", "Include")
  link("AerialNamespaceIcon", "Include")
  link("AerialNullIcon", "Identifier")
  link("AerialNumberIcon", "Identifier")
  link("AerialObjectIcon", "Identifier")
  link("AerialOperatorIcon", "Identifier")
  link("AerialPackageIcon", "Include")
  link("AerialPropertyIcon", "Identifier")
  link("AerialStringIcon", "Identifier")
  link("AerialStructIcon", "Type")
  link("AerialTypeParameterIcon", "Identifier")
  link("AerialVariableIcon", "Identifier")
end

return M
