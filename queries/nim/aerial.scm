; Enum
(type_declaration
  (type_symbol_declaration
    name: (exported_symbol (identifier)) @name
  )
  (#set! "kind" "Enum")
  (enum_declaration
    (enum_field_declaration
      (symbol_declaration
        name: (identifier) @name
      )
      (#set! "kind" "EnumMember")
    ) @symbol
  )
) @symbol

(type_declaration
  (type_symbol_declaration
    name: (identifier) @name
  )
  (#set! "kind" "Enum")
  (enum_declaration
    (enum_field_declaration
      (symbol_declaration
        name: (identifier) @name
        (#set! "kind" "EnumMember")
      )
    ) @symbol
  )
) @symbol

; Object
(type_declaration
  (type_symbol_declaration
    name: (exported_symbol
      (identifier) @name
    )
  )
  (object_declaration)
  (#set! "kind" "Object")
) @symbol

; Object ref
(type_declaration
  (type_symbol_declaration
    name: (exported_symbol
      (identifier) @name
    )
  )
  (ref_type
    (object_declaration)
  )
  (#set! "kind" "Object")
) @symbol

; Template
(template_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
) @symbol

; Macro
(macro_declaration
  ; [1593, 0] - [1594, 13]
  name: (identifier) @name
  (#set! "kind" "Function")
) @symbol

; Proc
(proc_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
) @symbol

; Proc (exported)
(proc_declaration
  name: (exported_symbol (identifier) @name)
  (#set! "kind" "Function")
) @symbol

; Func
(func_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
) @symbol

; Object fields
(object_declaration
  (field_declaration_list
    (field_declaration
      (symbol_declaration_list
        (symbol_declaration
          name: (exported_symbol
            (identifier) @name
          )
          (#set! "kind" "Property")
        ) @symbol
      )
    )
  )
)

; Constant
(const_section
  (variable_declaration
    (symbol_declaration_list
      (symbol_declaration
        name: (identifier) @name
      )
      (#set! "kind" "Constant")
    ) @symbol
  )
)

; Type
(type_declaration
  (type_symbol_declaration
    name: (identifier) @name
    (#set! "kind" "Class")
  ) @symbol
)

; Top level variables
(source_file
  (var_section
    (variable_declaration
      (symbol_declaration_list
        (symbol_declaration
          name: (identifier) @name
        )
      )
    )
    (#set! "kind" "Variable")
  ) @symbol
)
