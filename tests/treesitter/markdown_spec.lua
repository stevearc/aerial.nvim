local util = require("tests.test_util")

describe("markdown", function()
  local symbols = {
    {
      kind = "Interface",
      name = "Title 1",
      level = 0,
      lnum = 1,
      col = 0,
      end_lnum = 4,
      end_col = 0,
      children = {
        {
          kind = "Interface",
          name = "Title 2",
          level = 1,
          lnum = 3,
          col = 0,
          end_lnum = 4,
          end_col = 0,
        },
      },
    },
    {
      kind = "Interface",
      name = "Title 3",
      level = 0,
      lnum = 5,
      col = 0,
      end_lnum = 15,
      end_col = 8,
      children = {
        {
          kind = "Interface",
          name = "Title 4",
          level = 2,
          lnum = 7,
          col = 0,
          end_lnum = 15,
          end_col = 8,
          children = {
            {
              kind = "Interface",
              name = "Title 5",
              level = 3,
              lnum = 13,
              col = 0,
              end_lnum = 15,
              end_col = 8,
            },
          },
        },
      },
    },
  }
  it("treesitter parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/markdown_test.md", symbols)
  end)
  it("custom backend parses all symbols correctly", function()
    util.test_file_symbols("markdown", "./tests/treesitter/markdown_test.md", symbols)
  end)
end)
