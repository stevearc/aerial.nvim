; enums
(decl_enum
  typename: (identifier) @name
  (#set! "kind" "Enum")) @symbol

(enum_member
  name: (identifier) @name
  (#set! "kind" "EnumMember")) @symbol

; class
(decl_class
  typename: (identifier) @name
  (#set! "kind" "Class")) @symbol

(typedef
  alias: (identifier) @name
  (#set! "kind" "Class")) @symbol

; constructor
(decl_class
  typename: (identifier) @_typename
  body: (class_body
    (decl_method
      name: (identifier) @name
      (#eq? @name @_typename)
      (#set! "kind" "Constructor")) @symbol))

; field
(decl_field
  ((field_modifier) @_modifier
    (#eq? @_modifier "const"))
  type: (_)
  name: (identifier) @name
  (#set! "kind" "Constant")) @symbol

(decl_field
  type: (_)
  name: (identifier) @name
  (#set! "kind" "Field")) @symbol

; methods
(decl_method
  name: (identifier) @name
  (#set! "kind" "Method")) @symbol
