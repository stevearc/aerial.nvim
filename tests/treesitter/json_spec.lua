local util = require("tests.test_util")

describe("treesitter json", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/json_test.json", {
      {
        kind = "Class",
        name = "obj1",
        level = 0,
        lnum = 3,
        col = 2,
        end_lnum = 3,
        end_col = 12,
      },
      {
        kind = "Class",
        name = "obj2",
        level = 0,
        lnum = 4,
        col = 2,
        end_lnum = 8,
        end_col = 3,
        children = {
          {
            kind = "Class",
            name = "obj3",
            level = 1,
            lnum = 5,
            col = 4,
            end_lnum = 7,
            end_col = 5,
          },
        },
      },
    })
  end)
end)
