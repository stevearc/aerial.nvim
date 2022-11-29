(function_definition
  (#set! "kind" "Function")
  ) @root @type

(struct_specifier
  name: (type_identifier) @name
  body: (field_declaration_list)
  (#set! "kind" "Struct")
) @type

(declaration
  (struct_specifier
    body: (field_declaration_list)
    ) @type
  declarator: (identifier) @name
  (#set! "kind" "Struct")
  )

(enum_specifier
  name: (type_identifier) @name
  (#set! "kind" "Enum")
  ) @type

(class_specifier
  name: (type_identifier) @name
  (#set! "kind" "Class")
  ) @type
