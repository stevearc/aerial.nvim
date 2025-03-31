local config = require("aerial.config")

local M = {}

---@param str string
---@param length integer
---@param padchar nil|string
---@return string
M.rpad = function(str, length, padchar)
  local strlen = vim.api.nvim_strwidth(str)
  if strlen < length then
    return str .. string.rep(padchar or " ", length - strlen)
  end
  return str
end

---@param str string
---@param length integer
---@param padchar nil|string
---@return string
M.lpad = function(str, length, padchar)
  if string.len(str) < length then
    return string.rep(padchar or " ", length - string.len(str)) .. str
  end
  return str
end

---@param str string
---@return string
M.remove_newlines = function(str)
  local ret = string.gsub(str, "\n", " ")
  return ret
end

---@param winid nil|integer
---@return integer
M.win_get_gutter_width = function(winid)
  winid = winid or 0
  if vim.wo[winid].number or vim.wo[winid].relativenumber then
    return vim.wo[winid].numberwidth
  else
    return 0
  end
end

---@param bufnr nil|integer
---@return boolean
M.is_aerial_buffer = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr or 0) then
    return false
  end
  local ft = vim.bo[bufnr or 0].filetype
  return ft == "aerial"
end

---@param winid nil|integer
---@return boolean
M.is_aerial_win = function(winid)
  local bufnr = vim.api.nvim_win_get_buf(winid or 0)
  return M.is_aerial_buffer(bufnr)
end

---@param winid nil|integer
M.go_win_no_au = function(winid)
  if winid == nil or winid == 0 or winid == vim.api.nvim_get_current_win() then
    return
  end
  local winnr = vim.api.nvim_win_get_number(winid)
  vim.cmd(string.format("noau %dwincmd w", winnr))
end

---@param bufnr nil|integer
M.go_buf_no_au = function(bufnr)
  if bufnr == nil or bufnr == 0 or bufnr == vim.api.nvim_get_current_buf() then
    return
  end
  vim.cmd(string.format("noau b %d", bufnr))
end

---@param bufnr integer
---@return nil|integer
M.buf_first_win_in_tabpage = function(bufnr)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end
end

---@param winid? integer
---@return integer? Source window
---@return integer? Aerial window
M.get_winids = function(winid)
  if winid == nil or winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end
  local bufnr = vim.api.nvim_win_get_buf(winid)
  if M.is_aerial_buffer(bufnr) then
    return M.get_source_win(winid), winid
  else
    return winid, M.get_aerial_win(winid)
  end
end

---@param winid integer
---@param varname string
---@return integer?
M.get_winid_from_var = function(winid, varname)
  local status, result_winid = pcall(vim.api.nvim_win_get_var, winid, varname)
  if status and result_winid ~= nil and vim.api.nvim_win_is_valid(result_winid) then
    return result_winid
  end
end

---@param winid? integer
---@return integer?
M.get_aerial_win = function(winid)
  local aerial_win = M.get_winid_from_var(winid or 0, "aerial_win")
  if not aerial_win and config.attach_mode == "global" then
    for _, tab_win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if M.is_aerial_win(tab_win) then
        aerial_win = tab_win
        break
      end
    end
  end
  return aerial_win
end

---@param winid? integer
---@return integer?
M.get_source_win = function(winid)
  return M.get_winid_from_var(winid or 0, "source_win")
end

---@param bufnr nil|integer
---@return nil|integer Source buffer
---@return nil|integer Aerial buffer
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

---@param bufnr nil|integer
---@return nil|integer
M.get_aerial_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, "aerial_buffer")
end

---@param bufnr nil|integer
---@return nil|integer
M.get_source_buffer = function(bufnr)
  return M.get_buffer_from_var(bufnr or 0, "source_buffer")
end

---@param bufnr integer
---@param varname string
---@return nil|integer
M.get_buffer_from_var = function(bufnr, varname)
  local status, result_bufnr = pcall(vim.api.nvim_buf_get_var, bufnr, varname)
  if
    not status
    or result_bufnr == nil
    or not vim.api.nvim_buf_is_valid(result_bufnr)
    or not vim.api.nvim_buf_is_loaded(result_bufnr)
  then
    return nil
  end
  return result_bufnr
end

M.flash_highlight = function(bufnr, lnum, durationMs, hl_group)
  hl_group = hl_group or "AerialLine"
  if durationMs == true or durationMs == 1 then
    durationMs = 300
  end
  local ns = vim.api.nvim_create_namespace("AerialFlashHighlight")
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1]
  local ext_id = vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
    end_col = #line,
    hl_group = hl_group,
  })
  local remove_highlight = function()
    vim.api.nvim_buf_del_extmark(bufnr, ns, ext_id)
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
    if
      vim.api.nvim_win_is_valid(winid)
      and not M.is_floating_win(winid)
      and (not bufnr or vim.api.nvim_win_get_buf(winid) == bufnr)
    then
      table.insert(wins, winid)
    end
  end
  return wins
end

M.get_non_ignored_fixed_wins = function(bufnr)
  return vim.tbl_filter(function(winid)
    return not M.is_ignored_win(winid)
  end, M.get_fixed_wins(bufnr))
