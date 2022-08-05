require("plenary.async").tests.add_to_env()
local aerial = require("aerial")

a.describe("config", function()
  after_each(function()
    aerial.setup({})
    for i, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if i > 1 then
        vim.api.nvim_win_close(winid, true)
      end
    end
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_option(bufnr, "buflisted") then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end
  end)

  a.it("can open relative to the window, to the left", function()
    aerial.setup({
      layout = {
        default_direction = "left",
        placement = "window",
      },
    })
    vim.cmd("edit README.md")
    vim.cmd("AerialToggle")
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
    vim.cmd("AerialToggle")
    local winid = vim.api.nvim_tabpage_list_wins(0)[2]
    local aer_bufnr = vim.api.nvim_win_get_buf(winid)
    assert.equals("aerial", vim.api.nvim_buf_get_option(aer_bufnr, "filetype"))
  end)

  a.it("can open aerial in float", function()
    vim.cmd("edit README.md")
    vim.cmd("AerialToggle float")
    local winid = vim.api.nvim_tabpage_list_wins(0)[2]
    local aer_bufnr = vim.api.nvim_win_get_buf(winid)
    assert.equals("aerial", vim.api.nvim_buf_get_option(aer_bufnr, "filetype"))
    assert(require("aerial.util").is_floating_win(winid))
  end)
end)
