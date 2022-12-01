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

---@return integer
local function num_wins()
  return #vim.api.nvim_tabpage_list_wins(0)
end

---@return integer
local function num_aerial_wins()
  local ret = 0
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if util.is_aerial_win(winid) then
      ret = ret + 1
    end
  end
  return ret
end

a.describe("config attach_mode = 'window'", function()
  after_each(function()
    test_util.reset_editor()
  end)

  a.it("opens one aerial window per source window", function()
    aerial.setup({
      attach_mode = "window",
    })
    vim.cmd.edit({ args = { "README.md" } })
    aerial.open({ focus = false })
    vim.cmd.vsplit()
    aerial.toggle()
    assert.equals(4, num_wins())
    assert.equals(2, num_aerial_wins())
  end)

  a.it("updates symbols when changing to unsupported buffer", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "window",
    })
    vim.cmd.edit({ args = { "README.md" } })
    aerial.toggle({ focus = false })
    local aerial_win = util.get_aerial_win(0)
    assert.is_not_nil(aerial_win)
    -- Wait for symbols to populate
    sleep(1)
    assert.falsy(has_no_symbols(vim.api.nvim_win_get_buf(aerial_win)))
    vim.cmd.edit({ args = { "LICENSE" } })
    -- Wait for autocmd to run and attached buffer to switch
    sleep(10)
    local aerial_buf = vim.api.nvim_win_get_buf(aerial_win)
    assert.truthy(loading.is_loading(aerial_buf))
    sleep(50)
    assert.falsy(loading.is_loading(aerial_buf))
    assert.truthy(has_no_symbols(vim.api.nvim_win_get_buf(aerial_win)))
  end)

  a.it(
    "close_automatic_events = 'unsupported' closes aerial when entering unsupported buffer",
    function()
      aerial.setup({
        lazy_load = false,
        attach_mode = "window",
        close_automatic_events = { "unsupported" },
      })
      vim.cmd.edit({ args = { "README.md" } })
      aerial.toggle({ focus = false })
      local aerial_win = util.get_aerial_win(0)
      assert.is_not_nil(aerial_win)
      -- Wait for symbols to populate
      sleep(1)
      vim.cmd.edit({ args = { "LICENSE" } })
      -- Wait for autocmd to run and attached buffer to switch
      sleep(50)
      assert.falsy(vim.api.nvim_win_is_valid(aerial_win))
    end
  )

  a.it("close_automatic_events = 'unfocus' closes aerial when leaving window", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "window",
      close_automatic_events = { "unfocus" },
    })
    vim.cmd.edit({ args = { "README.md" } })
    local main_win = vim.api.nvim_get_current_win()
    aerial.toggle({ focus = true })
    local aerial_win = vim.api.nvim_get_current_win()
    assert.is_not.equals(main_win, aerial_win)
    assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
    -- Wait for symbols to populate
    sleep(1)
    vim.api.nvim_set_current_win(main_win)
    sleep(10)
    assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
    vim.cmd.vsplit()
    sleep(10)
    assert.falsy(vim.api.nvim_win_is_valid(aerial_win))
  end)

  a.it(
    "close_automatic_events = 'switch_buffer' closes aerial when buffer in window changes",
    function()
      aerial.setup({
        lazy_load = false,
        attach_mode = "window",
        close_automatic_events = { "switch_buffer" },
      })
      vim.cmd.edit({ args = { "README.md" } })
      aerial.toggle({ focus = false })
      local aerial_win = util.get_aerial_win(0)
      assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
      -- Wait for symbols to populate
      sleep(1)
      vim.cmd.edit({ args = { "doc/api.md" } })
      sleep(10)
      assert.falsy(vim.api.nvim_win_is_valid(aerial_win))
    end
  )
end)

