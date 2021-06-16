local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local protocol = require 'vim.lsp.protocol'
local render = require 'aerial.render'
local window = require 'aerial.window'

local M = {}

local function get_symbol_kind_name(kind_number)
  return protocol.SymbolKind[kind_number] or "Unknown"
end

local function process_symbols(symbols)
  local function _process_symbols(_symbols, list, level)
    for _, symbol in ipairs(_symbols) do
      local kind = get_symbol_kind_name(symbol.kind)
      local range
      if symbol.location then -- SymbolInformation type
        range = symbol.location.range
      elseif symbol.range then -- DocumentSymbol type
        range = symbol.range
      end
      local include_item = range and config.filter_kind[kind]

      if include_item then
        local item = {
          kind = kind,
          name = symbol.name,
          level = level,
          lnum = range.start.line + 1,
          col = range.start.character + 1,
        }
        if symbol.children then
          item.children = _process_symbols(symbol.children, {}, level + 1)
        end
        table.insert(list, item)
      elseif symbol.children then
        _process_symbols(symbol.children, list, level)
      end
    end
    table.sort(list, function(a, b)
      if a.lnum == b.lnum then
        return a.col < b.col
      else
        return a.lnum < b.lnum
      end
    end)
    return list
  end

  return _process_symbols(symbols, {}, 0)
end

M.symbol_callback = function(_, _, result, _, bufnr)
  if not result or vim.tbl_isempty(result) then return end
  -- Don't update if there are diagnostics errors (or override by setting)
  local error_count = vim.lsp.diagnostic.get_count(bufnr, 'Error')
  local has_symbols = data:has_symbols(bufnr)
  if not config.get_update_when_errors() and error_count > 0 and has_symbols then
    return
  end

  local items = process_symbols(result)
  data[bufnr].items = items

  render.update_aerial_buffer(bufnr)
  if not has_symbols then
    if not window._maybe_open_automatic() then
      nav._update_position()
    end
  else
    render.update_highlights(bufnr)
  end
end

return M
