local util = require("tests.test_util")

describe("treesitter csharp", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/csharp_test.cs", {
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 4,
        end_col = 1,
        children = {
          {
            kind = "Constructor",
            name = "Cl_1",
            level = 1,
            lnum = 2,
            col = 2,
            end_lnum = 2,
            end_col = 18,
          },
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 3,
            col = 2,
            end_lnum = 3,
            end_col = 25,
          },
        },
      },
      {
        kind = "Enum",
        name = "En_1",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 5,
        end_col = 20,
      },
      {
        kind = "Struct",
        name = "St_1",
        level = 0,
        lnum = 6,
        col = 0,
        end_lnum = 6,
        end_col = 22,
      },
    })
  end)
end)
