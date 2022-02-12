(function_definition
  name: (name) @name) @type

(expression_statement
  (assignment_expression
    left: (variable_name) @name
    right: (anonymous_function_creation_expression) @type
  )) @start

(class_declaration
  name: (name) @name) @type

(method_declaration
  name: (name) @name) @type

(interface_declaration
  name: (name) @name) @type

(trait_declaration
  name: (name) @name) @type
