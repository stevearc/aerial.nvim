local util = require("tests.test_util")

describe("treesitter php", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/php_test.php", {
      {
        kind = "Function",
        name = "my_function",
        level = 0,
        lnum = 2,
        col = 0,
        end_lnum = 2,
        end_col = 27,
      },
      {
        kind = "Function",
        name = "$var_function",
        level = 0,
        lnum = 4,
        col = 0,
        end_lnum = 4,
        end_col = 32,
      },
      {
        kind = "Class",
        name = "MyClass",
        level = 0,
        lnum = 6,
        col = 0,
        end_lnum = 8,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "myMethod",
            level = 1,
            lnum = 7,
            col = 4,
            end_lnum = 7,
            end_col = 34,
          },
        },
      },
      {
        kind = "Interface",
        name = "InterfaceOne",
        level = 0,
        lnum = 9,
        col = 0,
        end_lnum = 11,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "doSomething",
            level = 1,
            lnum = 10,
            col = 4,
            end_lnum = 10,
            end_col = 34,
          },
        },
      },
      {
        kind = "Class",
        name = "MyTrait",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 15,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "myTraitMethod",
            level = 1,
            lnum = 14,
            col = 4,
            end_lnum = 14,
            end_col = 39,
          },
        },
      },
    })
  end)
end)
