(create_table
  (object_reference) @name
  (#set! "kind" "Class")) @symbol

(create_view
  (object_reference) @name
  (#set! "kind" "Class")) @symbol

(create_materialized_view
  (object_reference) @name
  (#set! "kind" "Class")) @symbol

(create_function
  (object_reference) @name
  (#set! "kind" "Function")) @symbol

(create_type
  (object_reference) @name
  (#set! "kind" "Struct")) @symbol

(create_sequence
  (object_reference) @name
  (#set! "kind" "Class")) @symbol

(create_trigger
  (object_reference) @name
  (#set! "kind" "Class")) @symbol

(create_index
  column: (_) @name
  (#set! "kind" "Class")) @symbol

(create_role
  (identifier) @name
  (#set! "kind" "Class")) @symbol

(create_policy
  (object_reference) @name
  (#set! "kind" "Class")) @symbol

(create_extension
  (identifier) @name
  (#set! "kind" "Module")) @symbol

(create_schema
  (identifier) @name
  (#set! "kind" "Module")) @symbol

(create_database
  (identifier) @name
  (#set! "kind" "Module")) @symbol
