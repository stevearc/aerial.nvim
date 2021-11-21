local util = require("tests.test_util")

describe("treesitter csharp", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/csharp_test.cs", {
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 1,
        col = 0,
        children = {
          {
            kind = "Constructor",
            name = "Cl_1",
            level = 1,
            lnum = 2,
            col = 2,
          },
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 3,
            col = 2,
          },
        },
      },
      {
        kind = "Enum",
        name = "En_1",
        level = 0,
        lnum = 5,
        col = 0,
      },
      {
        kind = "Struct",
        name = "St_1",
        level = 0,
        lnum = 6,
        col = 0,
      },
    })
  end)
end)
