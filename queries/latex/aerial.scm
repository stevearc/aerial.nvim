(part
  text: [
    (curly_group
      (text) @name)
    (_)
  ] @name
  (#set! "kind" "Method")) @symbol

(chapter
  text: [
    (curly_group
      (text) @name)
    (_)
  ] @name
  (#set! "kind" "Method")) @symbol

(section
  text: [
    (curly_group
      (text) @name)
    (_)
  ] @name
  (#set! "kind" "Method")) @symbol

(subsection
  text: [
    (curly_group
      (text) @name)
    (_)
  ] @name
  (#set! "kind" "Method")) @symbol

(subsubsection
  text: [
    (curly_group
      (text) @name)
    (_)
  ] @name
  (#set! "kind" "Method")) @symbol

(generic_environment
  begin: (begin
    name: [
      (curly_group_text
        text: (text) @name)
      (_)
    ] @name)
  (#set! "kind" "Class")) @symbol

(new_command_definition
  declaration: [
    (curly_group_command_name
      command: (command_name) @name)
    (_)
  ] @name
  (#set! "kind" "Operator")) @symbol

(title_declaration
  text: [
    (curly_group
      (text) @name)
    (_)
  ] @name
  (#set! "kind" "Field")) @symbol

(author_declaration
  authors: [
    (curly_group_author_list
      (author) @name)
    (_)
  ] @name
  (#set! "kind" "Field")) @symbol
