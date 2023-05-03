local backends = require("aerial.backends")
local callbacks = require("aerial.backends.lsp.callbacks")
local config = require("aerial.config")
local lsp_util = require("aerial.backends.lsp.util")
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
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  local client = lsp_util.get_client(bufnr)
  if not client then
    vim.notify(
      string.format("No LSP client found that supports symbols in buffer %d", bufnr),
      vim.log.levels.WARN
    )
    return
  end
  local request_success =
    client.request("textDocument/documentSymbol", params, callbacks.symbol_callback, bufnr)
  if not request_success then
    vim.notify("Error requesting document symbols", vim.log.levels.WARN)
  end
end

M.fetch_symbols_sync = function(bufnr, opts)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout = 4000,
  })
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  local client = lsp_util.get_client(bufnr)
  if not client then
    vim.notify(
      string.format("No LSP client found that supports symbols in buffer %d", bufnr),
      vim.log.levels.WARN
    )
    return
  end
  local response
  local request_success = client.request(
    "textDocument/documentSymbol",
    params,
    function(err, result)
      response = { err = err, result = result }
    end,
    bufnr
  )
  if not request_success then
    vim.notify("Error requesting document symbols", vim.log.levels.WARN)
  end

  local wait_result = vim.wait(opts.timeout, function()
    return response ~= nil
  end, 10)

  if wait_result then
    if response.err then
      vim.notify(
        string.format("Error requesting document symbols: %s", response.err),
        vim.log.levels.WARN
      )
    else
      callbacks.handle_symbols(response.result, bufnr)
    end
  else
    vim.notify("Timeout when requesting document symbols", vim.log.levels.WARN)
  end
end

M.is_supported = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if not lsp_util.get_client(bufnr) then
    return false, "No LSP client found that supports symbols"
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
  if lsp_util.client_supports_symbols(client) then
    hook_handlers(opts.preserve_callback)
    -- This is called from the LspAttach autocmd
    -- The client isn't fully attached until just after that autocmd completes, so we need to
    -- schedule the attach
    vim.schedule_wrap(backends.attach)(bufnr, true)
  end
end

M.on_detach = function(client_id, bufnr)
  if not lsp_util.get_client(bufnr, client_id) then
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
