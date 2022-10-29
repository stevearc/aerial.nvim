local util = require("tests.test_util")

describe("treesitter latex", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/latex_test.tex", {
      {
        kind = "Function",
        name = "\\abs",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 3,
        end_col = 38,
      },
      {
        kind = "Field",
        name = "Title: Lorem Ipsum",
        level = 0,
        lnum = 5,
        col = 0,
        end_lnum = 5,
        end_col = 19,
      },
      {
        kind = "Field",
        name = "Authors: John Doe",
        level = 0,
        lnum = 6,
        col = 0,
        end_lnum = 6,
        end_col = 17,
      },
      {
        kind = "Class",
        name = "document",
        level = 0,
        lnum = 8,
        col = 0,
        end_lnum = 24,
        end_col = 14,
        children = {
          {
            kind = "Method",
            name = "First section",
            level = 1,
            lnum = 10,
            col = 0,
            end_lnum = 20,
            end_col = 24,
            children = {
              {
                kind = "Method",
                name = "A subsection",
                level = 2,
                lnum = 14,
                col = 0,
                end_lnum = 20,
                end_col = 24,
                children = {
                  {
                    kind = "Method",
                    name = "A subsubsection",
                    level = 3,
                    lnum = 18,
                    col = 0,
                    end_lnum = 20,
                    end_col = 24,
                  },
                },
              },
            },
          },
          {
            kind = "Method",
            name = "This is another subsection",
            level = 1,
            lnum = 22,
            col = 0,
            end_lnum = 22,
            end_col = 36,
          },
        },
      },
    })
  end)
end)
