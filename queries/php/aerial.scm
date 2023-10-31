(function_definition
  name: (name) @name
  (#set! "kind" "Function")
  ) @symbol

(expression_statement
  (assignment_expression
    left: (variable_name) @name
    right: (anonymous_function_creation_expression) @symbol
  )
  (#set! "kind" "Function")
  ) @start

(class_declaration
  name: (name) @name
  (#set! "kind" "Class")
  ) @symbol

(method_declaration
  name: (name) @name
  (#set! "kind" "Method")
  ) @symbol

(interface_declaration
  name: (name) @name
  (#set! "kind" "Interface")
  ) @symbol

(trait_declaration
  name: (name) @name
  (#set! "kind" "Class")
  ) @symbol
