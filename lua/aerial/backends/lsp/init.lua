local backends = require("aerial.backends")
local callbacks = require("aerial.backends.lsp.callbacks")
local config = require("aerial.config")
local util = require("aerial.backends.util")
local M = {}

local function replace_handler(name, callback, preserve_callback)
  local old_callback = vim.lsp.handlers[name]
  local new_callback
  new_callback = function(...)
    callback(...)
    if preserve_callback then
      old_callback(...)
    end
  end
  vim.lsp.handlers[name] = new_callback
end

local has_hook = false
local function hook_handlers(preserve_symbol_callback)
  if has_hook then
    return
  end
  has_hook = true
  replace_handler(
    "textDocument/documentSymbol",
    callbacks.symbol_callback,
    preserve_symbol_callback
  )
  replace_handler("textDocument/publishDiagnostics", callbacks.on_publish_diagnostics, true)
end

M.fetch_symbols = function(bufnr)
  bufnr = bufnr or 0
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, callbacks.symbol_callback)
end

M.fetch_symbols_sync = function(bufnr, opts)
  bufnr = bufnr or 0
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout = 4000,
  })
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  local lsp_results, err =
    vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, opts.timeout)
  if err then
    vim.api.nvim_err_writeln("Error when finding document symbols: " .. err)
  else
    callbacks.handle_symbols(lsp_results[1].result, bufnr)
  end
end

---@param bufnr integer
---@return boolean
local function is_lsp_attached(bufnr)
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
    if client.server_capabilities.documentSymbolProvider then
      return true
    end
  end
  return false
end

---@param bufnr integer
---@param exclude_id nil|integer Client ID to exclude from calculation
---@return boolean
local function has_lsp_client(bufnr, exclude_id)
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
    if client.id ~= exclude_id and client.server_capabilities.documentSymbolProvider then
      return true
    end
  end
  return false
end

M.is_supported = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if not is_lsp_attached(bufnr) then
    if has_lsp_client(bufnr) then
      return false, "LSP client available, but not attached"
    else
      return false, "No LSP client found"
    end
  end
  return true, nil
end

M.on_attach = function(client, bufnr, opts)
  if type(bufnr) == "table" then
    opts = bufnr
    bufnr = 0
  elseif not bufnr then
    bufnr = 0
  end
  opts = opts or {}
  if client.server_capabilities.documentSymbolProvider then
    hook_handlers(opts.preserve_callback)
    -- This is called from the LspAttach autocmd
    -- The client isn't fully attached until just after that autocmd completes, so we need to
    -- schedule the attach
    vim.schedule_wrap(backends.attach)(bufnr, true)
  end
end

M.on_detach = function(client_id, bufnr)
  if not has_lsp_client(bufnr, client_id) then
    -- This is called from the LspDetach autocmd
    -- The client isn't fully attached until just after that autocmd completes, so we need to
    -- schedule the attach
    vim.schedule_wrap(backends.attach)(bufnr, true)
  end
end

M.attach = function(bufnr)
  if not config.lsp.diagnostics_trigger_update then
    util.add_change_watcher(bufnr, "lsp")
  end
end

M.detach = function(bufnr)
  if not config.lsp.diagnostics_trigger_update then
    util.remove_change_watcher(bufnr, "lsp")
  end
end

return M
