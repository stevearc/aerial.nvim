(element
  (STag (Name) @name
    (#set! "kind" "Struct")
  )
) @symbol

(element
  (EmptyElemTag (Name) @name
    (#set! "kind" "Struct")
  )
) @symbol


(Attribute (Name) @name
  (#set! "kind" "Field")
) @symbol
