(mod_item
  name: (identifier) @name) @type

(enum_item
  name: (type_identifier) @name) @type

(struct_item
  name: (type_identifier) @name) @type

(function_item
  name: (identifier) @name) @type

(function_signature_item
  name: (identifier) @name) @type

(trait_item
  name: (type_identifier) @name) @type

(impl_item
  trait: (type_identifier)? @trait
  type: (type_identifier) @rust_type) @type

(impl_item
  trait: (type_identifier)? @trait
  type: (generic_type
    type: (type_identifier) @rust_type)) @type
