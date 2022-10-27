require("plenary.async").tests.add_to_env()
local aerial = require("aerial")
local sleep = require("plenary.async.util").sleep
local loading = require("aerial.loading")
local test_util = require("tests.test_util")
local util = require("aerial.util")

---@param bufnr integer
---@return boolean
local function has_no_symbols(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)) do
    if line:match("^%s*No symbols%s*$") then
      return true
    elseif not line:match("^%s*$") then
      return false
    end
  end
  return false
end

a.describe("config", function()
  after_each(function()
    test_util.reset_editor()
  end)

  a.it("attach_mode = 'window' updates symbols when changing to unsupported buffer", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "window",
    })
    vim.cmd("edit README.md")
    aerial.toggle({ focus = false })
    local aerial_win = util.get_aerial_win(0)
    assert.is_not_nil(aerial_win)
    -- Wait for symbols to populate
    sleep(1)
    assert.falsy(has_no_symbols(vim.api.nvim_win_get_buf(aerial_win)))
    vim.cmd("edit LICENSE")
    -- Wait for autocmd to run and attached buffer to switch
    sleep(10)
    local aerial_buf = vim.api.nvim_win_get_buf(aerial_win)
    assert.truthy(loading.is_loading(aerial_buf))
    sleep(50)
    assert.falsy(loading.is_loading(aerial_buf))
    assert.truthy(has_no_symbols(vim.api.nvim_win_get_buf(aerial_win)))
  end)
end)
