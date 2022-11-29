(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @type

(method_declaration
  name: (identifier) @name
  (#set! "kind" "Method")
  ) @type

(class_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")
  ) @type

(field_declaration
  declarator: (variable_declarator
    name: (identifier) @name)
  (#set! "kind" "Field")
  ) @type
