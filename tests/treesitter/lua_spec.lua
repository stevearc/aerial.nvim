local util = require("tests.test_util")

describe("treesitter lua", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/lua_test.lua", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 5,
        col = 0,
      },
      {
        kind = "Function",
        name = "fn_3",
        level = 0,
        lnum = 9,
        col = 13,
      },
      {
        kind = "Function",
        name = "fn_4",
        level = 0,
        lnum = 13,
        col = 7,
        children = {
          {
            kind = "Function",
            name = "<Anonymous>",
            level = 1,
            lnum = 14,
            col = 7,
          },
        },
      },
      {
        kind = "Function",
        name = "meth_1",
        level = 0,
        lnum = 21,
        col = 11,
      },
      {
        kind = "Function",
        name = "M.fn_5",
        level = 0,
        lnum = 26,
        col = 9,
      },
    })
  end)
end)
