local util = require("tests.test_util")

describe("treesitter java", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/java_test.java", {
      {
        kind = "Interface",
        name = "Iface_1",
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
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 5,
        col = 0,
        children = {
          {
            kind = "Method",
            name = "meth_2",
            level = 1,
            lnum = 6,
            col = 2,
          },
        },
      },
      {
        kind = "Enum",
        name = "En_1",
        level = 0,
        lnum = 9,
        col = 0,
      },
    })
  end)
end)
