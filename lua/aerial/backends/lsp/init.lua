local backends = require("aerial.backends")
local callbacks = require("aerial.backends.lsp.callbacks")
local config = require("aerial.config")
local data = require("aerial.data")
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

local has_hook = false
local function add_handler(preserve_callback)
  if has_hook then
    return
  end
  has_hook = true
  local old_callback = vim.lsp.handlers["textDocument/documentSymbol"]
  local new_callback
  new_callback = function(...)
    mk_handler(callbacks.symbol_callback)(...)
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

M.on_attach = function(client, bufnr, opts)
  if type(bufnr) == "table" then
    opts = bufnr
    bufnr = 0
  elseif not bufnr then
    bufnr = 0
  end
  opts = opts or {}
  if not client.resolved_capabilities.document_symbol then
    return
  end
  add_handler(opts.preserve_callback)
  backends.attach(bufnr, true)
end

M.attach = function(bufnr)
  if config["lsp.diagnostics_trigger_update"] then
    local autocmd_name = vim.diagnostic and "DiagnosticsChanged" or "LspDiagnosticsChanged"
    vim.cmd(string.format(
      [[augroup AerialDiagnostics
      au!
      au User %s lua require'aerial.backends.lsp'._on_diagnostics_changed()
    augroup END
    ]],
      autocmd_name
    ))
  end
  if config.open_automatic() and not config["lsp.diagnostics_trigger_update"] then
    M.fetch_symbols()
  end
end

M.detach = function(bufnr)
  -- pass
end

M._on_diagnostics_changed = function()
  if not backends.is_backend_attached(0, "lsp") then
    return
  end
  local errors = vim.lsp.diagnostic.get_count(0, "Error")
  -- if no errors, refresh symbols
  if config["lsp.update_when_errors"] or errors == 0 or not data:has_symbols() then
    M.fetch_symbols()
  end
end

return M
