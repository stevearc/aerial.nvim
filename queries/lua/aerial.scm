(function_declaration
  name: (identifier) @name) @type

(variable_declaration
  (assignment_statement
    (variable_list
      name: [(identifier) (dot_index_expression)] @name)
    (expression_list
      value: (function_definition) @type))) @location

(assignment_statement
  (variable_list
    name: [(identifier) (dot_index_expression)] @name)
  (expression_list
    value: (function_definition) @type)) @location

(field
  name: (identifier) @name
  value: (function_definition) @type) @location

(function_call
  name: (identifier) @method @name (#any-of? @method "describe" "it" "before_each" "after_each" "setup" "teardown")
  arguments: (arguments
    (string)? @name
    (function_definition) @type)
) @location

(function_definition) @type