end

---@param winid nil|integer
---@return boolean
M.is_floating_win = function(winid)
  return vim.api.nvim_win_get_config(winid or 0).relative ~= ""
end

---@param filetype string
---@return boolean
M.is_ignored_filetype = function(filetype)
  local ignore = config.ignore
  return ignore.filetypes and vim.tbl_contains(ignore.filetypes, filetype)
end

---@param bufnr nil|integer
---@return boolean
---@return nil|string
M.is_ignored_buf = function(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true, "Buffer is not valid"
  end
  local filetypes = M.get_filetypes(bufnr)
  -- Never ignore aerial buffers
  if vim.tbl_contains(filetypes, "aerial") then
    return false
  end
  local ignore = config.ignore
  if ignore.unlisted_buffers and not vim.bo[bufnr].buflisted then
    return true, "Buffer is not listed"
  end
  if ignore.buftypes then
    local buftype = vim.bo[bufnr].buftype
    local filetype = vim.bo[bufnr].filetype
    if ignore.buftypes == "special" then
      if buftype ~= "" and buftype ~= "help" and filetype ~= "man" then
        return true, string.format("Buftype '%s' is \"special\"", buftype)
      end
    elseif type(ignore.buftypes) == "table" then
      if vim.tbl_contains(ignore.buftypes, buftype) then
        return true, string.format("Buftype '%s' is ignored", buftype)
      end
    elseif type(ignore.buftypes) == "function" then
      if ignore.buftypes(bufnr, buftype) then
        return true, string.format("Buftype '%s' is ignored", buftype)
      end
    end
  end
  if ignore.filetypes then
    for _, filetype in ipairs(filetypes) do
      if M.is_ignored_filetype(filetype) then
        return true, string.format("Filetype '%s' is ignored", filetype)
      end
    end
  end
  return false
end

---@param winid nil|integer
---@return boolean
---@return nil|string
M.is_ignored_win = function(winid)
  if not winid or winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local ignore_buf, message = M.is_ignored_buf(bufnr)
  if ignore_buf then
    return ignore_buf, message
  end
  local ignore = config.ignore
  if ignore.diff_windows and vim.wo[winid].diff then
    return true, "Viewing a diff"
  end
  if ignore.wintypes then
    local wintype = vim.fn.win_gettype(winid)
    if ignore.wintypes == "special" and wintype ~= "" then
      return true, string.format("Wintype '%s' is \"special\"", wintype)
    elseif type(ignore.wintypes) == "table" then
      if vim.tbl_contains(ignore.wintypes, wintype) then
        return true, string.format("Wintype '%s' is ignored", wintype)
      end
    end
  end
  return false
end

---@param winid nil|integer
---@return boolean
M.is_managing_folds = function(winid)
  return vim.wo[winid or 0].foldexpr == "v:lua.aerial_foldexpr()"
end

---@return "left"|"right"|"float"
M.detect_split_direction = function()
  local default = config.layout.default_direction
  if default ~= "prefer_left" and default ~= "prefer_right" then
    return default
  end
  local wins = M.get_fixed_wins()
  local left_available, right_available
  if config.layout.placement == "edge" then
    left_available = not M.is_aerial_buffer(vim.api.nvim_win_get_buf(wins[1]))
    right_available = not M.is_aerial_buffer(vim.api.nvim_win_get_buf(wins[#wins]))
  elseif config.layout.placement == "window" then
    local mywin = vim.api.nvim_get_current_win()
    left_available = wins[1] == mywin
    right_available = wins[#wins] == mywin
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
  local winid
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      winid = win
      break
    end
  end
  local height = 40
  local width = 30
  if winid then
    height = vim.api.nvim_win_get_height(winid)
    width = vim.api.nvim_win_get_width(winid)
  end
  local lines = {}
  for _ = 1, (height / 2) - (#text / 2) do
    table.insert(lines, "")
  end
  for _, line in ipairs(text) do
    line = string.rep(" ", (width - vim.api.nvim_strwidth(line)) / 2) .. line
    table.insert(lines, line)
  end
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

M.pack = function(...)
  return { n = select("#", ...), ... }
end

M.throttle = function(func, opts)
  opts = opts or {}
  opts.delay = opts.delay or 300
  local timer = nil
  return function(...)
    if timer then
      if opts.reset_timer_on_call then
        timer:close()
        timer = nil
      else
        return timer
      end
    end
    local args = M.pack(...)
    local delay = opts.delay
    if type(delay) == "function" then
      delay = delay(unpack(args))
    end
    timer = assert(vim.loop.new_timer())
    timer:start(delay, 0, function()
      timer:close()
      timer = nil
      vim.schedule_wrap(func)(unpack(args))
    end)
    return timer
  end
end

---@generic T : any
---@param tbl T[]
---@return T[]
M.tbl_reverse = function(tbl)
  local len = #tbl
  for i = 1, math.floor(len / 2) do
    local j = len - i + 1
    local swp = tbl[i]
    tbl[i] = tbl[j]
    tbl[j] = swp
  end
  return tbl
end

M.get_filetypes = config.get_filetypes

return M
