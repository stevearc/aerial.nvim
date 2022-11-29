(function_definition
  name: (name) @name
  (#set! "kind" "Function")
  ) @type

(expression_statement
  (assignment_expression
    left: (variable_name) @name
    right: (anonymous_function_creation_expression) @type
  )
  (#set! "kind" "Function")
  ) @start

(class_declaration
  name: (name) @name
  (#set! "kind" "Class")
  ) @type

(method_declaration
  name: (name) @name
  (#set! "kind" "Method")
  ) @type

(interface_declaration
  name: (name) @name
  (#set! "kind" "Interface")
  ) @type

(trait_declaration
  name: (name) @name
  (#set! "kind" "Class")
  ) @type
