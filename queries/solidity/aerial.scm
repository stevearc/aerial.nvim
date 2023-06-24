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

(struct_declaration 
  name: (identifier) @name
  (#set! "kind" "Struct")
  ) @type

(enum_declaration 
  name: (identifier) @name  
  (#set! "kind" "Enum")
  ) @type

(event_definition 
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type