a.describe("config attach_mode = 'global'", function()
  after_each(function()
    test_util.reset_editor()
  end)

  a.it("opens one aerial window ever", function()
    aerial.setup({
      attach_mode = "global",
    })
    vim.cmd.edit({ args = { "README.md" } })
    aerial.open({ focus = false })
    vim.cmd.vsplit()
    sleep(10)
    aerial.open()
    assert.equals(3, num_wins())
    assert.equals(1, num_aerial_wins())
  end)

  a.it("updates symbols when changing to unsupported buffer", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "global",
    })
    vim.cmd.edit({ args = { "README.md" } })
    aerial.toggle({ focus = false })
    local aerial_win = util.get_aerial_win(0)
    assert.is_not_nil(aerial_win)
    -- Wait for symbols to populate
    sleep(1)
    assert.falsy(has_no_symbols(vim.api.nvim_win_get_buf(aerial_win)))
    vim.cmd.edit({ args = { "LICENSE" } })
    -- Wait for autocmd to run and attached buffer to switch
    sleep(10)
    local aerial_buf = vim.api.nvim_win_get_buf(aerial_win)
    assert.truthy(loading.is_loading(aerial_buf))
    sleep(50)
    assert.falsy(loading.is_loading(aerial_buf))
    assert.truthy(has_no_symbols(vim.api.nvim_win_get_buf(aerial_win)))
  end)

  a.it(
    "close_automatic_events = 'unsupported' closes aerial when entering unsupported buffer",
    function()
      aerial.setup({
        lazy_load = false,
        attach_mode = "global",
        close_automatic_events = { "unsupported" },
      })
      vim.cmd.edit({ args = { "README.md" } })
      aerial.toggle({ focus = false })
      local aerial_win = util.get_aerial_win(0)
      assert.is_not_nil(aerial_win)
      -- Wait for symbols to populate
      sleep(1)
      vim.cmd.edit({ args = { "LICENSE" } })
      -- Wait for autocmd to run and attached buffer to switch
      sleep(50)
      assert.falsy(vim.api.nvim_win_is_valid(aerial_win))
    end
  )

  a.it("close_automatic_events = 'unfocus' closes aerial when leaving window", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "global",
      close_automatic_events = { "unfocus" },
    })
    vim.cmd.edit({ args = { "README.md" } })
    local main_win = vim.api.nvim_get_current_win()
    aerial.toggle({ focus = true })
    local aerial_win = vim.api.nvim_get_current_win()
    assert.is_not.equals(main_win, aerial_win)
    assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
    -- Wait for symbols to populate
    sleep(1)
    vim.api.nvim_set_current_win(main_win)
    sleep(10)
    assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
    vim.cmd.vsplit()
    sleep(10)
    assert.falsy(vim.api.nvim_win_is_valid(aerial_win))
  end)

  a.it(
    "close_automatic_events = 'switch_buffer' closes aerial when buffer in window changes",
    function()
      aerial.setup({
        lazy_load = false,
        attach_mode = "global",
        close_automatic_events = { "switch_buffer" },
      })
      vim.cmd.edit({ args = { "README.md" } })
      aerial.toggle({ focus = false })
      local aerial_win = util.get_aerial_win(0)
      assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
      -- Wait for symbols to populate
      sleep(1)
      vim.cmd.edit({ args = { "doc/api.md" } })
      sleep(10)
      assert.falsy(vim.api.nvim_win_is_valid(aerial_win))
    end
  )

  a.it("open_automatic = true opens aerial when entering supported buffer", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "global",
      open_automatic = true,
    })
    vim.cmd.edit({ args = { "README.md" } })
    sleep(30)
    local aerial_win = util.get_aerial_win(0)
    assert.truthy(vim.api.nvim_win_is_valid(aerial_win))
  end)

  a.it("open_automatic = true does not open aerial when entering unsupported buffer", function()
    aerial.setup({
      lazy_load = false,
      attach_mode = "global",
      open_automatic = true,
    })
    vim.cmd.edit({ args = { "LICENSE" } })
    sleep(30)
    local aerial_win = util.get_aerial_win(0)
    assert.is_nil(aerial_win)
  end)
end)
