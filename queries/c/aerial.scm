(type_definition
  type: (enum_specifier) @symbol
  declarator: (type_identifier) @name
  (#set! "kind" "Enum")
  ) @start

(type_definition
  type: (struct_specifier) @symbol
  declarator: (type_identifier) @name
  (#set! "kind" "Struct")
  ) @start

(
  (declaration) @root @start
  .
  (function_definition) @symbol @end
  (#set! "kind" "Function")
)

(function_definition
  (#set! "kind" "Function")
  ) @symbol @root
