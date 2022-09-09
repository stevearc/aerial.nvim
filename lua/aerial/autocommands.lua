-- Functions that are called in response to autocommands
local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local fold = require("aerial.fold")
local util = require("aerial.util")
local render = require("aerial.render")
local window = require("aerial.window")

local M = {}

local maybe_open_automatic = util.throttle(function()
  window.maybe_open_automatic()
end, { delay = 5, reset_timer_on_call = true })

---@param aer_win integer
---@return boolean
local function should_close_aerial(aer_win)
  local aer_buf = vim.api.nvim_win_get_buf(aer_win)
  local src_win = util.get_source_win(aer_win)
  -- If the aerial window has no valid source window, close it
  if not src_win then
    return true
  end
  local src_buf = util.get_source_buffer(aer_buf)

  if config.close_automatic_events.unfocus then
    -- Close the window if the aerial source win is not the current win
    if src_win ~= vim.api.nvim_get_current_win() then
      return true
    end
  end

  -- Close the aerial window if its attached buffer is unsupported
  if config.close_automatic_events.unsupported then
    if not vim.api.nvim_buf_is_valid(src_buf) or not backends.get(src_buf) then
      return true
    end
  end
  return false
end

local function update_aerial_windows()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local winbuf = vim.api.nvim_win_get_buf(winid)
    if util.is_aerial_buffer(winbuf) then
      local close = false
      if config.attach_mode == "global" then
        window.open_aerial_in_win(0, 0, winid)
      elseif config.attach_mode == "window" then
        local src_win = util.get_source_win(winid)
        if src_win then
          local src_buf = vim.api.nvim_win_get_buf(src_win)

          -- Close the aerial window if its source window has switched buffers
          if config.close_automatic_events.switch_buffer then
            if src_buf ~= util.get_source_buffer(winbuf) then
              close = true
            end
          end

          if util.get_source_win(winid) == vim.api.nvim_get_current_win() then
            window.open_aerial_in_win(src_buf, src_win, winid)
          end
        end
      end

      if close or should_close_aerial(winid) then
        vim.api.nvim_win_close(winid, true)
      end
    end
  end
end

M.on_enter_buffer = util.throttle(function()
  backends.attach()
  if util.is_ignored_win() then
    return
  end

  local mybuf = vim.api.nvim_get_current_buf()

  if util.is_aerial_buffer(mybuf) then
    local source_win = util.get_source_win()
    if
      (not source_win and config.attach_mode ~= "global")
      or vim.tbl_count(vim.api.nvim_tabpage_list_wins(0)) == 1
    then
      vim.cmd("quit")
    else
      -- Hack to ignore winwidth
      util.restore_width(0, 0)
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

M.on_buf_delete = function(bufnr)
  data[tonumber(bufnr)] = nil
end

M.on_cursor_move = function(is_aerial_buf)
  if is_aerial_buf then
    render.update_highlights(util.get_source_buffer())
  else
    window.update_position(0, true)
  end
end

M.on_leave_aerial_buf = function()
  render.clear_highlights(util.get_source_buffer())
end

M.attach_autocommands = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  vim.cmd(
    string.format(
      "autocmd CursorMoved <buffer=%d> lua require'aerial.autocommands'.on_cursor_move()",
      bufnr
    )
  )
  vim.cmd(
    string.format(
      [[autocmd BufDelete <buffer=%d> call luaeval("require'aerial.autocommands'.on_buf_delete(_A)", expand('<abuf>'))]],
      bufnr
    )
  )
end

return M
