local util = require("tests.test_util")

describe("treesitter ts", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/ts_test.ts", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 1,
        end_col = 18,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 3,
        end_col = 22,
      },
      {
        kind = "Interface",
        name = "Iface_1",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 5,
        end_col = 20,
      },
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 7,
        col = 0,
        end_lnum = 9,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 8,
            col = 2,
            end_lnum = 8,
            end_col = 13,
          },
        },
      },
      {
        kind = "Type",
        name = "Type1",
        level = 0,
        lnum = 11,
        col = 0,
        end_lnum = 11,
        end_col = 16,
      },
      {
        kind = "Function",
        name = "fn_3",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 13,
        end_col = 22,
      },
      {
        kind = "Variable",
        name = "const_var",
        level = 0,
        lnum = 15,
        col = 0,
        end_lnum = 15,
        end_col = 26,
      },
      {
        kind = "Variable",
        name = "let_var",
        level = 0,
        lnum = 16,
        col = 0,
        end_lnum = 16,
        end_col = 22,
      },
    })
  end)
end)
