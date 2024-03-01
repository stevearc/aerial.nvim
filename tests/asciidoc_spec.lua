local util = require("tests.test_util")

describe("asciidoc", function()
  it("asciidoc_test.adoc", function()
    util.test_file_symbols(
      "asciidoc",
      "./tests/static/asciidoc_test.adoc",
      "./tests/symbols/asciidoc_backend.json"
    )
  end)
end)
