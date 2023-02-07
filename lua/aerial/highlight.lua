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

  -- Use Comment colors for AerialGuide, while stripping bold/italic/etc
  local comment_defn = vim.api.nvim_get_hl_by_name("Comment", true)
  -- The guides when show_guide = true
  vim.api.nvim_set_hl(0, "AerialGuide", {
    fg = comment_defn.foreground,
    bg = comment_defn.background,
    ctermfg = comment_defn.ctermfg,
    ctermbg = comment_defn.ctermbg,
    blend = comment_defn.blend,
    default = true,
  })
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
  link("AerialColorIcon", "Identifier")
  link("AerialConstantIcon", "Constant")
  link("AerialConstructorIcon", "Special")
  link("AerialEnumIcon", "Type")
  link("AerialEnumMemberIcon", "Identifier")
  link("AerialEventIcon", "Identifier")
  link("AerialFieldIcon", "Identifier")
  link("AerialFileIcon", "Identifier")
  link("AerialFolderIcon", "Identifier")
  link("AerialFunctionIcon", "Function")
  link("AerialInterfaceIcon", "Type")
  link("AerialKeyIcon", "Identifier")
  link("AerialKeywordIcon", "Identifier")
  link("AerialMethodIcon", "Function")
  link("AerialModuleIcon", "Include")
  link("AerialNamespaceIcon", "Include")
  link("AerialNullIcon", "Identifier")
  link("AerialNumberIcon", "Identifier")
  link("AerialObjectIcon", "Identifier")
  link("AerialOperatorIcon", "Identifier")
  link("AerialPackageIcon", "Include")
  link("AerialPropertyIcon", "Identifier")
  link("AerialReferenceIcon", "Identifier")
  link("AerialSnippetIcon", "Identifier")
  link("AerialStringIcon", "Identifier")
  link("AerialStructIcon", "Type")
  link("AerialTextIcon", "Identifier")
  link("AerialTypeParameterIcon", "Identifier")
  link("AerialUnitIcon", "Identifier")
  link("AerialValueIcon", "Identifier")
  link("AerialVariableIcon", "Identifier")
end

M.identifiers = {
  "Array",
  "Boolean",
  "Class",
  "Color",
  "Constant",
  "Constructor",
  "Enum",
  "EnumMember",
  "Event",
  "Field",
  "File",
  "Folder",
  "Function",
  "Interface",
  "Key",
  "Keyword",
  "Method",
  "Module",
  "Namespace",
  "Null",
  "Number",
  "Object",
  "Operator",
  "Package",
  "Property",
  "Reference",
  "Snippet",
  "String",
  "Struct",
  "Text",
  "TypeParameter",
  "Unit",
  "Value",
  "Variable",
}

return M
