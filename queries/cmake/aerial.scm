(function_def
  (function_command
    (argument_list
      .
      (argument) @name))
  (#set! "kind" "Function")) @symbol

(macro_def
  (macro_command
    (argument_list
      .
      (argument) @name))
  (#set! "kind" "Function")) @symbol

(normal_command
  (identifier) @_command
  (argument_list
    .
    (argument) @name)
  (#match? @_command "\\c^(add_executable|add_library|add_custom_target)$")
  (#set! "kind" "Interface")) @symbol
