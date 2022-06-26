local util = require("tests.test_util")

-- Disabling tests until vim parser is fixed https://github.com/vigoux/tree-sitter-viml/pull/106
describe("treesitter vim", function()
  -- it("parses all symbols correctly", function()
  --   util.test_file_symbols("treesitter", "./tests/treesitter/vim_test.vim", {
  --     {
  --       kind = "Function",
  --       name = "Fn_1",
  --       level = 0,
  --       lnum = 1,
  --       col = 0,
  --       end_lnum = 2,
  --       end_col = 11,
  --     },
  --     {
  --       kind = "Function",
  --       name = "s:fn_2",
  --       level = 0,
  --       lnum = 4,
  --       col = 0,
  --       end_lnum = 5,
  --       end_col = 11,
  --     },
  --   })
  -- end)
end)
