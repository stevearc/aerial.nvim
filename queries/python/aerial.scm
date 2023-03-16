(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(class_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(assignment
  left: (_) @name
  (#set! "kind" "Variable")
  ) @type
