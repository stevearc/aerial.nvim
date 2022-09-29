(interface_declaration
  name: (identifier) @name) @type

(class_declaration
  name: (identifier) @name) @type

(struct_declaration
  name: (identifier) @name) @type

(method_declaration
  name: (identifier) @name) @type

(enum_declaration
  name: (identifier) @name) @type

(constructor_declaration
  name: (identifier) @name) @type

(property_declaration
  name: (identifier) @name) @type

(field_declaration
   (variable_declaration
    (variable_declarator
       (identifier) @name))) @type
