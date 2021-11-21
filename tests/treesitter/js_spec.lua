local util = require("tests.test_util")

describe("treesitter js", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/js_test.js", {
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 1,
        col = 0,
        children = {
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 2,
            col = 2,
          },
        },
      },
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 5,
        col = 0,
      },
    })
  end)
end)
