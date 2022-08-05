(class
  name: [(constant) (scope_resolution)] @name) @type

(method
  name: (identifier) @name) @type

(singleton_method
  name: (identifier) @name) @type

(module
  name: [(constant) (scope_resolution)] @name) @type

; For Rspec, Rake, and Shoulda
(call
  method: (identifier) @method @name
  (#any-of? @method
   "describe" "it" "before" "after" ; Rspec
   "namespace" "task" "multitask" "file" ; Rake
   "setup" "teardown" "should" "should_not" "should_eventually" "context") ; Shoulda
  arguments: (argument_list
    [(string
      (string_content) @name)
     (simple_symbol) @name
     (pair
        key: [(string (string_content) @name) (hash_key_symbol) @name])
     (call) @name
    ])?
) @type
