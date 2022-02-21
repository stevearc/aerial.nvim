local backends = require("aerial.backends")
local config = require("aerial.config")
local util = require("aerial.util")
local M = {}

M.add_change_watcher = function(bufnr, backend_name)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  vim.cmd(string.format(
    [[augroup Aerial%s
      au! * <buffer=%d>
      au %s <buffer=%d> lua require'aerial.backends.util'._update_symbols('%s')
    augroup END
    ]],
    backend_name,
    bufnr,
    config.update_events,
    bufnr,
    backend_name,
    bufnr,
    backend_name
  ))
end

M.remove_change_watcher = function(bufnr, backend_name)
  vim.cmd(string.format(
    [[augroup Aerial%s
      au! * <buffer=%d>
    augroup END
    ]],
    backend_name,
    bufnr
  ))
end

M._update_symbols = util.throttle(function(backend_name)
  if backends.is_backend_attached(0, backend_name) then
    local backend = backends.get_backend_by_name(backend_name)
    if backend then
      backend.fetch_symbols()
    end
  end
end, {
  delay = function(backend_name)
    return config[backend_name].update_delay or 300
  end,
  reset_timer_on_call = true,
})

return M
