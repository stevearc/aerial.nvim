local M = {}

M.get = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local candidates = { "lsp" }
  for _, candidate in ipairs(candidates) do
    local backend = require(string.format("aerial.backends.%s", candidate))
    if backend.is_supported(bufnr) then
      return backend, candidate
    end
  end
  return nil, nil
end

M.log_support_err = function()
  vim.api.nvim_err_writeln("Aerial could find no supported backend")
end

local function set_backend(bufnr, backend)
  vim.api.nvim_buf_set_var(bufnr, "aerial_backend", backend)
end

M.is_backend_attached = function(bufnr, backend)
  local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr or 0, "aerial_backend")
  return ok and (backend == nil or val == backend)
end

M.attach = function(bufnr, refresh)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local is_attached = M.is_backend_attached(bufnr)
  if not refresh and is_attached then
    return
  end
  local backend, name = M.get()
  if backend then
    backend.attach(bufnr)
    if not is_attached then
      require("aerial.autocommands").attach_autocommands(bufnr)
      require("aerial.fold").add_fold_mappings(bufnr)
    end
    set_backend(bufnr, name)
  end
end

-- Backends must provide the following methods:
-- is_supported(bufnr)
-- fetch_symbols_sync(timeout)
-- fetch_symbols()
-- attach(bufnr)

return M
