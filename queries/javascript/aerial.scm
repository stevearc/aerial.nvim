(class_declaration
  name: (identifier) @name
  (#set! "kind" "Class")
  ) @type

(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(generator_function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")
  ) @type

(method_definition
  name: (property_identifier) @name
  (#set! "kind" "Method")
  ) @type

(field_definition
  property: (property_identifier) @name
  value: (arrow_function)
  (#set! "kind" "Method")
  ) @type

; const fn = () => {}
(lexical_declaration
  (variable_declarator
    name: (identifier) @name
    value: [(arrow_function) (function) (generator_function)] @type
  )
  (#set! "kind" "Function")
  ) @start

; describe("Unit test")
(call_expression
  function: (identifier) @method @name (#any-of? @method "describe" "it" "test" "afterAll" "afterEach" "beforeAll" "beforeEach")
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
  (#set! "kind" "Function")
  ) @type

; test.skip("this test")
(call_expression
  function: (member_expression
    object: (identifier) @method (#any-of? @method "describe" "it" "test")
    property: (property_identifier) @modifier (#any-of? @modifier "skip" "todo")
  ) @name
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
  (#set! "kind" "Function")
  ) @type

; describe.each([])("Test suite")
(call_expression
  function: (call_expression
    function: (member_expression
      object: (identifier) @method (#any-of? @method "describe" "it" "test")
      property: (property_identifier) @modifier (#any-of? @modifier "each")
    ) @name
  )
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
  (#set! "kind" "Function")
  ) @type
