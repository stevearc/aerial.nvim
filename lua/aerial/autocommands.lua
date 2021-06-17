-- Functions that are called in response to autocommands
local config = require 'aerial.config'
local data = require 'aerial.data'
local util = require 'aerial.util'
local render = require 'aerial.render'
local window = require 'aerial.window'

local M = {}

M.on_enter_aerial_buffer = function()
  local bufnr = util.get_source_buffer()
  if bufnr == -1 then
    -- Quit if source buffer is gone
    vim.api.nvim_win_close(0, true)
    return
  else
    local visible_buffers = vim.fn.tabpagebuflist()
    -- Quit if the source buffer is no longer visible
    if not vim.tbl_contains(visible_buffers, bufnr) then
      vim.api.nvim_win_close(0, true)
      return
    end
  end

  -- Hack to ignore winwidth
  vim.api.nvim_win_set_width(0, util.get_width())
end

M.on_buf_leave = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return
  end
  render.update_highlights(bufnr)

  local maybe_close_aerial = function()
    local winid = vim.fn.bufwinid(bufnr)
    -- If there are no windows left with the source buffer,
    if winid == -1 then
      local aer_winid = vim.fn.bufwinid(aer_bufnr)
      -- And there is a window left for the aerial buffer
      if aer_winid ~= -1 then
        vim.api.nvim_win_close(aer_winid, false)
      end
    end
  end
  -- We have to defer this because if we :q out of a buffer with a aerial open,
  -- and we *synchronously* close the aerial buffer, it will cause the :q
  -- command to fail (presumably because it would cause vim to 'unexpectedly'
  -- exit).
  vim.schedule(maybe_close_aerial)
end

M.on_buf_delete = function(bufnr)
  data[bufnr] = nil
end

M.on_diagnostics_changed = function()
  local errors = vim.lsp.diagnostic.get_count(0, 'Error')
  -- if no errors, refresh symbols
  if config.update_when_errors
    or errors == 0
    or not data:has_symbols() then
    vim.lsp.buf.document_symbol()
  end
end

M.on_buf_win_enter = function()
  if not config.open_automatic() then
    return
  end

  vim.lsp.buf.document_symbol()

  local num_bufs_in_tab = 0
  local bufnr = vim.api.nvim_get_current_buf()
  for i=1,vim.fn.winnr('$'),1 do
    if vim.fn.winbufnr(i) == bufnr then
      num_bufs_in_tab = num_bufs_in_tab + 1
    end
  end

  -- BufWinEnter usually only triggers when the buffer isn't already visible in
  -- an existing window, but it will if the filename was manually specified. If
  -- a buffer was already visible, we'd prefer to not change the visibility
  -- status of aerial.
  if num_bufs_in_tab == 1 then
    -- Have to defer this because we defer the close in on_buf_leave. We don't
    -- want to open the new window until the old one is cleaned up
    vim.defer_fn(window.maybe_open_automatic, 6)
  end
end

M.on_cursor_move = function()
  window.update_position(0, true)
end

return M
