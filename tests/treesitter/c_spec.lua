local util = require("tests.test_util")

describe("treesitter c", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/c_test.c", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 3,
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
        lnum = 7,
        col = 0,
      },
      {
        kind = "Function",
        name = "fn_4",
        level = 0,
        lnum = 9,
        col = 0,
      },
      {
        kind = "Enum",
        name = "kEnum",
        level = 0,
        lnum = 11,
        col = 0,
      },
      {
        kind = "Struct",
        name = "St_1",
        level = 0,
        lnum = 15,
        col = 0,
      },
    })
  end)
end)
