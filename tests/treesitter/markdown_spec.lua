local util = require("tests.test_util")

describe("markdown", function()
  local symbols_all = {
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
      end_lnum = 17,
      end_col = 0,
      children = {
        {
          kind = "Interface",
          name = "Title 4",
          level = 2,
          lnum = 7,
          col = 0,
          end_lnum = 17,
          end_col = 0,
          children = {
            {
              kind = "Interface",
              name = "Title 5",
              level = 3,
              lnum = 13,
              col = 0,
              end_lnum = 17,
              end_col = 0,
            },
          },
        },
      },
    },
    {
      kind = "Interface",
      name = "Title 6",
      level = 0,
      lnum = 18,
      col = 0,
      end_lnum = 27,
      end_col = 3,
      children = {
        {
          kind = "Interface",
          name = "Title 7",
          level = 1,
          lnum = 21,
          col = 0,
          end_lnum = 27,
          end_col = 3,
        },
      },
    },
  }
  local symbols_atx = {
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
      end_lnum = 27,
      end_col = 3,
      children = {
        {
          kind = "Interface",
          name = "Title 4",
          level = 2,
          lnum = 7,
          col = 0,
          end_lnum = 27,
          end_col = 3,
          children = {
            {
              kind = "Interface",
              name = "Title 5",
              level = 3,
              lnum = 13,
              col = 0,
              end_lnum = 27,
              end_col = 3,
            },
          },
        },
      },
    },
  }
  it("treesitter parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/markdown_test.md", symbols_all)
  end)
  it("custom backend parses atx symbols correctly", function()
    util.test_file_symbols("markdown", "./tests/treesitter/markdown_test.md", symbols_atx)
  end)
end)
