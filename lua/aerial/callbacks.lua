local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local window = require 'aerial.window'

local M = {}

function filter_symbol_predicate(item)
  return config.filter_kind[item.kind]
end

function sort_symbol(a, b)
  return a.lnum < b.lnum
end

M.symbol_callback = function(_, _, result, _, bufnr)
  if not result or vim.tbl_isempty(result) then return end
  local items = vim.lsp.util.symbols_to_items(result, bufnr)
  items = vim.tbl_filter(filter_symbol_predicate, items)
  table.sort(items, sort_symbol)
  local had_items = data.items_by_buf[bufnr] ~= nil
  data.items_by_buf[bufnr] = items

  -- Don't update if there are diagnostics errors (or override by setting)
  local error_count = M._buf_diagnostics_count(bufnr, 'Error') or 0
  if not config.get_update_when_errors() and error_count > 0 then
    return
  end
  window.update_aerial_buffer(bufnr)
  if not had_items and vim.api.nvim_get_current_buf() == bufnr then
    nav._update_position()
  else
    window.update_highlights(bufnr)
  end
end

-- This is mostly copied from Neovim source, but adjusted to accept a bufnr
function M._buf_diagnostics_count(bufnr, kind)
  local diagnostics = vim.lsp.util.diagnostics_by_buf[bufnr]
  if not diagnostics then return end
  local count = 0
  for _, diagnostic in pairs(diagnostics) do
    if vim.lsp.protocol.DiagnosticSeverity[kind] == diagnostic.severity then
      count = count + 1
    end
  end
  return count
end


return M
