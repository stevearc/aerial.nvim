(function_declaration
  name: (identifier) @name) @type

(type_declaration
  (type_spec
    name: (type_identifier) @name
    type: (struct_type) @type)) @start

(method_declaration
  name: (field_identifier) @name
) @type
