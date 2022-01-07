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
        children = {
          {
            kind = "Constant",
            name = "constant",
            level = 1,
            lnum = 3,
            col = 0,
          },
          {
            kind = "Function",
            name = "func",
            level = 1,
            lnum = 5,
            col = 0,
          },
          {
            kind = "Function",
            name = "myfunc",
            level = 1,
            lnum = 8,
            col = 0,
          },
          {
            kind = "Interface",
            name = "MyType",
            level = 1,
            lnum = 10,
            col = 0,
          },
          {
            kind = "Class",
            name = "MyStruct",
            level = 1,
            lnum = 12,
            col = 0,
            children = {
              {
                kind = "Function",
                name = "MyStruct",
                level = 2,
                lnum = 13,
                col = 4,
              },
              {
                kind = "Function",
                name = "method",
                level = 2,
                lnum = 14,
                col = 4,
              },
            },
          },
          {
            kind = "Function",
            name = "mac",
            level = 1,
            lnum = 17,
            col = 0,
          },
        },
      },
    })
  end)
end)
