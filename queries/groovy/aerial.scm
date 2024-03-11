(command (block
  (unit
    (identifier)?
    (identifier) @name (#not-any-of? @name "else" "try" "exec")
    (#set! "kind" "Module")
    ))) @symbol

(command
  (unit
    (identifier) @name
    )
  .
  (block (operators))
  (#set! "kind" "Function")
  ) @symbol

(command
  (unit
    (identifier) @keyword (#any-of? @keyword "task")
    )
  .
  (block (unit (func (identifier) @name)))
  (#set! "kind" "Function")
  ) @symbol

(command
  (unit
    (identifier) @keyword (#eq? @keyword "def")
    )
  .
  (unit
    (identifier) @name
    )
  .
  (operators)
  (#set! "kind" "Constant")
  ) @symbol
