; host sections
(host_declaration
  argument: (_) @name @symbol
  (#set! "kind" "Interface"))

; match sections
(match_declaration
  (condition
    (_) @name @symbol)
  (#set! "kind" "Interface"))
