local M = {}

---@param start_node TSNode
---@param end_node TSNode
---@return aerial.Range
M.range_from_nodes = function(start_node, end_node)
  local row, col = start_node:start()
  local end_row, end_col = end_node:end_()
  return {
    lnum = row + 1,
    end_lnum = end_row + 1,
    col = col,
    end_col = end_col,
  }
end

return M
