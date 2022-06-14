local util = require("tests.test_util")

describe("treesitter neorg", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/norg_test.norg", {
      {
        kind = "Interface",
        name = "Top header",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 3,
        end_col = 20,
        children = {
          {
            kind = "Interface",
            name = "Level 2 header",
            level = 1,
            lnum = 2,
            col = 1,
            end_lnum = 3,
            end_col = 20,
            children = {
              {
                kind = "Interface",
                name = "Level 3 header",
                level = 2,
                lnum = 3,
                col = 2,
                end_lnum = 3,
                end_col = 20,
              },
            },
          },
        },
      },
    })
  end)
end)
