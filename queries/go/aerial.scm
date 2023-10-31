(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol

(type_declaration
  (type_spec
    name: (type_identifier) @name
    type: (struct_type) @symbol)
  (#set! "kind" "Struct")
  ) @start

(type_declaration
  (type_spec
    name: (type_identifier) @name
    type: (interface_type) @symbol)
  (#set! "kind" "Interface")
  ) @start

(method_declaration
  receiver: (_) @receiver
  name: (field_identifier) @name
  (#set! "kind" "Method")
  ) @symbol
