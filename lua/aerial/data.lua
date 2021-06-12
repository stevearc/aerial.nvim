local M = {}

M.has_symbols = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return M.items_by_buf[bufnr] ~= nil
end
M.items_by_buf = {}
M.positions_by_buf = {}
M.last_position_by_buf = {}

return M
