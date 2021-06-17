local config = require 'aerial.config'

local M = {}

M.rpad = function(str, length, padchar)
  if string.len(str) < length then
    return str .. string.rep(padchar or ' ', length - string.len(str))
  end
  return str
end

M.lpad = function(str, length, padchar)
  if string.len(str) < length then
    return string.rep(padchar or ' ', length - string.len(str)) .. str
  end
  return str
end

M.get_width = function(bufnr)
  local ok, width = pcall(vim.api.nvim_buf_get_var, bufnr or 0, 'aerial_width')
  if ok then
    return width
  end
  return config.get_min_width()
end

M.set_width = function(bufnr, width)
  if M.get_width(bufnr) == width then
    return
  end
  vim.api.nvim_buf_set_var(bufnr, 'aerial_width', width)

  for _,winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.fn.win_execute(winid, 'vertical resize ' .. width, true)
  end
end

M.is_aerial_buffer = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, 'filetype')
  return ft == 'aerial'
end

M.get_aerial_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, 'aerial_buffer')
end

M.get_buffers = function(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if M.is_aerial_buffer(bufnr) then
    return M.get_source_buffer(bufnr), bufnr
  else
    return bufnr, M.get_aerial_buffer(bufnr)
  end
end

M.get_source_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, 'source_buffer')
end

M.get_buffer_from_var = function(bufnr, varname)
  local status, result_bufnr = pcall(vim.api.nvim_buf_get_var, bufnr, varname)
  if not status or result_bufnr == nil then
    return -1
  end
  return vim.fn.bufnr(result_bufnr)
end

M.flash_highlight = function(bufnr, lnum, hl_group, durationMs)
  hl_group = hl_group or 'AerialLine'
  durationMs = durationMs or 300
  local ns = vim.api.nvim_buf_add_highlight(bufnr, 0, hl_group, lnum - 1, 0, -1)
  local remove_highlight = function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
  vim.defer_fn(remove_highlight, durationMs)
end

M.get_fixed_wins = function()
  local wins = {}
  for _,winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not M.is_floating_win(winid) then
      table.insert(wins, winid)
    end
  end
  return wins
end

M.is_floating_win = function(winid)
  return vim.api.nvim_win_get_config(winid).relative ~= ""
end

M.detect_split_direction = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local wins = M.get_fixed_wins()
  local first_window = vim.fn.winbufnr(wins[1]) == bufnr
  local last_window = vim.fn.winbufnr(wins[#wins]) == bufnr
  local default = config.get_default_direction()

  if default == 'left' then
    if first_window then
      return 'left'
    elseif last_window then
      return 'right'
    end
  else
    if last_window then
      return 'right'
    elseif first_window then
      return 'left'
    end
  end

  return default
end

return M
