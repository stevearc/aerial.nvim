(class_declaration
  name: (identifier) @name
  (#set! "kind" "Class")) @symbol

(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")) @symbol

(generator_function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")) @symbol

(method_definition
  name: (property_identifier) @name
  (#set! "kind" "Method")) @symbol

(field_definition
  property: (property_identifier) @name
  value: (arrow_function)
  (#set! "kind" "Method")) @symbol

; const fn = () => {}
(lexical_declaration
  (variable_declarator
    name: (identifier) @name
    value: [
      (arrow_function)
      (function_expression)
      (generator_function)
    ] @symbol)
  (#set! "kind" "Function")) @start

; describe("Unit test")
(call_expression
  function: (identifier) @method @name
  (#any-of? @method "describe" "it" "test" "afterAll" "afterEach" "beforeAll" "beforeEach")
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
  (#set! "kind" "Function")) @symbol

; test.skip("this test")
(call_expression
  function: (member_expression
    object: (identifier) @method
    (#any-of? @method "describe" "it" "test")
    property: (property_identifier) @modifier
    (#any-of? @modifier "skip" "todo")) @name
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
  (#set! "kind" "Function")) @symbol

; describe.each([])("Test suite")
(call_expression
  function: (call_expression
    function: (member_expression
      object: (identifier) @method
      (#any-of? @method "describe" "it" "test")
      property: (property_identifier) @modifier
      (#any-of? @modifier "each")) @name)
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
  (#set! "kind" "Function")) @symbol
