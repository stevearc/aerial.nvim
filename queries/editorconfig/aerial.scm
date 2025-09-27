; single glob, e.g. [*.foo]
(section
  (section_name
    [
      (character)
      (integer_range)
      (path_separator)
      (character_choice)
      (escaped_character)
      (wildcard_characters)
      (wildcard_any_characters)
      (wildcard_single_character)
    ]) @name @symbol
  (#set! "kind" "Class"))

; multiple globs in braces, e.g. [{*.foo,*.bar}]
(section
  (section_name
    (brace_expansion
      (expansion_string) @name @symbol))
  (#set! "kind" "Class"))
