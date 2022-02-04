(type_definition
  type: [(enum_specifier) (struct_specifier)] @type
  declarator: (type_identifier) @name) @start

(
  (declaration) @root @start
  .
  (function_definition) @type @end
)

(function_definition) @type @root
