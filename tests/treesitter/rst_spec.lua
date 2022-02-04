local util = require("tests.test_util")

describe("treesitter rst", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/rst_test.rst", {
      {
        kind = "Interface",
        name = "Title 1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 3,
        end_col = 0,
      },
      {
        kind = "Interface",
        name = "Title 2",
        level = 0,
        lnum = 4,
        col = 0,
        end_lnum = 6,
        end_col = 8,
      },
    })
  end)
end)
