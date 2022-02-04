local util = require("tests.test_util")

describe("treesitter dart", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/dart_test.dart", {
      {
        kind = "Class",
        name = "Class_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 11,
        end_col = 1,
        children = {
          {
            kind = "Constructor",
            name = "Class_1",
            level = 1,
            lnum = 2,
            col = 2,
            end_lnum = 2,
            end_col = 11,
          },
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 4,
            col = 2,
            end_lnum = 4,
            end_col = 19,
          },
          {
            kind = "Method",
            name = "prop",
            level = 1,
            lnum = 6,
            col = 2,
            end_lnum = 8,
            end_col = 3,
          },
          {
            kind = "Method",
            name = "prop",
            level = 1,
            lnum = 10,
            col = 2,
            end_lnum = 10,
            end_col = 31,
          },
        },
      },
      {
        kind = "Function",
        name = "function_1",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 13,
        end_col = 21,
      },
      {
        kind = "Enum",
        name = "Enum_1",
        level = 0,
        lnum = 15,
        col = 0,
        end_lnum = 17,
        end_col = 1,
      },
    })
  end)
end)
