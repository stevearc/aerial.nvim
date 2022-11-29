(section
  text: [(curly_group (text) @name) (_)] @name
  (#set! "kind" "Method")
) @type
(subsection
  text: [(curly_group (text) @name) (_)] @name
  (#set! "kind" "Method")
) @type
(subsubsection
  text: [(curly_group (text) @name) (_)] @name
  (#set! "kind" "Method")
) @type
(generic_environment
  begin: (begin
    name: [(curly_group_text text: (text) @name) (_)] @name
)
  (#set! "kind" "Class")
  ) @type

(new_command_definition
  declaration: [(curly_group_command_name command: (command_name) @name) (_)] @name
  (#set! "kind" "Operator")
) @type

(title_declaration
  text: [(curly_group (text) @name) (_)] @name
  (#set! "kind" "Field")
) @type
(author_declaration
  authors: [(curly_group_author_list (author) @name) (_)] @name
  (#set! "kind" "Field")
) @type
