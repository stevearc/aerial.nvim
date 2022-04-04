(class
  name: [(constant) (scope_resolution)] @name) @type

(method
  name: (identifier) @name) @type

(singleton_method
  name: (identifier) @name) @type

(module
  name: [(constant) (scope_resolution)] @name) @type

; For Rspec and Rake
(call
  method: (identifier) @method @name (#any-of? @method "describe" "it" "before" "after" "namespace" "task" "multitask" "file")
  arguments: (argument_list
    [(string
      (string_content) @name)
     (simple_symbol) @name
     (pair
        key: [(string (string_content) @name) (hash_key_symbol) @name])
    ])?
) @type
