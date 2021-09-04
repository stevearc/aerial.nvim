local M = {}

-- callback args changed in Neovim 0.6. See:
-- https://github.com/neovim/neovim/pull/15504
local function mk_handler(fn)
  return function(...)
    local config_or_client_id = select(4, ...)
    local is_new = type(config_or_client_id) ~= "number"
    if is_new then
      fn(...)
    else
      local err = select(1, ...)
      local method = select(2, ...)
      local result = select(3, ...)
      local client_id = select(4, ...)
      local bufnr = select(5, ...)
      local config = select(6, ...)
      fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, config)
    end
  end
end

local has_hook = false
M.add_handler = function(preserve_callback)
  if has_hook then
    return
  end
  has_hook = true
  local old_callback = vim.lsp.handlers["textDocument/documentSymbol"]
  local new_callback
  new_callback = function(...)
    mk_handler(require("aerial.callbacks").symbol_callback)(...)
    if preserve_callback then
      old_callback(...)
    end
  end
  vim.lsp.handlers["textDocument/documentSymbol"] = new_callback
end

M.fetch_symbols = function()
  vim.lsp.buf.document_symbol()
end

M.fetch_symbols_sync = function(timeout)
  local params = vim.lsp.util.make_position_params()
  local lsp_results, err = vim.lsp.buf_request_sync(
    0,
    "textDocument/documentSymbol",
    params,
    timeout or 4000
  )
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
