local M = {}

local function get_backend(name)
  return require(string.format("aerial.backends.%s", name))
end

M.get = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  -- TODO this should be a config option
  local candidates = { "lsp", "treesitter" }
  for _, name in ipairs(candidates) do
    local backend = get_backend(name)
    if backend.is_supported(bufnr) then
      return backend, name
    end
  end
  return nil, nil
end

M.set_symbols = function(bufnr, items)
  local data = require("aerial.data")
  local fold = require("aerial.fold")
  local loading = require("aerial.loading")
  local render = require("aerial.render")
  local util = require("aerial.util")
  local window = require("aerial.window")

  local had_symbols = data:has_symbols(bufnr)
  data[bufnr].items = items
  loading.set_loading(util.get_aerial_buffer(bufnr), false)

  render.update_aerial_buffer(bufnr)
  window.update_all_positions(bufnr, vim.api.nvim_get_current_win())
  if not had_symbols then
    fold.maybe_set_foldmethod(bufnr)
    if bufnr == vim.api.nvim_get_current_buf() then
      window.maybe_open_automatic()
    end
  end
end

M.log_support_err = function()
  vim.api.nvim_err_writeln("Aerial could find no supported backend")
end

local function set_backend(bufnr, backend)
  vim.api.nvim_buf_set_var(bufnr, "aerial_backend", backend)
end

M.is_backend_attached = function(bufnr, backend)
  local b = M.get_attached_backend(bufnr)
  return b and (b == backend or backend == nil)
end

M.get_attached_backend = function(bufnr)
  local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr or 0, "aerial_backend")
  return ok and val or nil
end

M.attach = function(bufnr, refresh)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local existing_backend_name = M.get_attached_backend(bufnr)
  if not refresh and existing_backend_name then
    return
  end
  local backend, name = M.get()
  if backend and name ~= existing_backend_name then
    backend.attach(bufnr)
    if existing_backend_name then
      get_backend(existing_backend_name).detach(bufnr)
    else
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
-- detach(bufnr)

return M
