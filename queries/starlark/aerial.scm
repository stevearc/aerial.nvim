(expression_statement
  (call
    function: (identifier) @rule_kind
    (#not-any-of? @rule_kind "load")
    arguments: (argument_list
      (keyword_argument
        name: (identifier)
        value: (string
          (string_content) @rule_name))))
  (#set! "kind" "Function")) @symbol
