local util = require("tests.test_util")

describe("treesitter c", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/c_test.c", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 3,
        end_col = 22,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 5,
        end_col = 34,
      },
      {
        kind = "Function",
        name = "fn_3",
        level = 0,
        lnum = 7,
        col = 0,
        end_lnum = 7,
        end_col = 14,
      },
      {
        kind = "Function",
        name = "fn_4",
        level = 0,
        lnum = 9,
        col = 0,
        end_lnum = 9,
        end_col = 26,
      },
      {
        kind = "Function",
        name = "fn_5",
        level = 0,
        lnum = 11,
        col = 0,
        end_lnum = 11,
        end_col = 27,
      },
      {
        kind = "Enum",
        name = "kEnum",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 15,
        end_col = 8,
      },
      {
        kind = "Struct",
        name = "St_1",
        level = 0,
        lnum = 17,
        col = 0,
        end_lnum = 19,
        end_col = 7,
      },
    })
  end)
end)
