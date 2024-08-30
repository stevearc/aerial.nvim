(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")) @symbol

(variable_declaration
  (identifier) @name
  (struct_declaration)
  (#set! "kind" "Struct")) @symbol

(variable_declaration
  (identifier) @name
  (union_declaration)
  (#set! "kind" "Struct")) @symbol

(test_declaration
  (string
    (string_content) @name)
  (#set! "kind" "Function")) @symbol

(test_declaration
  (identifier) @name
  (#set! "kind" "Function")) @symbol
