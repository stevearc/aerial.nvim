(module_definition
  name: (identifier) @name
  (#set! "kind" "Module")) @symbol

(function_definition
  (signature
    (call_expression) @name)
  (#set! "kind" "Function")) @symbol

(assignment
  .
  (where_expression
    (call_expression) @name)
  (#set! "kind" "Function")) @symbol

(assignment
  .
  (call_expression) @name
  (#set! "kind" "Function")) @symbol

(abstract_definition
  (type_head
    (identifier) @name
    (#set! "kind" "Interface"))) @symbol

(struct_definition
  (type_head
    [
      (_
        (identifier) @name)
      (identifier) @name
    ]
    (#set! "kind" "Class"))) @symbol

(const_statement
  (assignment
    .
    (identifier) @name)
  (#set! "kind" "Constant")) @symbol

(macro_definition
  (signature
    (call_expression) @name)
  (#set! "kind" "Function")) @symbol
