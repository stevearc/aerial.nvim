-- Functions that are called in response to autocommands
local config = require 'aerial.config'
local data = require 'aerial.data'
local pane = require 'aerial.pane'
local util = require 'aerial.util'
local window = require 'aerial.window'

local M = {}

M.on_enter_aerial_buffer = function()
  local bufnr = util.get_source_buffer()
  if bufnr == -1 then
    -- Quit if source buffer is gone
    vim.cmd('q!')
    return
  else
    visible_buffers = vim.fn.tabpagebuflist()
    -- Quit if the source buffer is no longer visible
    if not vim.tbl_contains(visible_buffers, bufnr) then
      vim.cmd('q!')
      return
    end
  end

  -- Hack to ignore winwidth
  vim.cmd('vertical resize ' .. util.get_width())

  -- Move cursor to nearest matching line
  local row = data.last_position_by_buf[bufnr]
  if row ~= nil then
    vim.fn.setpos('.', {0, row, 1, 0})
  end
end

M.on_buf_leave = function()
  bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return
  end
  window.update_highlights(bufnr)

  local maybe_close_aerial = function()
    local winid = vim.fn.bufwinid(bufnr)
    -- If there are no windows left with the source buffer, 
    if winid == -1 then
      local winnr = vim.fn.bufwinnr(aer_bufnr)
      -- And there is a window left for the aerial buffer
      if winnr ~= -1 then
        vim.cmd(winnr .. "close")
      end
    end
  end
  -- We have to defer this because if we :q out of a buffer with a aerial open,
  -- and we *synchronously* close the aerial buffer, it will cause the :q
  -- command to fail (presumably because it would cause vim to 'unexpectedly'
  -- exit).
  vim.defer_fn(maybe_close_aerial, 5)
end

M.request_symbols_if_diagnostics_changed = function()
  local errors = vim.lsp.util.buf_diagnostics_count("Error")
  -- if no errors, refresh symbols
  if errors == 0 then
    vim.lsp.buf.document_symbol()
  end
end

M.on_buf_win_enter = function()
  if not config.get_open_automatic() then
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
    pane._maybe_open_automatic()
  end
end

return M
