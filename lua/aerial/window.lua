local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local render = require 'aerial.render'
local util = require 'aerial.util'

local M = {}

M.create_aerial_window = function(bufnr, aer_bufnr, direction)
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
    vim.cmd('vertical leftabove split')
  elseif direction == '>' then
    vim.cmd('vertical rightbelow split')
  else
    error("Unknown aerial window direction " .. direction)
    return
  end

  if aer_bufnr == -1 then
    aer_bufnr = M._create_aerial_buffer(bufnr)
  end
  vim.api.nvim_set_current_buf(aer_bufnr)

  vim.cmd('vertical resize ' .. util.get_width())
  vim.api.nvim_win_set_option(0, 'winfixwidth', true)
  vim.api.nvim_win_set_option(0, 'number', false)
  vim.api.nvim_win_set_option(0, 'relativenumber', false)
  vim.api.nvim_win_set_option(0, 'wrap', false)
end

M._create_aerial_buffer = function(bufnr)
  local aer_bufnr = vim.api.nvim_create_buf(false, true)

  -- Set up default mappings
  local mapper = function(mode, key, result)
    vim.api.nvim_buf_set_keymap(aer_bufnr, mode, key, result, {noremap = true, silent = true})
  end
  mapper('n', '<CR>', "<cmd>lua require'aerial'.jump_to_loc()<CR>zvzz")
  mapper('n', '<C-v>', "<cmd>lua require'aerial'.jump_to_loc(2)<CR>zvzz")
  mapper('n', '<C-s>', "<cmd>lua require'aerial'.jump_to_loc(2, 'belowright split')<CR>zvzz")
  mapper('n', '<C-j>', "j<cmd>lua require'aerial'.scroll_to_loc()<CR>")
  mapper('n', '<C-k>', "k<cmd>lua require'aerial'.scroll_to_loc()<CR>")
  mapper('n', ']]', "<cmd>lua require'aerial'.next_item()<CR>")
  mapper('n', '[[', "<cmd>lua require'aerial'.prev_item()<CR>")
  mapper('n', 'p', "<cmd>lua require'aerial'.scroll_to_loc()<CR>")
  mapper('n', 'q', '<cmd>lua require"aerial".close()<CR>')

  -- Set buffer options
  vim.api.nvim_buf_set_lines(aer_bufnr, 0, -1, false, {"Loading..."})
  vim.api.nvim_buf_set_var(bufnr, 'aerial_buffer', aer_bufnr)
  vim.api.nvim_buf_set_var(aer_bufnr, 'source_buffer', bufnr)
  vim.api.nvim_buf_set_option(aer_bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(aer_bufnr, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(aer_bufnr, 'buflisted', false)
  vim.api.nvim_buf_set_option(aer_bufnr, 'swapfile', false)
  vim.api.nvim_buf_set_option(aer_bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(aer_bufnr, 'filetype', 'aerial')
  render.update_aerial_buffer(bufnr)

  vim.api.nvim_set_current_buf(aer_bufnr)
  vim.cmd[[autocmd BufEnter <buffer> lua require'aerial.autocommands'.on_enter_aerial_buffer()]]
  return aer_bufnr
end

M.is_open = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return false
  else
    local winid = vim.fn.bufwinid(aer_bufnr)
    return winid ~= -1
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    vim.cmd('close')
    return
  end
  local aer_bufnr = util.get_aerial_buffer()
  local winnr = vim.fn.bufwinnr(aer_bufnr)
  if winnr ~= -1 then
    vim.cmd(winnr .. "close")
  end
end

M._maybe_open_automatic = function()
  if not config.get_open_automatic() then
    return false
  end
  local items = data.items_by_buf[vim.api.nvim_get_current_buf()]
  if items == nil or #items < config.get_open_automatic_min_symbols() then
    return false
  end
  if vim.fn.line('$') < config.get_open_automatic_min_lines() then
    return false
  end
  M.open(false, config.get_automatic_direction())
  return true
end

M.open = function(focus, direction)
  if vim.lsp.buf_get_clients() == 0 then
    error("Cannot open aerial. No LSP clients")
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if M.is_open() then
    if focus then
      local winid = vim.fn.bufwinid(aer_bufnr)
      vim.api.nvim_set_current_win(winid)
    end
    return
  end
  direction = direction or util.detect_split_direction()
  local start_winid = vim.fn.win_getid()
  M.create_aerial_window(bufnr, aer_bufnr, direction)
  if aer_bufnr == -1 then
    aer_bufnr = vim.api.nvim_get_current_buf()
  end
  vim.api.nvim_set_current_win(start_winid)
  if data.items_by_buf[bufnr] == nil then
    vim.lsp.buf.document_symbol()
  end
  nav._update_position()
  if focus then
    vim.api.nvim_set_current_win(vim.fn.bufwinid(aer_bufnr))
  end
end

M.focus = function()
  if not M.is_open() then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  local winid = vim.fn.bufwinid(aer_bufnr)
  vim.api.nvim_set_current_win(winid)
end

M.toggle = function(focus, direction)
  if util.is_aerial_buffer() then
    vim.cmd('close')
    return false
  end

  if M.is_open() then
    M.close()
    return false
  else
    M.open(focus, direction)
    return true
  end
end

return M
