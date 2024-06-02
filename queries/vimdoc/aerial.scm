(h1
  (word)+ @name @start
  (tag)
  (#set! "kind" "Interface")) @symbol

(h2
  (word)+ @name @start
  (tag)
  (#set! "kind" "Interface")) @symbol

(tag
  text: (word) @name
  (#set! "kind" "Interface")) @symbol
