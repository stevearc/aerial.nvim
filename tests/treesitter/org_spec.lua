local util = require("tests.test_util")

-- Old versions of nvim-treesitter do not have this parser
-- New versions of nvim-treesitter do not support neovim <0.7.0
if not require("nvim-treesitter.parsers").has_parser("org") then
  return
end

describe("org", function()
  local symbols = {
    {
      kind = "Interface",
      name = "Level1",
      level = 0,
      lnum = 1,
      col = 0,
      end_lnum = 7,
      end_col = 0,
      children = {
        {
          kind = "Interface",
          name = "Level2",
          level = 1,
          lnum = 3,
          col = 0,
          end_lnum = 7,
          end_col = 0,
          children = {
            {
              kind = "Interface",
              name = "Level3",
              level = 2,
              lnum = 5,
              col = 0,
              end_lnum = 7,
              end_col = 0,
            },
          },
        },
      },
    },
    {
      kind = "Interface",
      name = "Level1_2",
      level = 0,
      lnum = 7,
      col = 0,
      end_lnum = 14,
      end_col = 0,
      children = {
        {
          kind = "Interface",
          name = "Level2_2",
          level = 1,
          lnum = 11,
          col = 0,
          end_lnum = 14,
          end_col = 0,
        },
      },
    },
  }
  it("treesitter parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/org_test.org", symbols)
  end)
end)
