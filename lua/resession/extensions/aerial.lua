local window = require("aerial.window")
local util = require("aerial.util")
local M = {}

M.on_save = function() end
M.on_load = function() end

M.is_win_supported = function(winid, bufnr)
  return util.is_aerial_buffer(bufnr)
end

M.save_win = function(winid)
  local source_win = util.get_source_win(winid)
  local rel_nr = vim.api.nvim_win_get_number(source_win) - vim.api.nvim_win_get_number(winid)
  local bufnr = util.get_source_buffer(vim.api.nvim_win_get_buf(winid))
  return {
    rel_nr = rel_nr,
    bufname = vim.api.nvim_buf_get_name(bufnr),
  }
end

M.load_win = function(winid, config)
  local source_nr = vim.api.nvim_win_get_number(winid) + config.rel_nr
  local source_win = vim.api.nvim_tabpage_list_wins(0)[source_nr]
  vim.defer_fn(function()
    local bufnr = vim.fn.bufadd(config.bufname)
    window.open_aerial_in_win(bufnr, source_win, winid)
  end, 5)
end

return M
