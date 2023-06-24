;; Method and Function declarations
(contract_declaration (_
                        (function_definition
                          name: (identifier) @name
                          (#set! "kind" "Function")
                          ) @type))

(library_declaration (_
                       (function_definition
                         name: (identifier) @name
                         (#set! "kind" "Function")
                         ) @type))

(interface_declaration (_
                         (function_definition
                           name: (identifier) @name
                           (#set! "kind" "Function")
                           ) @type))
(source_file
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Function")
    ) @type)

(contract_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @type

(library_declaration
  name: (identifier) @name
  (#set! "kind" "Module")
  ) @type

(event_definition 
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

; (constructor_declaration
;   name: (identifier) @name
;   (#set! "kind" "Constructor")
;   ) @type

