local util = require("tests.test_util")

describe("treesitter rust", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("./tests/treesitter/rust_test.rs", {
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
            name = "St_1",
            level = 1,
            lnum = 6,
            col = 4,
          },
        },
      },
    })
  end)
end)
