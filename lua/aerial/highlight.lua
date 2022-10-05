local M = {}

M.create_highlight_groups = function()
  vim.cmd([[
    " The line that shows where your cursor(s) are
    highlight default link AerialLine   QuickFixLine
    highlight default link AerialLineNC AerialLine

    " The guides when show_guide = true
    highlight default link AerialGuide Comment
    highlight default link AerialGuide1 AerialGuide
    highlight default link AerialGuide2 AerialGuide
    highlight default link AerialGuide3 AerialGuide
    highlight default link AerialGuide4 AerialGuide
    highlight default link AerialGuide5 AerialGuide
    highlight default link AerialGuide6 AerialGuide
    highlight default link AerialGuide7 AerialGuide
    highlight default link AerialGuide8 AerialGuide
    highlight default link AerialGuide9 AerialGuide

    " The icon displayed to the left of the symbol
    highlight default link AerialArrayIcon         Identifier
    highlight default link AerialBooleanIcon       Identifier
    highlight default link AerialClassIcon         Type
    highlight default link AerialConstantIcon      Constant
    highlight default link AerialConstructorIcon   Special
    highlight default link AerialEnumIcon          Type
    highlight default link AerialEnumMemberIcon    Identifier
    highlight default link AerialEventIcon         Identifier
    highlight default link AerialFieldIcon         Identifier
    highlight default link AerialFileIcon          Identifier
    highlight default link AerialFunctionIcon      Function
    highlight default link AerialInterfaceIcon     Type
    highlight default link AerialKeyIcon           Identifier
    highlight default link AerialMethodIcon        Function
    highlight default link AerialModuleIcon        Include
    highlight default link AerialNamespaceIcon     Include
    highlight default link AerialNullIcon          Identifier
    highlight default link AerialNumberIcon        Identifier
    highlight default link AerialObjectIcon        Identifier
    highlight default link AerialOperatorIcon      Identifier
    highlight default link AerialPackageIcon       Include
    highlight default link AerialPropertyIcon      Identifier
    highlight default link AerialStringIcon        Identifier
    highlight default link AerialStructIcon        Type
    highlight default link AerialTypeParameterIcon Identifier
    highlight default link AerialVariableIcon      Identifier

    " The name of the symbol
    highlight default link AerialArray         NONE
    highlight default link AerialBoolean       NONE
    highlight default link AerialClass         NONE
    highlight default link AerialConstant      NONE
    highlight default link AerialConstructor   NONE
    highlight default link AerialEnum          NONE
    highlight default link AerialEnumMember    NONE
    highlight default link AerialEvent         NONE
    highlight default link AerialField         NONE
    highlight default link AerialFile          NONE
    highlight default link AerialFunction      NONE
    highlight default link AerialInterface     NONE
    highlight default link AerialKey           NONE
    highlight default link AerialMethod        NONE
    highlight default link AerialModule        NONE
    highlight default link AerialNamespace     NONE
    highlight default link AerialNull          NONE
    highlight default link AerialNumber        NONE
    highlight default link AerialObject        NONE
    highlight default link AerialOperator      NONE
    highlight default link AerialPackage       NONE
    highlight default link AerialProperty      NONE
    highlight default link AerialString        NONE
    highlight default link AerialStruct        NONE
    highlight default link AerialTypeParameter NONE
    highlight default link AerialVariable      NONE


    " The icon displayed to the left of the symbol in lualine
    highlight default link LuaLineAerialArrayIcon AerialArrayIcon
    highlight default link LuaLineAerialBooleanIcon AerialBooleanIcon
    highlight default link LuaLineAerialClassIcon AerialClassIcon
    highlight default link LuaLineAerialConstantIcon AerialConstantIcon
    highlight default link LuaLineAerialConstructorIcon AerialConstructorIcon
    highlight default link LuaLineAerialEnumIcon AerialEnumIcon
    highlight default link LuaLineAerialEnumMemberIcon AerialEnumMemberIcon
    highlight default link LuaLineAerialEventIcon AerialEventIcon
    highlight default link LuaLineAerialFieldIcon AerialFieldIcon
    highlight default link LuaLineAerialFileIcon AerialFileIcon
    highlight default link LuaLineAerialFunctionIcon AerialFunctionIcon
    highlight default link LuaLineAerialInterfaceIcon AerialInterfaceIcon
    highlight default link LuaLineAerialKeyIcon AerialKeyIcon
    highlight default link LuaLineAerialMethodIcon AerialMethodIcon
    highlight default link LuaLineAerialModuleIcon AerialModuleIcon
    highlight default link LuaLineAerialNamespaceIcon AerialNamespaceIcon
    highlight default link LuaLineAerialNullIcon AerialNullIcon
    highlight default link LuaLineAerialNumberIcon AerialNumberIcon
    highlight default link LuaLineAerialObjectIcon AerialObjectIcon
    highlight default link LuaLineAerialOperatorIcon AerialOperatorIcon
    highlight default link LuaLineAerialPackageIcon AerialPackageIcon
    highlight default link LuaLineAerialPropertyIcon AerialPropertyIcon
    highlight default link LuaLineAerialStringIcon AerialStringIcon
    highlight default link LuaLineAerialStructIcon AerialStructIcon
    highlight default link LuaLineAerialTypeParameterIcon AerialTypeParameterIcon
    highlight default link LuaLineAerialVariableIcon AerialVariableIcon

    " The name of the symbol in lualine
    highlight default link LuaLineAerialArray AerialArray
    highlight default link LuaLineAerialBoolean AerialBoolean
    highlight default link LuaLineAerialClass AerialClass
    highlight default link LuaLineAerialConstant AerialConstant
    highlight default link LuaLineAerialConstructor AerialConstructor
    highlight default link LuaLineAerialEnum AerialEnum
    highlight default link LuaLineAerialEnumMember AerialEnumMember
    highlight default link LuaLineAerialEvent AerialEvent
    highlight default link LuaLineAerialField AerialField
    highlight default link LuaLineAerialFile AerialFile
    highlight default link LuaLineAerialFunction AerialFunction
    highlight default link LuaLineAerialInterface AerialInterface
    highlight default link LuaLineAerialKey AerialKey
    highlight default link LuaLineAerialMethod AerialMethod
    highlight default link LuaLineAerialModule AerialModule
    highlight default link LuaLineAerialNamespace AerialNamespace
    highlight default link LuaLineAerialNull AerialNull
    highlight default link LuaLineAerialNumber AerialNumber
    highlight default link LuaLineAerialObject AerialObject
    highlight default link LuaLineAerialOperator AerialOperator
    highlight default link LuaLineAerialPackage AerialPackage
    highlight default link LuaLineAerialProperty AerialProperty
    highlight default link LuaLineAerialString AerialString
    highlight default link LuaLineAerialStruct AerialStruct
    highlight default link LuaLineAerialTypeParameter AerialTypeParameter
    highlight default link LuaLineAerialVariable AerialVariable
  ]])
end

return M
