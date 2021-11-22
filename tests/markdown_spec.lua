local util = require("tests.test_util")

describe("markdown", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("markdown", "./tests/markdown_test.md", {
      {
        kind = "Interface",
        name = "Title 1",
        level = 0,
        lnum = 1,
        col = 0,
        children = {
          {
            kind = "Interface",
            name = "Title 2",
            level = 1,
            lnum = 3,
            col = 0,
          },
        },
      },
      {
        kind = "Interface",
        name = "Title 3",
        level = 0,
        lnum = 5,
        col = 0,
        children = {
          {
            kind = "Interface",
            name = "Title 4",
            level = 2,
            lnum = 7,
            col = 0,
            children = {
              {
                kind = "Interface",
                name = "Title 5",
                level = 3,
                lnum = 13,
                col = 0,
              },
            },
          },
        },
      },
    })
  end)
end)
