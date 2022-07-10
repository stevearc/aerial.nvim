local util = require("tests.test_util")

describe("treesitter tsx", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/tsx_test.tsx", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 3,
        end_col = 1,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 5,
        end_col = 22,
      },
      {
        kind = "Interface",
        name = "Iface_1",
        level = 0,
        lnum = 7,
        col = 0,
        end_lnum = 7,
        end_col = 20,
      },
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 9,
        col = 0,
        end_lnum = 11,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 10,
            col = 2,
            end_lnum = 10,
            end_col = 13,
          },
        },
      },
      {
        kind = "Type",
        name = "Type1",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 13,
        end_col = 16,
      },
      {
        kind = "Function",
        name = "fn_3",
        level = 0,
        lnum = 15,
        col = 0,
        end_lnum = 15,
        end_col = 22,
      },
      {
        kind = "Variable",
        name = "const_var",
        level = 0,
        lnum = 17,
        col = 0,
        end_lnum = 17,
        end_col = 26,
      },
      {
        kind = "Variable",
        name = "let_var",
        level = 0,
        lnum = 18,
        col = 0,
        end_lnum = 18,
        end_col = 22,
      },
    })
  end)
end)
