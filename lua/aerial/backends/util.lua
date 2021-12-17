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
      au TextChanged <buffer=%d> lua require'aerial.backends.util'._on_text_changed('%s')
      au InsertLeave <buffer=%d> lua require'aerial.backends.util'._on_insert_leave('%s')
    augroup END
    ]],
    backend_name,
    bufnr,
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

local update_symbols = util.throttle(function(backend_name)
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

M._on_text_changed = update_symbols
M._on_insert_leave = update_symbols

return M
