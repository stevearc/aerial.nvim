(Decl
  (VarDecl
    variable_type_function: (IDENTIFIER) @name
    (#set! "kind" "Struct")
    (_
      (_
        (ContainerDecl
          (ContainerDeclType
            "struct") @symbol)))))

(Decl
  (VarDecl
    variable_type_function: (IDENTIFIER) @name
    (#set! "kind" "Struct")
    (_
      (_
        (ContainerDecl
          (ContainerDeclType
            "union") @symbol)))))

(FnProto
  function: (IDENTIFIER) @name
  (#set! "kind" "Function")) @symbol

(TestDecl
  (STRINGLITERALSINGLE) @name
  (#set! "kind" "Function")) @symbol
