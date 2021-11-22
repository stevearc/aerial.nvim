local util = require("tests.test_util")

describe("treesitter go", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/go_test.go", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 3,
        col = 0,
      },
      {
        kind = "Struct",
        name = "st_1",
        level = 0,
        lnum = 5,
        col = 0,
      },
      {
        kind = "Method",
        name = "Meth_1",
        level = 0,
        lnum = 7,
        col = 0,
      },
    })
  end)
end)
