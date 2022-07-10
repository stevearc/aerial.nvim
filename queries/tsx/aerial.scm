(function_signature
  name: (identifier) @name) @type

(function_declaration
  name: (identifier) @name) @type

(interface_declaration
  name: (type_identifier) @name) @type

(class_declaration
  name: (type_identifier) @name) @type

(method_definition
  name: (property_identifier) @name) @type

(type_alias_declaration
  name: (type_identifier) @name) @type

(lexical_declaration
  (variable_declarator
    name: (identifier) @name
    value: (_) @var_type) @type) @start
