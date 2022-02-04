local util = require("tests.test_util")

describe("treesitter julia", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/julia_test.jl", {
      {
        kind = "Module",
        name = "mod",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 20,
        end_col = 3,
        children = {
          {
            kind = "Constant",
            name = "constant",
            level = 1,
            lnum = 3,
            col = 0,
            end_lnum = 3,
            end_col = 24,
          },
          {
            kind = "Function",
            name = "func",
            level = 1,
            lnum = 5,
            col = 0,
            end_lnum = 6,
            end_col = 3,
          },
          {
            kind = "Function",
            name = "myfunc",
            level = 1,
            lnum = 8,
            col = 0,
            end_lnum = 8,
            end_col = 18,
          },
          {
            kind = "Interface",
            name = "MyType",
            level = 1,
            lnum = 10,
            col = 0,
            end_lnum = 10,
            end_col = 24,
          },
          {
            kind = "Class",
            name = "MyStruct",
            level = 1,
            lnum = 12,
            col = 0,
            end_lnum = 15,
            end_col = 3,
            children = {
              {
                kind = "Function",
                name = "MyStruct",
                level = 2,
                lnum = 13,
                col = 4,
                end_lnum = 13,
                end_col = 22,
              },
              {
                kind = "Function",
                name = "method",
                level = 2,
                lnum = 14,
                col = 4,
                end_lnum = 14,
                end_col = 22,
              },
            },
          },
          {
            kind = "Function",
            name = "mac",
            level = 1,
            lnum = 17,
            col = 0,
            end_lnum = 18,
            end_col = 3,
          },
        },
      },
    })
  end)
end)
