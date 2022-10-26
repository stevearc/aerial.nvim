local M = {}

---@param group1 string
---@param group2 string
local function link(group1, group2)
  vim.api.nvim_set_hl(0, group1, { link = group2, default = true })
end

M.create_highlight_groups = function()
  -- The line that shows where your cursor(s) are
  link("AerialLine", "QuickFixLine")
  link("AerialLineNC", "AerialLine")

  -- The guides when show_guide = true
  link("AerialGuide", "Comment")
  for i = 1, 9 do
    link(string.format("AerialGuide%d", i), "AerialGuide")
  end

  -- The name of the symbol
  for _, symbol_kind in ipairs(M.identifiers) do
    link(string.format("Aerial%s", symbol_kind), "NONE")
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

M.identifiers = {
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

return M
