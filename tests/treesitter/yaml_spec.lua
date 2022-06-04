local util = require("tests.test_util")

describe("treesitter yaml", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/yaml_test.yml", {
      {
        kind = "Class",
        name = "services",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 10,
        end_col = 24,
        children = {
          {
            kind = "Class",
            name = "proxy",
            level = 1,
            lnum = 4,
            col = 2,
            end_lnum = 7,
            end_col = 15,
            children = {
              {
                kind = "Enum",
                name = "ports",
                level = 2,
                lnum = 6,
                col = 4,
                end_lnum = 7,
                end_col = 15,
              },
            },
          },
          {
            kind = "Class",
            name = "db",
            level = 1,
            lnum = 9,
            col = 2,
            end_lnum = 10,
            end_col = 24,
          },
        },
      },
      {
        kind = "Class",
        name = "volumes",
        level = 0,
        lnum = 12,
        col = 0,
        end_lnum = 14,
        end_col = 18,
        children = {
          {
            kind = "Class",
            name = "media-volume",
            level = 1,
            lnum = 13,
            col = 2,
            end_lnum = 14,
            end_col = 18,
          },
        },
      },
      {
        kind = "Class",
        name = "networks",
        level = 0,
        lnum = 16,
        col = 0,
        end_lnum = 18,
        end_col = 0,
      },
    })
  end)
end)
