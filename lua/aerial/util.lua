local config = require 'aerial.config'

local M = {}

M.is_aerial_buffer = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, 'filetype')
  return ft == 'aerial'
end

M.get_aerial_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, 'aerial_buffer')
end

M.get_source_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, 'source_buffer')
end

M.get_buffer_from_var = function(bufnr, varname)
  local status, result_bufnr = pcall(vim.api.nvim_buf_get_var, bufnr, varname)
  if not status or result_bufnr == nil then
    return -1
  end
  return vim.fn.bufnr(result_bufnr)
end

M.flash_highlight = function(bufnr, lnum, hl_group, durationMs)
  local hl_group = hl_group or config.get_highlight_group()
  local durationMs = durationMs or 300
  local ns = vim.api.nvim_buf_add_highlight(bufnr, 0, hl_group, lnum - 1, 0, -1)
  local remove_highlight = function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
  vim.defer_fn(remove_highlight, durationMs)
end

M.detect_split_direction = function()
  bufnr = vim.api.nvim_get_current_buf()
  -- If we are the first window default to left side
  if vim.fn.winbufnr(1) == bufnr then
    return '<'
  end

  -- If we are the last window default to right side
  local lastwin = vim.fn.winnr('$')
  if vim.fn.winbufnr(lastwin) == bufnr then
    return '>'
  end

  return '<'
end

return M
