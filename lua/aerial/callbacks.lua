local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local pane = require 'aerial.pane'
local protocol = require 'vim.lsp.protocol'
local window = require 'aerial.window'

local M = {}

local function filter_symbol_predicate(item)
  return config.filter_kind[item.kind]
end

local function sort_symbol(a, b)
  return a.lnum < b.lnum
end

M.symbol_callback = function(_, _, result, _, bufnr)
  if not result or vim.tbl_isempty(result) then return end
  -- Don't update if there are diagnostics errors (or override by setting)
  local error_count = vim.lsp.diagnostic.get_count(bufnr, 'Error')
  if not config.get_update_when_errors() and error_count > 0 and not data.has_symbols(bufnr) then
    return
  end

  local items = M.symbols_to_items(result, bufnr)
  items = vim.tbl_filter(filter_symbol_predicate, items)
  table.sort(items, sort_symbol)
  local had_items = data.items_by_buf[bufnr] ~= nil
  data.items_by_buf[bufnr] = items

  window.update_aerial_buffer(bufnr)
  if not had_items then
    if not pane._maybe_open_automatic() then
      nav._update_position()
    end
  else
    window.update_highlights(bufnr)
  end
end

-- Mostly copied from neovim source, with some tweaks for naming
function M.symbols_to_items(symbols, bufnr)
  --@private
  local function _symbols_to_items(_symbols, _items, _bufnr, level)
    for _, symbol in ipairs(_symbols) do
      local kind = M._get_symbol_kind_name(symbol.kind)
      local text = M._get_prefix(level, kind) .. symbol.name
      if symbol.location then -- SymbolInformation type
        local range = symbol.location.range
        table.insert(_items, {
          filename = vim.uri_to_fname(symbol.location.uri),
          lnum = range.start.line + 1,
          col = range.start.character + 1,
          kind = kind,
          text = text,
        })
      elseif symbol.range then -- DocumentSymbol type
        table.insert(_items, {
          filename = vim.api.nvim_buf_get_name(_bufnr),
          lnum = symbol.range.start.line + 1,
          col = symbol.range.start.character + 1,
          kind = kind,
          text = text,
        })
        if symbol.children then
          for _, v in ipairs(_symbols_to_items(symbol.children, _items, _bufnr, level + 1)) do
            vim.list_extend(_items, v)
          end
        end
      end
    end
    return _items
  end
  return _symbols_to_items(symbols, {}, bufnr, 0)
end

function M._get_prefix(level, kind)
  local kind_abbr = config.get_kind_abbr(kind)
  local spacing = string.rep('  ', level)
  if kind_abbr == '' then
    return spacing
  else
    return spacing .. '[' .. kind .. '] '
  end
end

function M._get_symbol_kind_name(symbol_kind)
  return protocol.SymbolKind[symbol_kind] or "Unknown"
end

return M
