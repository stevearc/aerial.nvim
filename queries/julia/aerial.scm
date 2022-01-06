(module_definition
  name: (identifier) @name) @type

(function_definition
  name: (identifier) @name) @type

(assignment_expression
  . (call_expression
    (identifier) @name) @type) @location

(abstract_definition
  name: (identifier) @name) @type

(struct_definition
  name: (identifier) @name) @type

(const_statement
  (variable_declaration
    . (identifier) @name)) @type
