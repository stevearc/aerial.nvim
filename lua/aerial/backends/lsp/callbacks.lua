local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local protocol = require("vim.lsp.protocol")

local M = {}

local function get_symbol_kind_name(kind_number)
  return protocol.SymbolKind[kind_number] or "Unknown"
end

local function process_symbols(symbols, bufnr)
  local include_kind = config.get_filter_kind_map(bufnr)
  local max_line = vim.api.nvim_buf_line_count(bufnr)
  local function _process_symbols(symbols_, parent, list, level)
    for _, symbol in ipairs(symbols_) do
      local kind = get_symbol_kind_name(symbol.kind)
      local range
      if symbol.location then -- SymbolInformation type
        range = symbol.location.range
      elseif symbol.range then -- DocumentSymbol type
        range = symbol.range
      end
      local include_item = range and include_kind[kind]

      if include_item then
        local name = symbol.name
        -- Some LSP servers return multiline symbols with newlines
        local nl = string.find(symbol.name, "\n")
        if nl then
          name = string.sub(name, 1, nl - 1)
        end
        local item = {
          kind = kind,
          name = name,
          level = level,
          parent = parent,
          lnum = range.start.line + 1,
          col = range.start.character,
          end_lnum = range["end"].line + 1,
          end_col = range["end"].character,
        }
        -- Some language servers give number values that are wildly incorrect
        -- See https://github.com/stevearc/aerial.nvim/issues/101
        item.end_lnum = math.min(item.end_lnum, max_line)

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

local function get_error_count(bufnr, client_id)
  -- Neovim 0.6+
  if vim.diagnostic then
    return #vim.diagnostic.get(bufnr, {
      severity = vim.lsp.protocol.DiagnosticSeverity.Error,
      namespace = vim.lsp.diagnostic.get_namespace(client_id),
    })
  else
    -- Neovim < 0.6
    return vim.lsp.diagnostic.get_count(bufnr, "Error")
  end
end

local results = {}
M.symbol_callback = function(_err, result, context, _config)
  local client_id = context.client_id
  if not result or vim.tbl_isempty(result) then
    return
  end
  local bufnr = context.bufnr
  -- Don't update if there are diagnostics errors, unless config option is set
  -- or we have no symbols for this buffer
  if
    not config.lsp.update_when_errors
    and data:has_symbols(bufnr)
    and get_error_count(bufnr, client_id) > 0
  then
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

M.on_publish_diagnostics = function(_err, result, ctx, _config)
  local client_id = ctx.client_id
  local client = vim.lsp.get_client_by_id(client_id)
  local uri = result.uri
  local bufnr = vim.uri_to_bufnr(uri)
  if
    not bufnr
    or not backends.is_backend_attached(bufnr, "lsp")
    or not config.lsp.diagnostics_trigger_update
    or not client.server_capabilities.documentSymbolProvider
  then
    return
  end

  -- Don't update if there are diagnostics errors, unless config option is set
  -- or we have no symbols for this buffer
  if not config.lsp.update_when_errors and data:has_symbols(bufnr) then
    for _, diagnostic in ipairs(result.diagnostics) do
      local severity = diagnostic.severity
      if type(severity) == "string" then
        severity = vim.lsp.protocol.DiagnosticSeverity[diagnostic.severity]
      end
      if severity == vim.lsp.protocol.DiagnosticSeverity.Error then
        return
      end
    end
  end

  backends.get(bufnr).fetch_symbols(bufnr)
end

return M
