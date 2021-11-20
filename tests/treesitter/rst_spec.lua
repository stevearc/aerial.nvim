local util = require("tests.test_util")

describe("treesitter rst", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/rst_test.rst", {
      {
        kind = "Namespace",
        name = "Title 1",
        level = 0,
        lnum = 1,
        col = 0,
      },
      {
        kind = "Namespace",
        name = "Title 2",
        level = 0,
        lnum = 4,
        col = 0,
      },
    })
  end)
end)
