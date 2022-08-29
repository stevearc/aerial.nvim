local util = require("tests.test_util")

describe("treesitter proto", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/proto_test.proto", {
      {
        kind = "Class",
        name = "MessageA",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 11,
        end_col = 1,
        children = {
          {
            kind = "Enum",
            name = "Number",
            level = 1,
            lnum = 7,
            col = 2,
            end_lnum = 10,
            end_col = 3,
          },
        },
      },
      {
        kind = "Class",
        name = "MessageB",
        level = 0,
        lnum = 13,
        col = 0,
        end_lnum = 16,
        end_col = 1,
      },
    })
  end)
end)
