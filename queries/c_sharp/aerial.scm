(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @type

(class_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(struct_declaration
  name: (identifier) @name
  (#set! "kind" "Struct")
  ) @type

(method_declaration
  name: (identifier) @name
  (#set! "kind" "Method")
  ) @type

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")
  ) @type

(constructor_declaration
  name: (identifier) @name
  (#set! "kind" "Constructor")
  ) @type

(property_declaration
  name: (identifier) @name
  (#set! "kind" "Property")
  ) @type

(field_declaration
   (variable_declaration
    (variable_declarator
       (identifier) @name))
  (#set! "kind" "Field")
   ) @type
