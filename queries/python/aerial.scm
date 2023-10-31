(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @symbol

(class_definition
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @symbol

(assignment
  left: (_) @name
  (#set! "kind" "Variable")
  ) @symbol
