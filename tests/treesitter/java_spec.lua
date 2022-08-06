local util = require("tests.test_util")

describe("treesitter java", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/java_test.java", {
      {
        kind = "Interface",
        name = "Iface_1",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 3,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 2,
            col = 2,
            end_lnum = 2,
            end_col = 16,
          },
        },
      },
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 9,
        end_col = 1,
        children = {
          {
            kind = "Method",
            name = "meth_2",
            level = 1,
            lnum = 6,
            col = 2,
            end_lnum = 6,
            end_col = 19,
          },
          {
            kind = "Field",
            name = "field_1",
            level = 1,
            lnum = 7,
            col = 2,
            end_lnum = 7,
            end_col = 22,
          },
          {
            kind = "Field",
            name = "field_2",
            level = 1,
            lnum = 8,
            col = 2,
            end_lnum = 8,
            end_col = 24,
          },
        },
      },
      {
        kind = "Enum",
        name = "En_1",
        level = 0,
        lnum = 11,
        col = 0,
        end_lnum = 11,
        end_col = 13,
      },
    })
  end)
end)
