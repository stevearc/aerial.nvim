(binary_operator
    lhs: ((identifier) @name)
    ["<-" "="]
    rhs: (function_definition)
    (#set! "kind" "Function")) @symbol
