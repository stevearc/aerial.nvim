local util = require("tests.test_util")

describe("make", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/Makefile", {
      {
        kind = "Interface",
        name = "all",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 4,
        end_col = 0,
      },
      {
        kind = "Interface",
        name = "out.so",
        level = 0,
        lnum = 4,
        col = 0,
        end_lnum = 6,
        end_col = 0,
      },
    })
  end)
end)
