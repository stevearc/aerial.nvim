(function_definition
  declarator: (function_declarator
    declarator: [(identifier) (field_identifier) (qualified_identifier)] @name)) @type

(struct_specifier
  name: (type_identifier) @name
) @type

(declaration
  (struct_specifier) @type
  declarator: (identifier) @name)

(enum_specifier
  name: (type_identifier) @name) @type

(class_specifier
  name: (type_identifier) @name) @type
