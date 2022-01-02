(class
  name: (constant) @name) @type

(method
  name: (identifier) @name) @type

(singleton_method
  name: (identifier) @name) @type

(module
  name: (constant) @name) @type

(call
  method: (identifier) @method @name (#any-of? @method "describe" "it" "before" "after")
  arguments: (argument_list
    (string
      (string_content) @name))?
) @type
