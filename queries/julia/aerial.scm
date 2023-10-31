(module_definition
  name: (identifier) @name
  (#set! "kind" "Module")
  ) @symbol

(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol

(function_definition
  name: (field_expression
          value: (_)
          (identifier)) @name
  (#set! "kind" "Function")
  ) @symbol

(short_function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol

(short_function_definition
  name: (field_expression
          value: (_)
          (identifier)) @name
  (#set! "kind" "Function")
  ) @symbol

(abstract_definition
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @symbol

(struct_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @symbol

(const_statement
  (assignment
    . (identifier) @name)
  (#set! "kind" "Constant")
  ) @symbol

(macro_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol
