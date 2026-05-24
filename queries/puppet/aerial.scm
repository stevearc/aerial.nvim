; Classes
(class_definition
  (identifier) @name
  (#set! "kind" "Class")) @symbol

(class_definition
  (class_identifier
    (identifier) @name .)
  (#set! "kind" "Class")) @symbol

; Node definitions
(node_definition
  (node_name
    (string
      (string_content) @name))
  (#set! "kind" "Class")) @symbol

(node_definition
  (node_name
    (identifier) @name)
  (#set! "kind" "Class")) @symbol

; Defined resource types
(defined_resource_type
  (identifier) @name
  (#set! "kind" "Method")) @symbol

(defined_resource_type
  (class_identifier
    (identifier) @name .)
  (#set! "kind" "Method")) @symbol

; Function declarations
(function_declaration
  (identifier) @name
  (#set! "kind" "Function")) @symbol

(function_declaration
  (class_identifier
    (identifier) @name .)
  (#set! "kind" "Function")) @symbol

; Resource declarations (file { '/path': ... })
(resource_declaration
  title: (string
    (string_content) @name)
  (#set! "kind" "Object")) @symbol

; Resource defaults (File { ... })
(resource_default
  type: (identifier) @name
  (#set! "kind" "Object")) @symbol

; Variable assignments
(assignment
  (variable
    (identifier) @name)
  (#set! "kind" "Variable")) @symbol

; Conditionals
(if_statement
  "if" @name
  (#set! "kind" "Function")) @symbol

(case_statement
  "case" @name
  (#set! "kind" "Function")) @symbol

; Lambdas / iterators
(iterator_statement
  (variable
    (identifier) @name)
  (#set! "kind" "Function")) @symbol
