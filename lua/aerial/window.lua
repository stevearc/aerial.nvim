local data = require 'aerial.data'
local util = require 'aerial.util'
local config = require 'aerial.config'

local M = {}

M.create_aerial_window = function(bufnr, direction)
  if direction ~= '<' and direction ~= '>' then
    error("Expected direction to be '<' or '>'")
  end
  local winnr
  for i=1,vim.fn.winnr('$'),1 do
    if vim.fn.winbufnr(i) == bufnr then
      winnr = i
      if direction == '<' then
        break
      end
    end
  end
  if winnr ~= vim.fn.winnr() then
    vim.api.nvim_set_current_win(vim.fn.win_getid(winnr))
  end
  if direction == '<' then
    vim.cmd('vertical leftabove new')
  elseif direction == '>' then
    vim.cmd('vertical rightbelow new')
  else
    error("Unknown aerial window direction " .. direction)
    return
  end
  vim.cmd('vertical resize ' .. util.get_width())
  vim.api.nvim_win_set_option(0, 'winfixwidth', true)
  vim.api.nvim_win_set_option(0, 'number', false)
  vim.api.nvim_win_set_option(0, 'relativenumber', false)
end

M.create_aerial_buffer = function(bufnr, direction)
  M.create_aerial_window(bufnr, direction)
  win = vim.api.nvim_get_current_win()
  buf = vim.api.nvim_get_current_buf()

  -- Set up default mappings
  local mapper = function(mode, key, result)
    vim.fn.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
  end
  mapper('n', '<CR>', "<cmd>lua require'aerial'.jump_to_loc()<CR>zzzv")
  mapper('n', '<C-v>', "<cmd>lua require'aerial'.jump_to_loc(2)<CR>zzzv")
  mapper('n', '<C-s>', "<cmd>lua require'aerial'.jump_to_loc(2, 'belowright split')<CR>zzzv")
  mapper('n', '<C-j>', "j<cmd>lua require'aerial'.scroll_to_loc()<CR>")
  mapper('n', '<C-k>', "k<cmd>lua require'aerial'.scroll_to_loc()<CR>")
  mapper('n', ']]', "<cmd>lua require'aerial'.next_item()<CR>")
  mapper('n', '[[', "<cmd>lua require'aerial'.prev_item()<CR>")
  mapper('n', 'p', "<cmd>lua require'aerial'.scroll_to_loc()<CR>")
  mapper('n', 'q', '<cmd>lua require"aerial".close()<CR>')

  -- Set buffer options
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Loading..."})
  vim.api.nvim_buf_set_var(bufnr, 'aerial_buffer', buf)
  vim.api.nvim_buf_set_var(buf, 'source_buffer', bufnr)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'buflisted', false)
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'aerial')
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
  M.update_aerial_buffer(bufnr)

  vim.cmd("autocmd BufEnter <buffer> lua require'aerial.autocommands'.on_enter_aerial_buffer()")
end

-- Update the aerial buffer from cached symbols
M.update_aerial_buffer = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return
  end
  local items = data.items_by_buf[bufnr]
  if items == nil then
    return
  end
  local max_len = 1

  -- Replace SymbolKind with abbreviations
  for _,item in ipairs(items) do
    item.text = string.gsub(item.text, item.kind, config.get_kind_abbr(item.kind), 1)
  end

  -- Calculate window width
  for _,item in ipairs(items) do
    local len = string.len(item.text)
    if len > max_len then
      max_len = len
    end
  end
  local width = math.min(config.get_max_width(), math.max(config.get_min_width(), max_len))
  util.set_width(aer_bufnr, width)

  -- Insert lines into buffer
  local lines = {}
  for _,item in ipairs(items) do
    table.insert(lines, util.rpad(item.text, width))
  end
  vim.api.nvim_buf_set_option(aer_bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_lines(aer_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(aer_bufnr, 'modifiable', false)
end

-- Update the highlighted lines in the aerial buffer
M.update_highlights = function(bufnr)
  local positions = data.positions_by_buf[bufnr]
  if positions == nil then
    return
  end
  local winids = {}
  local win_count = 0
  for k in pairs(positions) do
    local winnr = vim.fn.win_id2win(k)
    if winnr ~= 0 and vim.fn.winbufnr(k) == bufnr then
      win_count = win_count + 1
      table.insert(winids, k)
    end
  end
  local sortWinId = function(a, b)
    return vim.fn.win_id2win(a) < vim.fn.win_id2win(b)
  end
  table.sort(winids, sortWinId)
  local ns = vim.api.nvim_create_namespace('aerial')
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return
  end
  vim.api.nvim_buf_clear_namespace(aer_bufnr, ns, 0, -1)
  local hl_width = math.floor(util.get_width(aer_bufnr) / win_count)
  local hl_mode = config.get_highlight_mode()

  if hl_mode == 'last' then
    local row = data.last_position_by_buf[bufnr]
    vim.api.nvim_buf_add_highlight(
      aer_bufnr,
      ns,
      config.get_highlight_group(),
      row - 1,
      0,
      -1)
    return
  end

  if win_count == 1 or hl_mode == 'full_width' then
    -- Will make end_hl -1, which is the special value for "entire line"
    hl_width = -2
  end
  local start_hl = 0
  local end_hl = hl_width
  for _,winid in ipairs(winids) do
    vim.api.nvim_buf_add_highlight(
      aer_bufnr,
      ns,
      config.get_highlight_group(),
      positions[winid] - 1,
      start_hl,
      end_hl)
    if hl_mode ~= 'full_width' then
      start_hl = end_hl
      end_hl = end_hl + hl_width
    end
  end
end

return M
