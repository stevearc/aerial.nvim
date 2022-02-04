(function_definition) @root @type

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
