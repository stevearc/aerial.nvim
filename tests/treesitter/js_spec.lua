local util = require("tests.test_util")

describe("treesitter js", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("treesitter", "./tests/treesitter/js_test.js", {
      {
        kind = "Class",
        name = "Cl_1",
        level = 0,
        lnum = 1,
        col = 0,
        children = {
          {
            kind = "Method",
            name = "meth_1",
            level = 1,
            lnum = 2,
            col = 2,
          },
        },
      },
      {
        kind = "Function",
        name = "fn_1",
        level = 0,
        lnum = 5,
        col = 0,
      },
      {
        kind = "Function",
        name = "describe UnitTest",
        level = 0,
        lnum = 7,
        col = 0,
        children = {
          {
            kind = "Function",
            name = "afterAll",
            level = 1,
            lnum = 8,
            col = 2,
          },
          {
            kind = "Function",
            name = "afterEach",
            level = 1,
            lnum = 9,
            col = 2,
          },
          {
            kind = "Function",
            name = "beforeAll",
            level = 1,
            lnum = 10,
            col = 2,
          },
          {
            kind = "Function",
            name = "beforeEach",
            level = 1,
            lnum = 11,
            col = 2,
          },
          {
            kind = "Function",
            name = "test should describe the test",
            level = 1,
            lnum = 12,
            col = 2,
          },
          {
            kind = "Function",
            name = "it is an alias for test",
            level = 1,
            lnum = 13,
            col = 2,
          },
          {
            kind = "Function",
            name = "test.skip skip this test",
            level = 1,
            lnum = 14,
            col = 2,
          },
          {
            kind = "Function",
            name = "test.todo this is a todo",
            level = 1,
            lnum = 15,
            col = 2,
          },
          {
            kind = "Function",
            name = "describe.each Test Suite",
            level = 1,
            lnum = 16,
            col = 2,
            children = {
              {
                kind = "Function",
                name = "test.each runs multiple times",
                level = 2,
                lnum = 17,
                col = 4,
              },
            },
          },
        },
      },
    })
  end)
end)
