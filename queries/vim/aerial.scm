(function_definition
  (function_declaration
    name: [
      (identifier)
      (scoped_identifier)
    ] @name)
  (#set! "kind" "Function")) @symbol

(function_definition
  (function_declaration
    name: (field_expression) @name)
  (#set! "kind" "Function")) @symbol
