(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")) @symbol

(method_declaration
  name: (identifier) @name @start
  (#set! "kind" "Method")) @symbol

(constructor_declaration
  name: (identifier) @name
  (#set! "kind" "Constructor")) @symbol

(class_declaration
  name: (identifier) @name
  (#set! "kind" "Class")) @symbol

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")) @symbol

(field_declaration
  declarator: (variable_declarator
    name: (identifier) @name)
  (#set! "kind" "Field")) @symbol
