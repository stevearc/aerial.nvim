local util = require("tests.test_util")

describe("treesitter bash", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/bash_test.sh", {
      {
        kind = "Function",
        name = "function_1",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 5,
        end_col = 1,
      },
    })
  end)
end)
