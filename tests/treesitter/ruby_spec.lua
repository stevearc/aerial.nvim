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
        children = {
          {
            kind = "Class",
            name = "Cl_1",
            level = 1,
            lnum = 2,
            col = 2,
            children = {
              {
                kind = "Method",
                name = "meth_1",
                level = 2,
                lnum = 3,
                col = 4,
              },
            },
          },
          {
            kind = "Method",
            name = "meth_2",
            level = 1,
            lnum = 6,
            col = 2,
          },
        },
      },
    })
  end)
end)
