local config = require("aerial.config")
local M = {}

---@class aerial.Backend
---@field is_supported fun(bufnr: integer): boolean, string?
---@field fetch_symbols_sync fun(bufnr: integer, timeout?: integer)
---@field fetch_symbols fun(bufnr: integer)
---@field attach fun(bufnr: integer)
---@field detach fun(bufnr: integer)

---@param name string
---@return aerial.Backend|nil
M.get_backend_by_name = function(name)
  local ok, mod = pcall(require, string.format("aerial.backends.%s", name))
  return ok and mod or nil
end

---@param bufnr integer
---@param name string
---@return boolean
---@return string?
M.is_supported = function(bufnr, name)
  local max_lines = config.disable_max_lines
  if max_lines and max_lines > 0 and vim.api.nvim_buf_line_count(bufnr) > max_lines then
    return false, "File exceeds disable_max_lines size"
  end
  local max_size = config.disable_max_size
  if max_size and max_size > 0 then
    local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
    -- size will be -2 if it doesn't fit into a number
    if size > max_size or size == -2 then
      return false, "File exceeds disable_max_size"
    end
  end
  local backend = M.get_backend_by_name(name)
  if backend then
    local supported, err = backend.is_supported(bufnr)
    return supported, err
  else
    return false, "No such backend"
  end
end

---@param bufnr? integer
---@return aerial.Backend?
---@return string?
local function get_best_backend(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local candidates = config.backends(bufnr)
  for _, name in ipairs(candidates) do
    if M.is_supported(bufnr, name) then
      return M.get_backend_by_name(name), name
    end
  end
  return nil, nil
end

---@param bufnr integer
---@param backend string
local function set_backend(bufnr, backend)
  vim.api.nvim_buf_set_var(bufnr, "aerial_backend", backend)
end

---@param bufnr integer
---@param backend? aerial.Backend
---@param name? string
---@param existing_backend_name? string
local function attach(bufnr, backend, name, existing_backend_name)
  if not backend or not name or name == existing_backend_name then
    return
  end
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  set_backend(bufnr, name)
  backend.attach(bufnr)
  if existing_backend_name then
    M.get_backend_by_name(existing_backend_name).detach(bufnr)
  else
    require("aerial.autocommands").attach_autocommands(bufnr)
    require("aerial.fold").add_fold_mappings(bufnr)
  end
  if not existing_backend_name and config.on_attach then
    config.on_attach(bufnr)
  end
end

---@param bufnr integer
---@return aerial.Backend?
M.get = function(bufnr)
  local existing_backend_name = M.get_attached_backend(bufnr)
  if existing_backend_name then
    return M.get_backend_by_name(existing_backend_name)
  end
  local backend, name = get_best_backend(bufnr)
  if backend and name then
    attach(bufnr, backend, name, existing_backend_name)
  end
  return backend
end

---@param bufnr integer
---@param items aerial.Symbol[]
M.set_symbols = function(bufnr, items)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
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
      window.maybe_open_automatic(bufnr)
    end
    if config.on_first_symbols then
      config.on_first_symbols(bufnr)
    end
  end
end

M.log_support_err = function()
  vim.api.nvim_err_writeln("Aerial could find no supported backend")
end

---@param bufnr integer
---@param backend string
---@return boolean?
M.is_backend_attached = function(bufnr, backend)
  local b = M.get_attached_backend(bufnr)
  return b and (b == backend or backend == nil)
end

---@param bufnr integer
---@return string?
M.get_attached_backend = function(bufnr)
  local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr or 0, "aerial_backend")
  return ok and val or nil
end

---@param bufnr integer
---@param refresh? boolean
M.attach = function(bufnr, refresh)
  if refresh then
    local existing_backend_name = M.get_attached_backend(bufnr)
    local backend, name = get_best_backend()
    attach(bufnr, backend, name, existing_backend_name)
  else
    M.get(bufnr)
  end
end

return M
