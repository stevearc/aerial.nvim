local util = require("tests.test_util")

describe("treesitter scala", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/scala_test.scala", {
      {
        kind = "Class",
        name = "Object",
        level = 0,
        lnum = 1,
        col = 0,
        end_lnum = 5,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "foo",
            level = 1,
            lnum = 2,
            col = 2,
            end_lnum = 4,
            end_col = 3,
          },
        },
      },
      {
        kind = "Interface",
        name = "Trait",
        level = 0,
        lnum = 7,
        col = 0,
        end_lnum = 9,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "foo",
            level = 1,
            lnum = 8,
            col = 2,
            end_lnum = 8,
            end_col = 23,
          },
        },
      },
      {
        kind = "Class",
        name = "Class",
        level = 0,
        lnum = 11,
        col = 0,
        end_lnum = 18,
        end_col = 1,
        children = {
          {
            kind = "Function",
            name = "foo",
            level = 1,
            lnum = 12,
            col = 2,
            end_lnum = 14,
            end_col = 3,
          },
          {
            kind = "Function",
            name = "bar",
            level = 1,
            lnum = 15,
            col = 2,
            end_lnum = 17,
            end_col = 3,
          },
        },
      },
    })
  end)
end)
