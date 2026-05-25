(component_instantiation_statement
  (label_declaration
    (label) @name)
  (#set! "kind" "Module")) @type

(entity_declaration
  entity: (identifier) @name
  (#set! "kind" "Module")) @type

(architecture_definition
  architecture: (identifier) @name
  entity: (name
            (identifier))
  (#set! "kind" "Module")) @type

(for_generate_statement
  (label_declaration
    (label) @name)
  (#set! "kind" "Namespace")) @type
