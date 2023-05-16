(prim_definition
  (string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "Class")
) @type

(attribute_assignment
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @type

(attribute_declaration
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @type

(relationship_assignment
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @type

(relationship_declaration
  [(identifier) (qualified_identifier)] @name
  (#set! "kind" "Property")
) @type

(variant_set_definition
  (string) @name
  (#offset! @name 0 1 0 -1)
  (#set! "kind" "Property")
) @type
