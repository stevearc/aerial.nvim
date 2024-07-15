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
  for _, filename in ipairs(list_files("tests/treesitter")) do
    local filepath = "./tests/treesitter/" .. filename
    local basename = vim.fn.fnamemodify(filename, ":r")
    local symbols_file = "./tests/symbols/" .. basename .. ".json"
    it(filename, function()
      util.test_file_symbols("treesitter", filepath, symbols_file)
    end)

    if filename == "markdown_test.md" then
      it("<markdown backend> " .. filename, function()
        util.test_file_symbols("markdown", filepath, "./tests/symbols/markdown_backend.json")
      end)
    end
  end

  util.test_file_symbols("man", "./tests/man_test.txt", "./tests/symbols/man.json")
end)
