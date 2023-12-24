-- Functions that are called in response to autocommands
local util = require("aerial.util")

local M = {}

local maybe_open_automatic = util.throttle(function()
  require("aerial.window").maybe_open_automatic()
end, { delay = 5, reset_timer_on_call = true })

---@param aer_win integer
---@return boolean
local function should_close_aerial(aer_win)
  local backends = require("aerial.backends")
  local config = require("aerial.config")
  local aer_buf = vim.api.nvim_win_get_buf(aer_win)
  local src_win = util.get_source_win(aer_win)
  -- If the aerial window has no valid source window, close it
  if not src_win then
    return true
  end
  local src_buf = util.get_source_buffer(aer_buf)

  -- Close the aerial window if its attached buffer is unsupported
  if config.close_automatic_events.unsupported then
    if not src_buf or not vim.api.nvim_buf_is_valid(src_buf) or not backends.get(src_buf) then
      return true
    end
  end
  return false
end

local function update_aerial_windows()
  local config = require("aerial.config")
  local window = require("aerial.window")
  local curwin = vim.api.nvim_get_current_win()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not vim.api.nvim_win_is_valid(winid) or not util.is_aerial_win(winid) then
      goto continue
    end
    local winbuf = vim.api.nvim_win_get_buf(winid)
    local src_win = util.get_source_win(winid)
    local src_buf
    if src_win then
      src_buf = vim.api.nvim_win_get_buf(src_win)
    end
    local close = false

    if config.close_automatic_events.unfocus and curwin ~= winid then
      -- Close the window if the aerial source win is not the current win
      if src_win ~= vim.api.nvim_get_current_win() then
        close = true
      end
    end
    if src_buf then
      -- Close the aerial window if its source window has switched buffers
      if config.close_automatic_events.switch_buffer then
        if src_buf ~= util.get_source_buffer(winbuf) then
          close = true
        end
      end
    end

    if config.attach_mode == "global" then
      window.open_aerial_in_win(0, 0, winid)
    elseif config.attach_mode == "window" then
      if src_win and src_buf then
        if util.get_source_win(winid) == vim.api.nvim_get_current_win() then
          window.open_aerial_in_win(src_buf, src_win, winid)
        end
      end
    end

    if close or should_close_aerial(winid) then
      vim.api.nvim_win_close(winid, true)
    end
    ::continue::
  end
end

M.on_enter_buffer = util.throttle(function()
  local backends = require("aerial.backends")
  local config = require("aerial.config")
  local fold = require("aerial.fold")
  local window = require("aerial.window")
  if util.is_ignored_win() then
    return
  end
  backends.attach()

  local mybuf = vim.api.nvim_get_current_buf()

  if util.is_aerial_buffer(mybuf) then
    local source_win = util.get_source_win()
    if
      (not source_win and config.attach_mode ~= "global")
      or vim.tbl_count(vim.api.nvim_tabpage_list_wins(0)) == 1
    then
      -- If aerial is the last window open, we must have closed the other windows. If the others
      -- were closed via "quit" or similar, we should quit neovim.
      local last_cmd = vim.fn.histget("cmd", -1)
      local cmd1 = last_cmd:sub(1, 1)
      local cmd2 = last_cmd:sub(1, 2)
      local cmd3 = last_cmd:sub(1, 3)
      if cmd2 == "wq" or cmd1 == "q" or cmd1 == "x" or cmd3 == "exi" then
        vim.cmd.quit()
      end
    end
    return
  end

  update_aerial_windows()

  -- If we're not in supported buffer
  local backend = backends.get()
  if not backend then
    fold.restore_foldmethod()
  else
    fold.maybe_set_foldmethod()
  end

  if not window.is_open() then
    maybe_open_automatic()
  end
end, { delay = 10, reset_timer_on_call = true })

M.attach_autocommands = function(bufnr)
  local data = require("aerial.data")
  local window = require("aerial.window")
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local group = vim.api.nvim_create_augroup("AerialBuffer", { clear = false })
  vim.api.nvim_clear_autocmds({
    buffer = bufnr,
    group = group,
  })
  vim.api.nvim_create_autocmd("CursorMoved", {
    desc = "Aerial update highlights in window when cursor moves",
    buffer = bufnr,
    group = group,
    callback = function()
      window.update_position(0, 0)
    end,
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    desc = "Aerial clean up stored data",
    buffer = bufnr,
    group = group,
    callback = function()
      data.delete_buf(bufnr)
    end,
  })
end

return M
