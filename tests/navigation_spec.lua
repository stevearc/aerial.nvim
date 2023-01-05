require("plenary.async").tests.add_to_env()
local aerial = require("aerial")
local backends = require("aerial.backends")
local config = require("aerial.config")
local test_util = require("tests.test_util")

local markdown_content = [[
# First symbol

# Second symbol

# Third symbol
]]

local function create_md_buf()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, vim.split(markdown_content, "\n"))
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].filetype = "markdown"
  backends.attach()
end

a.describe("navigation", function()
  before_each(function()
    config.setup()
  end)
  after_each(function()
    test_util.reset_editor()
  end)

  a.it("select jumps to location", function()
    create_md_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    aerial.select({ index = 2 })
    local cursor = vim.api.nvim_win_get_cursor(0)
    assert.are.same({ 3, 0 }, cursor)
  end)

  a.it("select in aerial window jumps to location", function()
    create_md_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    aerial.toggle()
    assert.equals("aerial", vim.bo.filetype)
    aerial.select({ index = 2 })
    local cursor = vim.api.nvim_win_get_cursor(0)
    assert.are.same({ 3, 0 }, cursor)
  end)

  a.it("select in aerial window uses cursor position as index", function()
    create_md_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    aerial.toggle()
    a.util.sleep(10) -- let the aerial window render
    assert.equals("aerial", vim.bo.filetype)
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    aerial.select()
    local cursor = vim.api.nvim_win_get_cursor(0)
    assert.are.same({ 5, 0 }, cursor)
  end)

  a.it("can select without jumping", function()
    create_md_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local winid = vim.api.nvim_get_current_win()
    aerial.toggle()
    a.util.sleep(10) -- let the aerial window render
    assert.equals("aerial", vim.bo.filetype)
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    aerial.select({ jump = false })

    -- We should still be in the aerial window
    assert.equals("aerial", vim.bo.filetype)
    -- The source window cursor should be updated
    local cursor = vim.api.nvim_win_get_cursor(winid)
    assert.are.same({ 5, 0 }, cursor)
  end)

  a.it("can open a new split when jumping", function()
    create_md_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local winid = vim.api.nvim_get_current_win()
    aerial.toggle()
    a.util.sleep(10) -- let the aerial window render
    assert.equals("aerial", vim.bo.filetype)
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    aerial.select({ split = "v" })

    assert.is_not.equals(winid, vim.api.nvim_get_current_win())
    assert.equals(3, #vim.api.nvim_tabpage_list_wins(0))

    -- Source window cursor should be the same
    assert.are.same({ 1, 0 }, vim.api.nvim_win_get_cursor(winid))
    -- Split window cursor should be updated
    assert.are.same({ 5, 0 }, vim.api.nvim_win_get_cursor(0))
  end)
end)
