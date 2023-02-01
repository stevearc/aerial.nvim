((doctype) @name
  (#set! "kind" "Module")
) @type

(_
  [
    (start_tag (tag_name) @name)
    (self_closing_tag (tag_name) @name)
  ]
  (#set! "kind" "Snippet")
) @type

(attribute (attribute_name) @name
 (#set! "kind" "Field")
) @type
