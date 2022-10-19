local util = require("tests.test_util")

describe("treesitter help", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/help_test.txt", {
      {
        kind = "Interface",
        name = "help_test.txt",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 1,
        end_col = 15,
      },
      {
        kind = "Interface",
        name = "TEST INTRO",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 3,
        end_col = 10,
        children = {
          {
            kind = "Interface",
            name = ":SomeCommand",
            level = 1,
            lnum = 5,
            col = 68,
            end_lnum = 5,
            end_col = 82,
          },
        },
      },
    })
  end)
end)
