local backends = require("aerial.backends")
local callbacks = require("aerial.backends.lsp.callbacks")
local config = require("aerial.config")
local util = require("aerial.backends.util")
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
      local conf = select(6, ...)
      fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, conf)
    end
  end
end

local function replace_handler(name, callback, preserve_callback)
  local old_callback = vim.lsp.handlers[name]
  local new_callback
  new_callback = function(...)
    mk_handler(callback)(...)
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

local function mark_lsp_attached(bufnr)
  vim.api.nvim_buf_set_var(bufnr, "_aerial_lsp_attached", true)
end

local function is_lsp_attached(bufnr)
  local ok, attached = pcall(vim.api.nvim_buf_get_var, bufnr, "_aerial_lsp_attached")
  return ok and attached
end

M.is_supported = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if not is_lsp_attached(bufnr) then
    for _, client in pairs(vim.lsp.buf_get_clients(bufnr)) do
      if client.server_capabilities.documentSymbolProvider then
        return false, "LSP client not attached (did you call aerial.on_attach?)"
      end
    end
    return false, "LSP client not attached"
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
    mark_lsp_attached(bufnr)
    backends.attach(bufnr, true)
  end
end

M.attach = function(bufnr)
  if not config.lsp.diagnostics_trigger_update then
    util.add_change_watcher(bufnr, "lsp")
  end
  M.fetch_symbols(bufnr)
end

M.detach = function(bufnr)
  if not config.lsp.diagnostics_trigger_update then
    util.remove_change_watcher(bufnr, "lsp")
  end
end

return M
