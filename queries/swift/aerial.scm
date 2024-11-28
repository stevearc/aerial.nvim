(protocol_declaration
  name: _ @name
  (#set! "kind" "Interface")) @symbol

(class_declaration
  "enum"
  .
  name: _ * @name
  (#set! "kind" "Enum")) @symbol

(class_declaration
  "struct"
  .
  name: _ * @name
  (#set! "kind" "Struct")) @symbol

(class_declaration
  name: _ * @name
  (#set! "kind" "Class")) @symbol

(init_declaration
  name: "init" @name
  (#set! "kind" "Constructor")) @symbol

(deinit_declaration
  "deinit" @name
  (#set! "kind" "Constructor")) @symbol

(enum_class_body
  (function_declaration
    name: _ @name
    (#set! "kind" "Method")) @symbol)

(class_body
  (function_declaration
    name: _ @name
    (#set! "kind" "Method")) @symbol)

(enum_class_body
  (property_declaration
    name: _ @name
    computed_value: _
    (#set! "kind" "Method")) @symbol)

(class_body
  (property_declaration
    name: _ @name
    computed_value: _
    (#set! "kind" "Method")) @symbol)

(enum_class_body
  (property_declaration
    name: _ @name
    !computed_value
    (#set! "kind" "Property")) @symbol)

(class_body
  (property_declaration
    name: _ @name
    !computed_value
    (#set! "kind" "Property")) @symbol)

(property_declaration
  name: _ @name
  computed_value: _
  (#set! "kind" "Function")) @symbol

(property_declaration
  name: _ @name
  !computed_value
  (#set! "kind" "Variable")) @symbol


(protocol_function_declaration
  name: _ @name
  (#set! "kind" "Method")) @symbol

(protocol_property_declaration
  name: (pattern
          bound_identifier: _ @name)
  (#set! "kind" "Property")) @symbol

(function_declaration
  name: _ @name
  (#set! "kind" "Function")) @symbol

