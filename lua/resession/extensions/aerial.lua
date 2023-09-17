local M = {}

M.is_win_supported = function(winid, bufnr)
  local util = require("aerial.util")
  if not util.is_aerial_buffer(bufnr) then
    return false
  end
  local source_win = util.get_source_win(winid)
  local source_buf = util.get_source_buffer(bufnr)
  return source_win
    and vim.api.nvim_win_is_valid(source_win)
    and source_buf
    and vim.api.nvim_buf_is_valid(source_buf)
end

M.save_win = function(winid)
  local util = require("aerial.util")
  local source_win = util.get_source_win(winid)
  if not source_win then
    error("Source winid is nil")
  end
  local rel_nr = vim.api.nvim_win_get_number(source_win) - vim.api.nvim_win_get_number(winid)
  local bufnr = util.get_source_buffer(vim.api.nvim_win_get_buf(winid))
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    error("Source buffer is nil")
  end
  return {
    rel_nr = rel_nr,
    bufname = vim.api.nvim_buf_get_name(bufnr),
  }
end

M.load_win = function(winid, config)
  require("aerial").sync_load()
  local window = require("aerial.window")
  local source_nr = vim.api.nvim_win_get_number(winid) + config.rel_nr
  local source_win = vim.api.nvim_tabpage_list_wins(0)[source_nr]
  vim.defer_fn(function()
    local bufnr = vim.fn.bufadd(config.bufname)
    window.open_aerial_in_win(bufnr, source_win, winid)
  end, 5)
end

return M
