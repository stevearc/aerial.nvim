(juxt_function_call
  function: (identifier) @name
  (#not-any-of? @name "else" "try" "exec")
  (argument_list
    (closure))
  (#set! "kind" "Module")) @symbol

(declaration
  name: (identifier) @name
  (closure)
  (#set! "kind" "Function")) @symbol

(juxt_function_call
  function: (identifier) @keyword
  (#eq? @keyword "task")
  (argument_list
    (function_call
      function: (identifier) @name))
  (#set! "kind" "Function")) @symbol

(declaration
  name: (identifier) @name
  (#set! "kind" "Constant")) @symbol
