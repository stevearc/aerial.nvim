local util = require("tests.test_util")

describe("treesitter teal", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/teal_test.tl", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 3,
        end_col = 3,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 7,
        end_col = 3,
      },
      {
        kind = "Function",
        name = "fn_3",
        level = 0,
        lnum = 11,
        col = 0,
        end_lnum = 11,
        end_col = 23,
      },
      {
        kind = "Function",
        name = "M.launch",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 15,
        end_col = 3,
      },
      {
        kind = "Function",
        name = "M.wrap",
        level = 0,
        lnum = 17,
        col = 0,
        end_lnum = 21,
        end_col = 3,
      },
      {
        kind = "Function",
        name = "Point.new",
        level = 0,
        lnum = 28,
        col = 0,
        end_lnum = 33,
        end_col = 3,
      },
      {
        kind = "Function",
        name = "Point:move",
        level = 0,
        lnum = 35,
        col = 0,
        end_lnum = 38,
        end_col = 3,
      },
    })
  end)
end)
