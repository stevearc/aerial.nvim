local util = require("tests.test_util")

describe("treesitter man", function()
  it("parses all symbols correctly", function()
    util.test_file_symbols("man", "./tests/treesitter/man_test.txt", {
      {
        kind = "Interface",
        name = "NAME",
        level = 0,
        lnum = 3,
        col = 0,
        end_lnum = 5,
        end_col = 0,
      },
      {
        kind = "Interface",
        name = "SYNOPSIS",
        level = 0,
        lnum = 6,
        col = 0,
        end_lnum = 9,
        end_col = 0,
      },
      {
        kind = "Interface",
        name = "DESCRIPTION",
        level = 0,
        lnum = 10,
        col = 0,
        end_lnum = 29,
        end_col = 0,
        children = {
          {
            kind = "Interface",
            name = "-4      Forces nc to use IPv4 addresses only.",
            level = 1,
            lnum = 24,
            col = 5,
            end_lnum = 24,
            end_col = 50,
          },
          {
            kind = "Interface",
            name = "-6      Forces nc to use IPv6 addresses only.",
            level = 1,
            lnum = 26,
            col = 5,
            end_lnum = 26,
            end_col = 50,
          },
          {
            kind = "Interface",
            name = "-A      Set SO_RECV_ANYIF on socket.",
            level = 1,
            lnum = 28,
            col = 5,
            end_lnum = 28,
            end_col = 41,
          },
        },
      },
      {
        kind = "Interface",
        name = "CLIENT/SERVER MODEL",
        level = 0,
        lnum = 30,
        col = 0,
        end_lnum = 42,
        end_col = 11,
      },
    })
  end)
end)
