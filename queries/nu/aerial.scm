; Functions
(decl_def
  (cmd_identifier) @name
  (#set! "kind" "Function")
) @symbol

(decl_def
  (val_string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "Function")
) @symbol

; Modules
(decl_module
  (cmd_identifier) @name
  (#set! "kind" "Module")
) @symbol

; Constant
(stmt_const
  (identifier) @name
  (#set! "kind" "Constant")
) @symbol
