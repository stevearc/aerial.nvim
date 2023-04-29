; (prim_definition
;   (string) @name
;   (#match? @name "\"([a-zA-Z0-9]+)\"")
;   (#set! "kind" "Class")
; ) @type
(prim_definition
  (string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "Class")
) @type
; ((identifier) @constant (#offset! @constant 0 1 0 -1))
; (
;   (identifier) @constant
;   (#match? @constant "^[A-Z][A-Z_]+")
; )
