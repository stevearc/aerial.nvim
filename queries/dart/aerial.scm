(class_definition
  name: (identifier) @name) @type

(constructor_signature
  name: (identifier) @name) @type

(
  (method_signature
    [(function_signature
      name: (identifier) @name)
     (getter_signature
      name: (identifier) @name)
     (setter_signature
      name: (identifier) @name)
    ]
  ) @type
  .
  (function_body) @end
)

(
  (function_signature
    name: (identifier) @name) @type
  .
  (function_body) @end
)

(enum_declaration
  name: (identifier) @name) @type
