local util = require("tests.test_util")

describe("treesitter ruby", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/ruby_test.rb", {
      {
        kind = "Module",
        name = "Mod",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 7,
        end_col = 3,
        children = {
          {
            kind = "Class",
            name = "Cl_1",
            level = 1,
            lnum = 2,
            col = 2,
            end_lnum = 4,
            end_col = 5,
            children = {
              {
                kind = "Method",
                name = "meth_1",
                level = 2,
                lnum = 3,
                col = 4,
                end_lnum = 3,
                end_col = 20,
              },
            },
          },
          {
            kind = "Method",
            name = "meth_2",
            level = 1,
            lnum = 6,
            col = 2,
            end_lnum = 6,
            end_col = 18,
          },
        },
      },
      {
        kind = "Method",
        name = "describe UnitTest",
        level = 0,
        lnum = 9,
        col = 0,
        end_lnum = 16,
        end_col = 3,
        children = {
          {
            kind = "Method",
            name = "before",
            level = 1,
            lnum = 10,
            col = 2,
            end_lnum = 11,
            end_col = 5,
          },
          {
            kind = "Method",
            name = "after",
            level = 1,
            lnum = 12,
            col = 2,
            end_lnum = 13,
            end_col = 5,
          },
          {
            kind = "Method",
            name = "it should describe the test",
            level = 1,
            lnum = 14,
            col = 2,
            end_lnum = 15,
            end_col = 5,
          },
        },
      },
    })
  end)
end)
