(interface_declaration
  name: (identifier) @name) @type

(method_declaration
  name: (identifier) @name) @type

(class_declaration
  name: (identifier) @name) @type

(enum_declaration
  name: (identifier) @name) @type

(field_declaration
  type: [(integral_type) (type_identifier) (boolean_type)] @java_type
  declarator: (variable_declarator
    name: (identifier) @name)) @type

