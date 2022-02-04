local util = require("tests.test_util")

describe("treesitter python", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/python_test.py", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 2,
        end_col = 8,
      },
      {
        kind = "Class",
        name = "cl_1",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 7,
        end_col = 12,
        children = {
          {
            kind = "Function",
            name = "meth_1",
            level = 1,
            lnum = 6,
            col = 4,
            end_lnum = 7,
            end_col = 12,
          },
        },
      },
    })
  end)
end)
