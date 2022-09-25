(function_definition) @root @type

(struct_specifier
  name: (type_identifier) @name
  body: (field_declaration_list)
) @type

(declaration
  (struct_specifier
    body: (field_declaration_list)
    ) @type
  declarator: (identifier) @name)

(enum_specifier
  name: (type_identifier) @name) @type

(class_specifier
  name: (type_identifier) @name) @type
