local util = require("tests.test_util")

describe("treesitter ts", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/ts_test.ts", {
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 1,
        col = 0,
      },
      {
        kind = "Function",
        name = "fn_2",
        level = 0,
        lnum = 3,
        col = 0,
      },
      {
        kind = "Interface",
        name = "Iface_1",
        level = 0,
        lnum = 5,
        col = 0,
      },
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 7,
        col = 0,
        children = {
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 8,
            col = 2,
          },
        },
      },
      {
        kind = "Type",
        name = "Type1",
        level = 0,
        lnum = 11,
        col = 0,
      },
    })
  end)
end)
