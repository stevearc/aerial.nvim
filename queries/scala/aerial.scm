(trait_definition
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @symbol

(object_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @symbol

(class_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @symbol

(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol

(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol
