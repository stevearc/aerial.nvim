local config = require 'aerial.config'
local data = require 'aerial.data'
local render = require 'aerial.render'
local util = require 'aerial.util'

local M = {}

local function create_aerial_buffer(bufnr)
  local aer_bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_set_current_buf(aer_bufnr)
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

  vim.cmd[[autocmd BufEnter <buffer> lua require'aerial.autocommands'.on_enter_aerial_buffer()]]
  return aer_bufnr
end

local function create_aerial_window(bufnr, aer_bufnr, direction)
  if direction == '<' then direction = 'left' end
  if direction == '>' then direction = 'right' end
  if direction ~= 'left' and direction ~= 'right' then
    error("Expected direction to be 'left' or 'right'")
    return
  end
  local winids = util.get_fixed_wins(bufnr)
  local split_target
  if direction == 'left' then
    split_target = winids[1]
  else
    split_target = winids[#winids]
  end
  local my_winid = vim.api.nvim_get_current_win()
  if my_winid ~= split_target then
    vim.api.nvim_set_current_win(split_target)
  end
  if direction == 'left' then
    vim.cmd('vertical leftabove split')
  else
    vim.cmd('vertical rightbelow split')
  end

  if aer_bufnr == -1 then
    aer_bufnr = create_aerial_buffer(bufnr)
  end
  vim.api.nvim_set_current_buf(aer_bufnr)

  vim.cmd('vertical resize ' .. util.get_width())
  vim.api.nvim_win_set_option(0, 'winfixwidth', true)
  vim.api.nvim_win_set_option(0, 'number', false)
  vim.api.nvim_win_set_option(0, 'relativenumber', false)
  vim.api.nvim_win_set_option(0, 'wrap', false)
  local aer_winid = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(my_winid)
  return aer_winid
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

M.maybe_open_automatic = function()
  if not config.open_automatic() then
    return false
  end
  if data[0]:count() < config.open_automatic_min_symbols then
    return false
  end
  if vim.api.nvim_buf_line_count(0) < config.open_automatic_min_lines then
    return false
  end
  M.open(false)
  return true
end

M.open = function(focus, direction)
  -- We get empty strings from the vim command
  if focus == '' then
    focus = true
  elseif focus == '!' then
    focus = false
  end
  if direction == '' then
    direction = nil
  end
  if vim.lsp.buf_get_clients() == 0 then
    error("Cannot open aerial. No LSP clients")
    return
  end
  local bufnr, aer_bufnr = util.get_buffers()
  if M.is_open() then
    if focus then
      local winid = vim.fn.bufwinid(aer_bufnr)
      vim.api.nvim_set_current_win(winid)
    end
    return
  end
  direction = direction or util.detect_split_direction()
  local aer_winid = create_aerial_window(bufnr, aer_bufnr, direction)
  if not data:has_symbols(bufnr) then
    vim.lsp.buf.document_symbol()
  end
  local my_winid = vim.api.nvim_get_current_win()
  M.update_position(nil, my_winid)
  if focus then
    vim.api.nvim_set_current_win(aer_winid)
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

local function get_position_in_win(bufnr, winid)
  local lnum = vim.api.nvim_win_get_cursor(winid or 0)[1]
  local bufdata = data[bufnr]
  local selected = 0
  local relative = 'above'
  bufdata:visit(function(item)
    if item.lnum > lnum then
      return true
    elseif item.lnum == lnum then
      relative = 'exact'
    else
      relative = 'below'
    end
    selected = selected + 1
  end)
  return {
    lnum = math.max(1, selected),
    relative = relative
  }
end

M.update_all_positions = function(bufnr)
  local winids = vim.fn.win_findbuf(bufnr)
  M.update_position(winids, false)
end

M.update_position = function(winid, update_last)
  if winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end
  local win_bufnr = vim.api.nvim_win_get_buf(winid)
  local bufnr, aer_bufnr = util.get_buffers(win_bufnr)
  local winids
  if not winid or util.is_aerial_buffer(win_bufnr) then
    winids = util.get_fixed_wins(bufnr)
  elseif type(winid) == 'table' then
    winids = winid
  else
    winids = {winid}
  end


  local bufdata = data[bufnr]
  for _,target_win in ipairs(winids) do
    local pos = get_position_in_win(bufnr, target_win)
    if pos ~= nil then
      bufdata.positions[target_win] = pos.lnum
      if update_last and (update_last == true or update_last == target_win) then
        bufdata.last_position = pos.lnum
      end
    end
  end

  render.update_highlights(bufnr)
  if update_last then
    local aer_winid = vim.fn.bufwinid(aer_bufnr)
    if aer_winid ~= -1 then
      vim.api.nvim_win_set_cursor(aer_winid, {bufdata.last_position, 0})
    end
  end
end

return M
