local backends = require("aerial.backends")
local config = require("aerial.config")
local util = require("aerial.util")
local M = {}

local update_symbols = util.throttle(function(backend_name, bufnr)
  if backends.is_backend_attached(bufnr, backend_name) then
    local backend = backends.get_backend_by_name(backend_name)
    if backend then
      backend.fetch_symbols(bufnr)
    end
  end
end, {
  delay = function(backend_name)
    return config[backend_name].update_delay or 300
  end,
  reset_timer_on_call = true,
})

---@param bufnr nil|integer
---@param backend_name string
M.add_change_watcher = function(bufnr, backend_name)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local event = config.update_events
  if type(event) == "string" then
    event = vim.split(config.update_events, ",")
  end
  local group =
    vim.api.nvim_create_augroup(string.format("Aerial%s", backend_name), { clear = false })
  vim.api.nvim_clear_autocmds({
    group = group,
    buffer = bufnr,
  })

  vim.api.nvim_create_autocmd(event, {
    desc = "Aerial update symbols",
    buffer = bufnr,
    group = group,
    callback = function(params)
      update_symbols(backend_name, bufnr)
    end,
  })
end

---@param bufnr nil|integer
---@param backend_name string
M.remove_change_watcher = function(bufnr, backend_name)
  local group =
    vim.api.nvim_create_augroup(string.format("Aerial%s", backend_name), { clear = false })
  vim.api.nvim_clear_autocmds({
    group = group,
    buffer = bufnr,
  })
end

return M
