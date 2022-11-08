(module_definition
  name: (identifier) @name) @type

(function_definition
  name: (identifier) @name) @type

(short_function_definition
  name: (identifier) @name) @type

(abstract_definition
  name: (identifier) @name) @type

(struct_definition
  name: (identifier) @name) @type

(const_statement
  (variable_declaration
    . (identifier) @name)) @type

(macro_definition
  name: (identifier) @name) @type
