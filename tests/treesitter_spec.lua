local util = require("tests.test_util")

---@param dir string
---@return string[]
local function list_files(dir)
  ---@diagnostic disable-next-line: param-type-mismatch
  local fd = vim.loop.fs_opendir(dir, nil, 32)
  ---@diagnostic disable-next-line: param-type-mismatch
  local entries = vim.loop.fs_readdir(fd)
  local ret = {}
  while entries do
    for _, entry in ipairs(entries) do
      if entry.type == "file" then
        table.insert(ret, entry.name)
      end
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    entries = vim.loop.fs_readdir(fd)
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.loop.fs_closedir(fd)
  return ret
end

describe("treesitter", function()
  local skip_tests = {}
  if vim.fn.has("nvim-0.11") == 0 then
    -- ABI version mismatch
    table.insert(skip_tests, "enforce_test.c")
  end

  for _, filename in ipairs(list_files("tests/treesitter")) do
    if vim.tbl_contains(skip_tests, filename) then
      print("Skipping test", filename)
      goto continue
    end
    local filepath = "./tests/treesitter/" .. filename
    local basename = vim.fn.fnamemodify(filename, ":r")
    local symbols_file = "./tests/symbols/" .. basename .. ".json"
    if not vim.env.TS_TEST or vim.env.TS_TEST == basename then
      it(filename, function()
        util.test_file_symbols("treesitter", filepath, symbols_file)
      end)
    end

    if filename == "markdown_test.md" and not vim.env.TS_TEST then
      it("<markdown backend> " .. filename, function()
        util.test_file_symbols("markdown", filepath, "./tests/symbols/markdown_backend.json")
      end)
    end
    ::continue::
  end

  util.test_file_symbols("man", "./tests/man_test.txt", "./tests/symbols/man.json")
end)
