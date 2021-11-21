local util = require("tests.test_util")

describe("treesitter json", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/json_test.json", {
      {
        kind = "Class",
        name = "obj1",
        level = 0,
        lnum = 3,
        col = 2,
      },
      {
        kind = "Class",
        name = "obj2",
        level = 0,
        lnum = 4,
        col = 2,
        children = {
          {
            kind = "Class",
            name = "obj3",
            level = 1,
            lnum = 5,
            col = 4,
          },
        },
      },
    })
  end)
end)
