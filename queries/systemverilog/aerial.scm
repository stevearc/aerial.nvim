;--------------------------------------------------------------
; Module/Package etc
;--------------------------------------------------------------
(module_declaration
  (_
    (module_keyword)
    name: (simple_identifier) @name
      (#set! "kind" "Module"))) @type

(module_instantiation
  instance_type: (simple_identifier)
          (hierarchical_instance
            (name_of_instance)  @name
  (#set! "kind" "Module"))) @type

(interface_declaration
  (_
    name: (simple_identifier) @name
    (#set! "kind" "Module"))) @type

(package_declaration
  name: (simple_identifier) @name
  (#set! "kind" "Module")) @type

(clocking_declaration
  name: (simple_identifier) @name
  (#set! "kind" "Module")) @type

;--------------------------------------------------------------
; generate constructs
;--------------------------------------------------------------
(generate_block
  name: (simple_identifier) @name
  (#set! "kind" "Namespace")) @type

(generate_block
  !name
  (#set! "kind" "Namespace")) @type

;--------------------------------------------------------------
; Class/Property/Function etc
;--------------------------------------------------------------
(class_declaration
  name: (simple_identifier) @name
  (#set! "kind" "Class")) @type

(class_constructor_declaration
  (#set! "kind" "Constructor")
  "new" @name
  ) @type

(class_property
  (data_declaration
    (_)
    (list_of_variable_decl_assignments
      (variable_decl_assignment
        name: (simple_identifier) @name
        (#set! "kind" "Property"))))) @type

(function_declaration
  (_)*
  (function_body_declaration
    (_)*
    name: (simple_identifier) @name
  (#set! "kind" "Function"))) @type

(task_declaration
  (_)*
  (task_body_declaration
    name: (simple_identifier) @name
  (#set! "kind" "Function"))) @type
