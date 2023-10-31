(contract_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @symbol

(contract_declaration (_
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Method")
    ) @symbol))

(contract_declaration (_
  (modifier_definition
    name: (identifier) @name
    (#set! "kind" "Method")
    ) @symbol))

(library_declaration (_
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Function")
    ) @symbol))

(interface_declaration
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @symbol

(interface_declaration (_
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Function")
    ) @symbol))

(source_file
  (function_definition
    name: (identifier) @name
    (#set! "kind" "Function")
    ) @symbol)

(library_declaration
  name: (identifier) @name
  (#set! "kind" "Module")
  ) @symbol

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")
  ) @symbol

(event_definition
  name: (identifier) @name
  (#set! "kind" "Event")
  ) @symbol

(struct_declaration
  name: (identifier) @name
  (#set! "kind" "Struct")
  ) @symbol

(constructor_definition
  ("constructor") @name
  (#set! "kind" "Constructor")
  ) @symbol

(state_variable_declaration
  name: (identifier) @name @symbol
  (#set! "kind" "Field"))
