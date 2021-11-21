(type_definition
  type: [(enum_specifier) (struct_specifier)] @type
  declarator: (type_identifier) @name) @location

(_
  declarator: (pointer_declarator
    declarator: (function_declarator
      declarator: (identifier) @name) @type)
) @location

(_
  declarator: (function_declarator
    declarator: (identifier) @name) @type
) @location
