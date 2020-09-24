local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local util = require 'aerial.util'
local window = require 'aerial.window'

local M = {}

M.is_open = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer()
  if aer_bufnr == -1 then
    return false
  else
    local winid = vim.fn.bufwinid(aer_bufnr)
    return winid ~= -1
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    vim.cmd('close')
    return
  end
  local aer_bufnr = util.get_aerial_buffer()
  local winnr = vim.fn.bufwinnr(aer_bufnr)
  if winnr ~= -1 then
    vim.cmd(winnr .. "close")
  end
end

M._maybe_open_automatic = function()
  local items = data.items_by_buf[vim.api.nvim_get_current_buf()]
  if items == nil or #items < config.get_open_automatic_min_symbols() then
    return false
  end
  if vim.fn.line('$') < config.get_open_automatic_min_lines() then
    return false
  end
  M.open(false, config.get_automatic_direction())
  return true
end

M.open = function(focus, direction)
  if vim.lsp.buf_get_clients() == 0 then
    error("Cannot open aerial. No LSP clients")
    return
  end
  bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if M.is_open() then
    if focus then
      local winid = vim.fn.bufwinid(aer_bufnr)
      vim.api.nvim_set_current_win(winid)
    end
    return
  end
  local direction = direction or util.detect_split_direction()
  local start_winid = vim.fn.win_getid()
  window.create_aerial_window(bufnr, aer_bufnr, direction)
  if aer_bufnr == -1 then
    aer_bufnr = vim.api.nvim_get_current_buf()
  end
  vim.api.nvim_set_current_win(start_winid)
  if data.items_by_buf[bufnr] == nil then
    vim.lsp.buf.document_symbol()
  end
  nav._update_position()
  if focus then
    vim.api.nvim_set_current_win(vim.fn.bufwinid(aer_bufnr))
  end
end

M.focus = function()
  if not M.is_open() then
    return
  end
  bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  local winid = vim.fn.bufwinid(aer_bufnr)
  vim.api.nvim_set_current_win(winid)
end

M.toggle = function(focus, direction)
  if util.is_aerial_buffer() then
    vim.cmd('close')
    return false
  end

  if M.is_open() then
    M.close()
    return false
  else
    M.open(focus, direction)
    return true
  end
end

return M
