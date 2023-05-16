local util = require("tests.test_util")

describe("treesitter USD", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/usd_test.usd", {
      {
        kind = "Class",
        name = "something",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 3,
        end_col = 21,
        children = {
          {
            kind = "Class",
            name = "child",
            level = 1,
            lnum = 7,
            col = 5,
            end_lnum = 7,
            end_col = 21,
            children = {
              {
                kind = "Property",
                name = "foo:xformOp:rotateXYZ",
                level = 2,
                lnum = 9,
                col = 9,
                end_lnum = 9,
                end_col = 58,
              },
              {
                kind = "Property",
                name = "translate",
                level = 2,
                lnum = 10,
                col = 9,
                end_lnum = 10,
                end_col = 48,
              },
              {
                kind = "Property",
                name = "thing",
                level = 2,
                lnum = 11,
                col = 9,
                end_lnum = 11,
                end_col = 32,
              },
              {
                kind = "Enum",
                name = "variants",
                level = 2,
                lnum = 13,
                col = 9,
                end_lnum = 13,
                end_col = 31,
                children = {
                  {
                    kind = "EnumMember",
                    name = "default",
                    level = 3,
                    lnum = 14,
                    col = 13,
                    end_lnum = 14,
                    end_col = 21,
                  },
                  {
                    kind = "EnumMember",
                    name = "one",
                    level = 3,
                    lnum = 15,
                    col = 13,
                    end_lnum = 15,
                    end_col = 21,
                    children = {
                      {
                        kind = "Property",
                        name = "xformOp:translate",
                        level = 4,
                        lnum = 17,
                        col = 17,
                        end_lnum = 17,
                        end_col = 56,
                      },
                    }
                  },
                }
              },
            }
          },
        }
      },
    })
  end)
end)
