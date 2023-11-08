require("plenary.async").tests.add_to_env()
local aerial = require("aerial")
local backends = require("aerial.backends")
local test_util = require("tests.test_util")
local window = require("aerial.window")

local markdown_content = [[
# First symbol

# Second symbol

# Third symbol
]]

local markdown_nested_content = [[
# One

## One.A

## One.B

# Two

## Two.A
]]

local function create_md_buf(content)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, vim.split(content, "\n"))
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].filetype = "markdown"
  backends.attach()
end

a.describe("navigation", function()
  before_each(function()
    aerial.setup({
      ignore = {
        buftypes = false,
      },
    })
    aerial.sync_load()
  end)
  after_each(function()
    test_util.reset_editor()
  end)

  a.describe("select", function()
    a.it("select jumps to location", function()
      create_md_buf(markdown_content)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      aerial.select({ index = 2 })
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.are.same({ 3, 2 }, cursor)
    end)

    a.it("in aerial window jumps to location", function()
      create_md_buf(markdown_content)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      aerial.toggle()
      assert.equals("aerial", vim.bo.filetype)
      aerial.select({ index = 2 })
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.are.same({ 3, 2 }, cursor)
    end)

    a.it("in aerial window uses cursor position as index", function()
      create_md_buf(markdown_content)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      aerial.toggle()
      a.util.sleep(10) -- let the aerial window render
      assert.equals("aerial", vim.bo.filetype)
      vim.api.nvim_win_set_cursor(0, { 3, 0 })
      aerial.select()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.are.same({ 5, 2 }, cursor)
    end)

    a.it("doesn't have to jump", function()
      create_md_buf(markdown_content)
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
      assert.are.same({ 5, 2 }, cursor)
    end)

    a.it("can open a new split when jumping", function()
      create_md_buf(markdown_content)
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
      assert.are.same({ 5, 2 }, vim.api.nvim_win_get_cursor(0))
    end)
  end)

  a.describe("movement", function()
    a.it("can go to next symbol", function()
      create_md_buf(markdown_nested_content)
      vim.api.nvim_win_set_cursor(0, { 1, 2 })
      window.update_position() -- Not sure why the CursorMoved autocmd doesn't fire
      aerial.next()
      assert.are.same({ 3, 3 }, vim.api.nvim_win_get_cursor(0))
    end)

    a.it("can go to next N symbol", function()
      create_md_buf(markdown_nested_content)
      vim.api.nvim_win_set_cursor(0, { 1, 2 })
      window.update_position() -- Not sure why the CursorMoved autocmd doesn't fire
      aerial.next(2)
      assert.are.same({ 5, 3 }, vim.api.nvim_win_get_cursor(0))
    end)

    a.it("can go to prev symbol", function()
      create_md_buf(markdown_nested_content)
      vim.api.nvim_win_set_cursor(0, { 3, 2 })
      window.update_position() -- Not sure why the CursorMoved autocmd doesn't fire
      aerial.prev()
      assert.are.same({ 1, 2 }, vim.api.nvim_win_get_cursor(0))
    end)

    a.it("can go to prev N symbol", function()
      create_md_buf(markdown_nested_content)
      vim.api.nvim_win_set_cursor(0, { 5, 2 })
      window.update_position() -- Not sure why the CursorMoved autocmd doesn't fire
      aerial.prev(2)
      assert.are.same({ 1, 2 }, vim.api.nvim_win_get_cursor(0))
    end)

    a.it("can go up and backwards in the tree", function()
      create_md_buf(markdown_nested_content)
      vim.api.nvim_win_set_cursor(0, { 5, 2 })
      window.update_position() -- Not sure why the CursorMoved autocmd doesn't fire
      aerial.prev_up()
      assert.are.same({ 1, 2 }, vim.api.nvim_win_get_cursor(0))
    end)

    a.it("can go up and forwards in the tree", function()
      create_md_buf(markdown_nested_content)
      vim.api.nvim_win_set_cursor(0, { 3, 2 })
      window.update_position() -- Not sure why the CursorMoved autocmd doesn't fire
      aerial.next_up()
      assert.are.same({ 7, 2 }, vim.api.nvim_win_get_cursor(0))
    end)
  end)
end)
