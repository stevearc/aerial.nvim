local util = require("tests.test_util")

describe("treesitter rust", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/rust_test.rs", {
      {
        kind = "Module",
        name = "mod_1",
        level = 0,
        lnum = 1,
        col = 0,
        children = {
          {
            kind = "Enum",
            name = "Enum_1",
            level = 1,
            lnum = 2,
            col = 4,
          },
          {
            kind = "Function",
            name = "Fn_1",
            level = 1,
            lnum = 4,
            col = 4,
          },
          {
            kind = "Struct",
            name = "MyStruct",
            level = 1,
            lnum = 6,
            col = 4,
          },
          {
            kind = "Interface",
            name = "MyTrait",
            level = 1,
            lnum = 8,
            col = 4,
            children = {
              {
                kind = "Function",
                name = "TraitFn",
                level = 2,
                lnum = 9,
                col = 8,
              },
            },
          },
          {
            kind = "Class",
            name = "MyStruct",
            level = 1,
            lnum = 12,
            col = 4,
            children = {
              {
                kind = "Function",
                name = "StructFn",
                level = 2,
                lnum = 13,
                col = 8,
              },
            },
          },
          {
            kind = "Class",
            name = "MyStruct > Display",
            level = 1,
            lnum = 16,
            col = 4,
            children = {
              {
                kind = "Function",
                name = "fmt",
                level = 2,
                lnum = 17,
                col = 8,
              },
            },
          },
        },
      },
    })
  end)
end)
