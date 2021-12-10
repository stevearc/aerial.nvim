local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local protocol = require("vim.lsp.protocol")

local M = {}

local function get_symbol_kind_name(kind_number)
  return protocol.SymbolKind[kind_number] or "Unknown"
end

local function process_symbols(symbols, bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local include_kind = config.get_filter_kind_map(filetype)
  local function _process_symbols(_symbols, parent, list, level)
    for _, symbol in ipairs(_symbols) do
      local kind = get_symbol_kind_name(symbol.kind)
      local range
      if symbol.location then -- SymbolInformation type
        range = symbol.location.range
      elseif symbol.range then -- DocumentSymbol type
        range = symbol.range
      end
      local include_item = range and include_kind[kind]

      if include_item then
        local item = {
          kind = kind,
          name = symbol.name,
          level = level,
          parent = parent,
          lnum = range.start.line + 1,
          col = range.start.character,
        }

        -- Skip this symbol if it's in the same location as the last one.
        -- This can happen on C++ macros
        -- (see https://github.com/stevearc/aerial.nvim/issues/13)
        local last_item = vim.tbl_isempty(list) and {} or list[#list]
        if last_item.lnum ~= item.lnum or last_item.col ~= item.col then
          if symbol.children then
            item.children = _process_symbols(symbol.children, item, {}, level + 1)
          end
          table.insert(list, item)
        elseif symbol.children then
          -- If this duplicate symbol has children (unlikely), make sure those get
          -- merged into the previous symbol's children
          last_item.children = last_item.children or {}
          vim.list_extend(
            last_item.children,
            _process_symbols(symbol.children, last_item, {}, level + 1)
          )
        end
      elseif symbol.children then
        _process_symbols(symbol.children, parent, list, level)
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

  return _process_symbols(symbols, nil, {}, 0)
end

M.handle_symbols = function(result, bufnr)
  backends.set_symbols(bufnr, process_symbols(result, bufnr))
end

local results = {}
M.symbol_callback = function(_err, result, context, _config)
  if not result or vim.tbl_isempty(result) then
    return
  end
  local bufnr = context.bufnr
  -- Don't update if there are diagnostics errors (or override by setting)
  local error_count = #vim.diagnostic.get(bufnr, { severity = "Error" })
  local has_symbols = data:has_symbols(bufnr)
  if not config.lsp.update_when_errors and error_count > 0 and has_symbols then
    return
  end

  -- Debounce this callback to avoid unnecessary re-rendering
  if results[bufnr] == nil then
    vim.defer_fn(function()
      local r = results[bufnr]
      results[bufnr] = nil
      M.handle_symbols(r, bufnr)
    end, 100)
  end
  results[bufnr] = result
end

return M
