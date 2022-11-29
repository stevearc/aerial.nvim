(function_signature
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(interface_declaration
  name: (type_identifier) @name
  (#set! "kind" "Interface")
  ) @type

(class_declaration
  name: (type_identifier) @name
  (#set! "kind" "Class")
  ) @type

(method_definition
  name: (property_identifier) @name
  (#set! "kind" "Method")
  ) @type

(type_alias_declaration
  name: (type_identifier) @name
  (#set! "kind" "Type")
  ) @type

(lexical_declaration
  (variable_declarator
    name: (identifier) @name
    value: (_) @var_type) @type
  (#set! "kind" "Variable")
  ) @start
