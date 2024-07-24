(class
  name: [
    (constant)
    (scope_resolution)
  ] @name
  (#set! "kind" "Class")) @symbol

(call
  ((identifier) @scope
    (#any-of? @scope "private" "protected" "public"))?
  .
  (argument_list
    (method
      name: (_) @name
      (#set! "kind" "Method")) @symbol))

(body_statement
  [
    (_)
    ((identifier) @scope
      (#any-of? @scope "private" "protected" "public"))
  ]*
  .
  (method
    name: (_) @name
    (#set! "kind" "Method")) @symbol)

; handle methods not caught by the above query that includes the scope
(body_statement
  (method
    name: (_) @name
    (#set! "kind" "Method")) @symbol)

(singleton_method
  object: [
    (constant)
    (self)
    (identifier)
  ] @receiver
  ([
    "."
    "::"
  ] @separator)?
  name: [
    (operator)
    (identifier)
  ] @name
  (#set! "kind" "Method")) @symbol

(singleton_class
  value: (_) @name
  (#set! "kind" "Class")) @symbol

(module
  name: [
    (constant)
    (scope_resolution)
  ] @name
  (#set! "kind" "Module")) @symbol

; For Rspec, Rake, and Shoulda
(call
  method: (identifier) @method @name
  (#any-of? @method
    "describe" "it" "before" "after" ; Rspec
     "namespace" "task" "multitask" "file" ; Rake
     "setup" "teardown" "should" "should_not" "should_eventually" "context")
  ; Shoulda
  arguments: (argument_list
    [
      (string
        (string_content) @name)
      (simple_symbol) @name
      (pair
        key: [
          (string
            (string_content) @name)
          (hash_key_symbol) @name
        ])
      (call) @name
    ])?
  (#set! "kind" "Method")) @symbol @selection
