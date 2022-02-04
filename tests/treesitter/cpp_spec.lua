local util = require("tests.test_util")

describe("treesitter cpp", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/cpp_test.cpp", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 1,
        end_col = 14,
      },
      {
        kind = "Struct",
        name = "st_1",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 3,
        end_col = 14,
      },
      {
        kind = "Struct",
        name = "st_2",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 6,
        end_col = 1,
      },
      {
        kind = "Enum",
        name = "en_1",
        level = 0,
        lnum = 8,
        col = 0,
        end_lnum = 8,
        end_col = 12,
      },
      {
        kind = "Class",
        name = "cl_1",
        level = 0,
        lnum = 10,
        col = 0,
        end_lnum = 13,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "meth_1",
            level = 1,
            lnum = 12,
            col = 2,
            end_lnum = 12,
            end_col = 18,
          },
        },
      },
      {
        kind = "Function",
        name = "A::bar",
        level = 0,
        lnum = 15,
        col = 0,
        end_lnum = 15,
        end_col = 16,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 17,
        col = 0,
        end_lnum = 17,
        end_col = 14,
      },
      {
        kind = "Function",
        name = "fn_3",
        level = 0,
        lnum = 19,
        col = 0,
        end_lnum = 19,
        end_col = 15,
      },
    })
  end)
end)
