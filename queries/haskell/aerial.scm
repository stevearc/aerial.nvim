(function
  name: (variable) @name
  (#set! "kind" "Function")) @symbol @start

(data_type
  name: (name) @name
  (#set! "kind" "Struct")) @symbol @start

(newtype
  name: (name) @name
  (#set! "kind" "Struct")) @start @symbol

(declarations
  (instance
    name: (name) @name
    (#set! "kind" "Class")) @start @symbol)

(instance
  name: (name) @name

  declarations: (instance_declarations
    declaration: (function
      name: (variable) @name)
    (#set! "kind" "Method")) @start @symbol)

(class
  name: (name) @name
  (#set! "kind" "Interface")) @start @symbol

(class
  declarations: (class_declarations
    declaration: (signature
      name: (variable) @name)
    (#set! "kind" "Method")) @start @symbol)
