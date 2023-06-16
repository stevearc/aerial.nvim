(module_definition
  name: (identifier) @name
  (#set! "kind" "Module")
  ) @type

(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(function_definition
  name: (field_expression
          value: (_)
          (identifier) @name)
  (#set! "kind" "Function")
  ) @type

(short_function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(short_function_definition
  name: (field_expression
          value: (_)
          (identifier) @name)
  (#set! "kind" "Function")
  ) @type

(abstract_definition
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @type

(struct_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(const_declaration
  (assignment
    . (identifier) @name)
  (#set! "kind" "Constant")
  ) @type

(macro_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type
