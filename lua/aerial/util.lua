local config = require("aerial.config")

local M = {}

M.rpad = function(str, length, padchar)
  local strlen = vim.fn.strdisplaywidth(str)
  if strlen < length then
    return str .. string.rep(padchar or " ", length - strlen)
  end
  return str
end

M.lpad = function(str, length, padchar)
  if string.len(str) < length then
    return string.rep(padchar or " ", length - string.len(str)) .. str
  end
  return str
end

M.get_width = function(bufnr)
  local ok, width = pcall(vim.api.nvim_buf_get_var, bufnr or 0, "aerial_width")
  if ok then
    return width
  end
  return (config.min_width + config.max_width) / 2
end

M.set_width = function(bufnr, width)
  if M.get_width(bufnr) == width then
    return
  end
  vim.api.nvim_buf_set_var(bufnr, "aerial_width", width)

  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_win_set_width(winid, width)
  end
end

M.is_aerial_buffer = function(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
  return ft == "aerial"
end

M.go_win_no_au = function(winid)
  if winid == vim.api.nvim_get_current_win() then
    return
  end
  local winnr = vim.fn.win_id2win(winid)
  vim.cmd(string.format("noau %dwincmd w", winnr))
end

M.go_buf_no_au = function(bufnr)
  vim.cmd(string.format("noau b %d", bufnr))
end

M.get_aerial_orphans = function()
  local orphans = {}
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local winbuf = vim.api.nvim_win_get_buf(winid)
    if M.is_aerial_buffer(winbuf) and M.is_aerial_buffer_orphaned(winbuf) then
      table.insert(orphans, winid)
    end
  end
  return orphans
end

M.is_aerial_buffer_orphaned = function(bufnr)
  local sourcebuf = M.get_source_buffer(bufnr)
  if sourcebuf == -1 then
    return true
  end
  if config.close_behavior == "global" and not M.is_aerial_buffer() then
    return sourcebuf ~= vim.api.nvim_get_current_buf()
  end
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(winid) == sourcebuf then
      return false
    end
  end
  return true
end

M.get_aerial_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, "aerial_buffer")
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
  return M.get_buffer_from_var(bufnr or 0, "source_buffer")
end

M.get_buffer_from_var = function(bufnr, varname)
  local status, result_bufnr = pcall(vim.api.nvim_buf_get_var, bufnr, varname)
  if not status or result_bufnr == nil or not vim.api.nvim_buf_is_valid(result_bufnr) then
    return -1
  end
  return result_bufnr
end

M.flash_highlight = function(bufnr, lnum, durationMs, hl_group)
  hl_group = hl_group or "AerialLine"
  if durationMs == true or durationMs == 1 then
    durationMs = 300
  end
  local ns = vim.api.nvim_buf_add_highlight(bufnr, 0, hl_group, lnum - 1, 0, -1)
  local remove_highlight = function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
  vim.defer_fn(remove_highlight, durationMs)
end

M.tbl_indexof = function(tbl, value)
  for i, v in ipairs(tbl) do
    if value == v then
      return i
    end
  end
end

M.get_fixed_wins = function(bufnr)
  local wins = {}
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not M.is_floating_win(winid) and (not bufnr or vim.api.nvim_win_get_buf(winid) == bufnr) then
      table.insert(wins, winid)
    end
  end
  return wins
end

M.is_floating_win = function(winid)
  return vim.api.nvim_win_get_config(winid or 0).relative ~= ""
end

M.is_managing_folds = function(winid)
  return vim.api.nvim_win_get_option(winid or 0, "foldexpr") == "aerial#foldexpr()"
end

M.detect_split_direction = function(bufnr)
  local default = config.default_direction
  if default == "left" then
    return "left"
  elseif default == "right" then
    return "right"
  end
  local wins = M.get_fixed_wins()
  local left_available, right_available
  if config.placement_editor_edge then
    left_available = not M.is_aerial_buffer(vim.api.nvim_win_get_buf(wins[1]))
    right_available = not M.is_aerial_buffer(vim.api.nvim_win_get_buf(wins[#wins]))
  else
    if not bufnr or bufnr == 0 then
      bufnr = vim.api.nvim_get_current_buf()
    end
    left_available = vim.api.nvim_win_get_buf(wins[1]) == bufnr
    right_available = vim.api.nvim_win_get_buf(wins[#wins]) == bufnr
  end

  if default == "prefer_left" then
    if left_available then
      return "left"
    elseif right_available then
      return "right"
    else
      return "left"
    end
  else
    if right_available then
      return "right"
    elseif left_available then
      return "left"
    else
      return "right"
    end
  end
end

M.render_centered_text = function(bufnr, text)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if type(text) == "string" then
    text = { text }
  end
  local winid = vim.fn.bufwinid(bufnr)
  local height = 40
  local width = M.get_width(bufnr)
  if winid ~= -1 then
    height = vim.api.nvim_win_get_height(winid)
    width = vim.api.nvim_win_get_width(winid)
  end
  local lines = {}
  for _ = 1, (height / 2) - (#text / 2) do
    table.insert(lines, "")
  end
  for _, line in ipairs(text) do
    line = string.rep(" ", (width - vim.fn.strdisplaywidth(line)) / 2) .. line
    table.insert(lines, line)
  end
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

M.can_show_symbols = function(bufnr)
  for _, client in ipairs(vim.lsp.buf_get_clients(bufnr)) do
    if client.resolved_capabilities.document_symbol then
      return true
    end
  end
  return false
end

return M
