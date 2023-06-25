local util = require("tests.test_util")

describe("treesitter solidity", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/solidity_test.sol", {
      {
        kind = "Module",
        name = "a",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 9,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "f",
            level = 1,
            lnum = 6,
            col = 4,
            end_lnum = 8,
            end_col = 5,
          },
        },
      },
      {
        kind = "Class",
        name = "A",
        level = 0,
        lnum = 11,
        col = 0,
        end_lnum = 16,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "Log",
            level = 1,
            lnum = 12,
            col = 4,
            end_lnum = 12,
            end_col = 54,
          },
          {
            kind = "Method",
            name = "m",
            level = 1,
            lnum = 13,
            col = 4,
            end_lnum = 15,
            end_col = 5,
          },
        },
      },
      {
        kind = "Interface",
        name = "I",
        level = 0,
        lnum = 18,
        col = 0,
        end_lnum = 20,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "f",
            level = 1,
            lnum = 19,
            col = 4,
            end_lnum = 19,
            end_col = 17,
          },
        },
      },
    })
  end)
end)
