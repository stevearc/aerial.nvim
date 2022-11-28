(mod_item
  name: (identifier) @name
  (#set! "kind" "Module")
  ) @type

(enum_item
  name: (type_identifier) @name
  (#set! "kind" "Enum")
  ) @type

(struct_item
  name: (type_identifier) @name
  (#set! "kind" "Struct")
  ) @type

(function_item
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(function_signature_item
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(trait_item
  name: (type_identifier) @name
  (#set! "kind" "Interface")
  ) @type

(impl_item
  trait: (type_identifier)? @trait
  type: (type_identifier) @rust_type
  (#set! "kind" "Class")
  ) @type

(impl_item
  trait: (type_identifier)? @trait
  type: (generic_type
    type: (type_identifier) @rust_type)
  (#set! "kind" "Class")
  ) @type
