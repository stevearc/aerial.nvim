require("plenary.async").tests.add_to_env()
local aerial = require("aerial")
local test_util = require("tests.test_util")

a.describe("layout", function()
  after_each(function()
    test_util.reset_editor()
  end)

  a.it("can open relative to the window, to the left", function()
    aerial.setup({
      layout = {
        default_direction = "left",
        placement = "window",
      },
    })
    vim.cmd("edit README.md")
    aerial.toggle()
    local winid = vim.api.nvim_tabpage_list_wins(0)[1]
    local aer_bufnr = vim.api.nvim_win_get_buf(winid)
    assert.equals("aerial", vim.api.nvim_buf_get_option(aer_bufnr, "filetype"))
  end)

  a.it("can open relative to the window, to the right", function()
    aerial.setup({
      layout = {
        default_direction = "right",
        placement = "window",
      },
    })
    vim.cmd("edit README.md")
    aerial.toggle()
    local winid = vim.api.nvim_tabpage_list_wins(0)[2]
    local aer_bufnr = vim.api.nvim_win_get_buf(winid)
    assert.equals("aerial", vim.api.nvim_buf_get_option(aer_bufnr, "filetype"))
  end)

  a.it("can open aerial in float", function()
    vim.cmd("edit README.md")
    aerial.toggle({ direction = "float" })
    local winid = vim.api.nvim_tabpage_list_wins(0)[2]
    local aer_bufnr = vim.api.nvim_win_get_buf(winid)
    assert.equals("aerial", vim.api.nvim_buf_get_option(aer_bufnr, "filetype"))
    assert(require("aerial.util").is_floating_win(winid))
  end)
end)
