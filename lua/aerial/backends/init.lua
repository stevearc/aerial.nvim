local config = require("aerial.config")
local M = {}

---@class aerial.Backend
---@field is_supported fun(bufnr: integer): boolean, string?
---@field fetch_symbols_sync fun(bufnr?: integer, opts?: {timeout?: integer})
---@field fetch_symbols fun(bufnr?: integer)
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
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false, "Buffer is invalid"
  end
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

---@param bufnr integer
---@return table[]
M.get_status = function(bufnr)
  local ret = {}
  for _, name in ipairs(config.backends(bufnr)) do
    local supported, err = M.is_supported(bufnr, name)
    table.insert(ret, {
      name = name,
      supported = supported,
      error = err,
      attached = M.is_backend_attached(bufnr, name),
    })
  end
  return ret
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

---@param bufnr? integer
---@param backend string
local function set_backend(bufnr, backend)
  vim.api.nvim_buf_set_var(bufnr or 0, "aerial_backend", backend)
end

---@param bufnr? integer
---@param backend? aerial.Backend
---@param name? string
---@return boolean
local function attach(bufnr, backend, name)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local existing_backend_name = M.get_attached_backend(bufnr)
  if not backend or not name or name == existing_backend_name then
    return false
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
    local data = require("aerial.data")
    local loading = require("aerial.loading")
    local util = require("aerial.util")
    local aer_bufnr = util.get_aerial_buffer(bufnr)
    if aer_bufnr then
      loading.set_loading(aer_bufnr, not data.has_received_data(bufnr))
    end

    -- On first attach, fetch symbols from ALL possible backends so that they will race and the
    -- fastest provider will display symbols (instead of just waiting for the prioritized backend
    -- to come back with symbols)
    local candidates = config.backends(bufnr)
    for _, candidate_name in ipairs(candidates) do
      if name ~= candidate_name and M.is_supported(bufnr, candidate_name) then
        local other_backend = M.get_backend_by_name(candidate_name)
        if other_backend then
          other_backend.fetch_symbols(bufnr)
        end
      end
    end
  end
  backend.fetch_symbols(bufnr)
  if not existing_backend_name then
    if config.on_attach then
      config.on_attach(bufnr)
    end
    require("aerial").process_pending_fn_calls()
  end
  return true
end

---@param bufnr? integer
---@return aerial.Backend?
---@return string?
M.get = function(bufnr)
  local existing_backend_name = M.get_attached_backend(bufnr)
  if existing_backend_name then
    return M.get_backend_by_name(existing_backend_name), existing_backend_name
  end
  local backend, name = get_best_backend(bufnr)
  if backend and name then
    attach(bufnr, backend, name)
  end
  return backend, name
end

---@param bufnr? integer
---@param items aerial.Symbol[]
---@param ctx {backend_name: string, lang: string}
M.set_symbols = function(bufnr, items, ctx)
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

  if config.post_add_all_symbols then
    items = config.post_add_all_symbols(bufnr, items, ctx)
    if items == nil then
      vim.notify(
        "aerial.config.post_add_all_symbols should return the symbols to display, but you returned nil or didn't return anything.",
        vim.log.levels.WARN
      )
      return
    end
  end

  local had_symbols = data.has_symbols(bufnr)
  -- Ignore symbols from non-attached backend IFF we already have symbols
  if had_symbols and not M.is_backend_attached(bufnr, ctx.backend_name) then
    return
  end

  data.set_symbols(bufnr, items)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr then
    loading.set_loading(aer_bufnr, false)
  end

  render.update_aerial_buffer(bufnr)
  window.update_all_positions(bufnr, 0)
  if not had_symbols then
    fold.maybe_set_foldmethod(bufnr)
    if bufnr == vim.api.nvim_get_current_buf() then
      -- When switching buffers, this can complete before the BufEnter autocmd since it's throttled.
      -- We need that autocmd to complete first so that it reallocates the existing aerial windows,
      -- thus the defer. It's a bit of a hack :/
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        window.maybe_open_automatic(bufnr)
      end, 15)
    end

    window.center_symbol_in_view(bufnr)

    if config.on_first_symbols then
      config.on_first_symbols(bufnr)
    end
  end
end

M.log_support_err = function()
  vim.notify("Aerial could find no supported backend", vim.log.levels.ERROR)
end

---@param bufnr? integer
---@param backend string
---@return boolean?
M.is_backend_attached = function(bufnr, backend)
  local b = M.get_attached_backend(bufnr)
  return b and (b == backend or backend == nil)
end

---@param bufnr? integer
---@return string?
M.get_attached_backend = function(bufnr)
  local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr or 0, "aerial_backend")
  return ok and val or nil
end

---@param bufnr? integer
---@param refresh? boolean
---@return boolean True if symbols were fetched
M.attach = function(bufnr, refresh)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if refresh then
    local backend, name = get_best_backend()
    return attach(bufnr, backend, name)
  else
    M.get(bufnr)
    return false
  end
end

return M
