(local_function
  (identifier) @name) @type

(field
  (identifier) @name
  (function_definition) @type)

(function
  (function_name) @name) @type

(local_variable_declaration
  (variable_declarator
    (identifier) @name)
  (function_definition) @type)

(variable_declaration
  (variable_declarator) @name
  (function_definition) @type)

(function_definition) @type

(function_call
  (identifier) @method @name (#any-of? @method "describe" "it" "before_each" "after_each" "setup" "teardown")
  (arguments
    (string)? @name
    (function_definition) @type)
) @location
