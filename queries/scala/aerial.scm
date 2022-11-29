(trait_definition
  name: (identifier) @name
  (#set! "kind" "Interface")
  ) @type

(object_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(class_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type
