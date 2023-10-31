(prim_definition
  (string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "Class")
) @symbol

(attribute_assignment
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @symbol

(attribute_declaration
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @symbol

(relationship_assignment
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @symbol

(relationship_declaration
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @symbol

(variant_set_definition
  (string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "Enum")
) @symbol

(variant
  (string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "EnumMember")
) @symbol
