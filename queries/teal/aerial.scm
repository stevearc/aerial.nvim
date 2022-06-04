(function_statement
  name: [(identifier)] @name) @type

(var_declaration
  (var_declarators
    (var
      name: (identifier) @name))
  (expressions
    (anon_function) @type)) @start

(var_assignment
    (assignment_variables
      (var
        (index
          (identifier)
          (identifier) @name)))
    (expressions
      (anon_function) @type)) @start

(function_statement
    name: (function_name) @name) @type
