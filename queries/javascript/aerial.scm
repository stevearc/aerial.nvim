(class_declaration
  name: (identifier) @name) @type

(function_declaration
  name: (identifier) @name) @type

(method_definition
  name: (property_identifier) @name) @type

; describe("Unit test")
(call_expression
  function: (identifier) @method @name (#any-of? @method "describe" "it" "test" "afterAll" "afterEach" "beforeAll" "beforeEach")
  arguments: (arguments
    (string
      (string_fragment) @name @string))?
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
) @type
