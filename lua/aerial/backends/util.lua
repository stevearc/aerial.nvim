local backends = require("aerial.backends")
local config = require("aerial.config")
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

local timer = nil
local function throttle_update(backend_name)
  if timer or not backends.is_backend_attached(0, backend_name) then
    return
  end
  timer = vim.loop.new_timer()
  timer:start(
    config[backend_name].update_delay or 300,
    0,
    vim.schedule_wrap(function()
      timer:close()
      timer = nil
      local backend = backends.get_backend_by_name(backend_name)
      if backend then
        backend.fetch_symbols()
      end
    end)
  )
end

M._on_text_changed = function(backend_name)
  throttle_update(backend_name)
end

M._on_insert_leave = function(backend_name)
  throttle_update(backend_name)
end

return M
