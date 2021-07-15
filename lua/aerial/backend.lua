local M = {}

local has_hook = false
M.add_handler = function(preserve_callback)
  if has_hook then
    return
  end
  has_hook = true
  local old_callback = vim.lsp.handlers["textDocument/documentSymbol"]
  local new_callback
  if preserve_callback then
    new_callback = function(...)
      require("aerial.callbacks").symbol_callback(...)
      old_callback(...)
    end
  else
    new_callback = require("aerial.callbacks").symbol_callback
  end
  vim.lsp.handlers["textDocument/documentSymbol"] = new_callback
end

M.fetch_symbols = function()
  vim.lsp.buf.document_symbol()
end

M.fetch_symbols_sync = function(timeout)
  local params = vim.lsp.util.make_position_params()
  local lsp_results, err = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, timeout or 4000)
  if err then
    vim.api.nvim_err_writeln("Error when finding document symbols: " .. err)
  else
    local callbacks = require("aerial.callbacks")
    callbacks.handle_symbols(lsp_results[1].result)
  end
end

M.is_supported = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  for _, client in pairs(vim.lsp.buf_get_clients(bufnr)) do
    if client.resolved_capabilities.document_symbol then
      return true
    end
  end
  return false
end

M.log_support_err = function()
  vim.api.nvim_err_writeln("No LSP clients support textDocument/documentSymbol")
end

return M
