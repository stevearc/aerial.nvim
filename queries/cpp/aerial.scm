(namespace_definition
  name: (namespace_identifier) @name
  body: (declaration_list) @symbol
  (#set! "kind" "Namespace"))

; Nested namespace definition (since C++17)
(namespace_definition
  name: (nested_namespace_specifier) @name
  body: (declaration_list) @symbol
  (#set! "kind" "Namespace"))

; Namespace alias
(namespace_alias_definition
  name: (namespace_identifier) @name
  (#set! "kind" "Namespace")) @symbol

; Anonymous namespace
(namespace_definition
  body: (declaration_list) @symbol
  (#set! "kind" "Namespace"))

(struct_specifier
  name: (type_identifier) @name
  body: (field_declaration_list)
  (#set! "kind" "Struct")) @symbol

(declaration
  (struct_specifier
    body: (field_declaration_list)) @symbol
  declarator: (identifier) @name
  (#set! "kind" "Struct"))

(function_declarator
  declarator: (_) @name
  (#set! "kind" "Function")) @symbol

(enum_specifier
  name: (type_identifier) @name
  (#set! "kind" "Enum")) @symbol

(class_specifier
  name: (type_identifier) @name
  (#set! "kind" "Class")) @symbol
