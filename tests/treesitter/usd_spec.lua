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
        end_lnum = 21,
        end_col = 1,
        children = {
          {
            kind = "Class",
            name = "child",
            level = 1,
            lnum = 7,
            col = 4,
            end_lnum = 20,
            end_col = 5,
            children = {
              {
                kind = "Property",
                name = "foo:xformOp:rotateXYZ",
                level = 2,
                lnum = 9,
                col = 8,
                end_lnum = 9,
                end_col = 58,
              },
              {
                kind = "Property",
                name = "translate",
                level = 2,
                lnum = 10,
                col = 8,
                end_lnum = 10,
                end_col = 48,
              },
              {
                kind = "Property",
                name = "thing",
                level = 2,
                lnum = 11,
                col = 8,
                end_lnum = 11,
                end_col = 32,
              },
              {
                kind = "Enum",
                name = "variants",
                level = 2,
                lnum = 13,
                col = 8,
                end_lnum = 19,
                end_col = 9,
                children = {
                  {
                    kind = "EnumMember",
                    name = "default",
                    level = 3,
                    lnum = 14,
                    col = 12,
                    end_lnum = 15,
                    end_col = 13,
                  },
                  {
                    kind = "EnumMember",
                    name = "one",
                    level = 3,
                    lnum = 16,
                    col = 12,
                    end_lnum = 18,
                    end_col = 13,
                    children = {
                      {
                        kind = "Property",
                        name = "xformOp:translate",
                        level = 4,
                        lnum = 17,
                        col = 16,
                        end_lnum = 17,
                        end_col = 56,
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    })
  end)
end)
