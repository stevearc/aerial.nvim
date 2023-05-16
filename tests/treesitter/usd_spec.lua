local util = require("tests.test_util")

describe("treesitter USD", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/usd_test.usd", {
      {
        kind = "Class",
        name = "something",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 4,
        end_col = 8,
      },
    })
  end)
end)
