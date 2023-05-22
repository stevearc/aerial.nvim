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
    assert.equals("aerial", vim.bo[aer_bufnr].filetype)
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
    assert.equals("aerial", vim.bo[aer_bufnr].filetype)
  end)

  a.it("can open aerial in float", function()
    vim.cmd("edit README.md")
    aerial.toggle({ direction = "float" })
    local winid = vim.api.nvim_tabpage_list_wins(0)[2]
    local aer_bufnr = vim.api.nvim_win_get_buf(winid)
    assert.equals("aerial", vim.bo[aer_bufnr].filetype)
    assert(require("aerial.util").is_floating_win(winid))
  end)

  a.it("can open aerial in a specific window (not current)", function()
    local target_win = vim.api.nvim_get_current_win()
    vim.cmd("edit README.md")
    vim.cmd.vsplit()
    aerial.open_in_win(target_win, 0)
    local aer_bufnr = vim.api.nvim_win_get_buf(target_win)
    assert.equals("aerial", vim.bo[aer_bufnr].filetype)
    assert.truthy(vim.api.nvim_buf_get_name(0):match("README.md$"))
  end)

  a.it("can open aerial in a specific (current) window", function()
    local source_win = vim.api.nvim_get_current_win()
    vim.cmd("edit README.md")
    vim.cmd.vsplit()
    local target_win = vim.api.nvim_get_current_win()
    aerial.open_in_win(target_win, source_win)
    local source_bufnr = vim.api.nvim_win_get_buf(source_win)
    assert.equals("aerial", vim.bo.filetype)
    assert.truthy(vim.api.nvim_buf_get_name(source_bufnr):match("README.md$"))
  end)
end)
