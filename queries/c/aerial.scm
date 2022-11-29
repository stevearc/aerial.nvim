(type_definition
  type: (enum_specifier) @type
  declarator: (type_identifier) @name
  (#set! "kind" "Enum")
  ) @start

(type_definition
  type: (struct_specifier) @type
  declarator: (type_identifier) @name
  (#set! "kind" "Struct")
  ) @start

(
  (declaration) @root @start
  .
  (function_definition) @type @end
  (#set! "kind" "Function")
)

(function_definition
  (#set! "kind" "Function")
  ) @type @root
