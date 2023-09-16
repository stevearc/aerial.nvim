(contract_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(contract_declaration (_
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Method")
    ) @type))

(contract_declaration (_
  (modifier_definition
    name: (identifier) @name
    (#set! "kind" "Method")
    ) @type))

(library_declaration (_
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Function")
    ) @type))

(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @type

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

(library_declaration
  name: (identifier) @name
  (#set! "kind" "Module")
  ) @type

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")
  ) @type

(event_definition
  name: (identifier) @name
  (#set! "kind" "Event")
  ) @type

(struct_declaration
  name: (identifier) @name
  (#set! "kind" "Struct")
  ) @type

(constructor_definition
  ("constructor") @name
  (#set! "kind" "Constructor")
  ) @type

(state_variable_declaration
  name: (identifier) @name @type
  (#set! "kind" "Field"))
