((doctype) @name
  (#set! "kind" "Module")) @symbol

(_
  [
    (start_tag
      (tag_name) @name)
    (self_closing_tag
      (tag_name) @name)
  ]
  (#set! "kind" "Struct")) @symbol

(attribute
  (attribute_name) @name
  (#set! "kind" "Field")) @symbol
