(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @symbol

(class_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @symbol

(struct_declaration
  name: (identifier) @name
  (#set! "kind" "Struct")
  ) @symbol

(method_declaration
  name: (identifier) @name
  (#set! "kind" "Method")
  ) @symbol

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")
  ) @symbol

(constructor_declaration
  name: (identifier) @name
  (#set! "kind" "Constructor")
  ) @symbol

(property_declaration
  name: (identifier) @name
  (#set! "kind" "Property")
  ) @symbol

(field_declaration
   (variable_declaration
    (variable_declarator
       (identifier) @name))
  (#set! "kind" "Field")
   ) @symbol
