local data = require 'aerial.data'
local util = require 'aerial.util'
local config = require 'aerial.config'
local render = require 'aerial.render'

local M = {}

M._get_virt_winid = function(bufnr, virt_winnr)
  local vwin = 1
  for i=1,vim.fn.winnr('$'),1 do
    if vim.fn.winbufnr(i) == bufnr then
      if vwin == virt_winnr then
        return vim.fn.win_getid(i)
      end
      vwin = vwin + 1
    end
  end

  return -1
end

M._get_current_lnum = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.fn.getcurpos()[2]
  if util.is_aerial_buffer(bufnr) then
    bufnr = util.get_source_buffer()
    local winid = M._get_virt_winid(bufnr, 1)
    if winid == -1 then
      return nil
    end
    local bufdata = data[bufnr]
    local cached_lnum = bufdata.positions[winid]
    return cached_lnum == nil and nil or {
      ['lnum'] = cached_lnum,
      ['relative'] = 'exact',
    }
  end
  if not data:has_symbols(bufnr) then
    return nil
  end
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
    ['lnum'] = math.max(1, selected),
    ['relative'] = relative
  }
end

M._update_position = function()
  local pos = M._get_current_lnum()
  if pos == nil then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  local mywin = vim.api.nvim_get_current_win()
  local bufdata = data[bufnr]
  bufdata.positions[mywin] = pos.lnum
  bufdata.last_position = pos.lnum
  render.update_highlights(bufnr)
  local winid = vim.fn.bufwinid(aer_bufnr)
  if winid ~= -1 then
    vim.fn.win_execute(winid, string.format('normal %dgg', pos.lnum), true)
  end
end

M._jump_to_loc = function(item_no, virt_winnr, split_cmd)
  virt_winnr = virt_winnr or 1
  split_cmd = split_cmd or 'belowright vsplit'
  local bufnr = util.get_source_buffer()
  if not data:has_symbols(bufnr) then
    return
  end
  local item = data[bufnr]:item(item_no)
  if item == nil then
    error("Could not find item at position " .. item_no)
    return
  end
  bufnr = util.get_source_buffer()
  local winid = M._get_virt_winid(bufnr, virt_winnr)
  if winid == -1 then
    -- Create a new split for the source window
    winid = vim.fn.bufwinid(bufnr)
    if winid ~= -1 then
      vim.fn.win_gotoid(winid)
      vim.cmd(split_cmd)
    else
      vim.cmd(split_cmd)
      vim.api.nvim_set_current_buf(bufnr)
    end
    vim.fn.setpos('.', {bufnr, item.lnum, item.col, 0})
  else
    vim.fn.win_gotoid(winid)
    vim.fn.setpos('.', {bufnr, item.lnum, item.col, 0})
  end
  return item
end

M.jump_to_loc = function(virt_winnr, split_cmd)
  local pos = vim.fn.getcurpos()
  local item = M._jump_to_loc(pos[2], virt_winnr, split_cmd)
  if config.get_highlight_on_jump() then
    util.flash_highlight(vim.api.nvim_get_current_buf(), item.lnum)
  end
end

M.scroll_to_loc = function(virt_winnr, split_cmd)
  M.jump_to_loc(virt_winnr, split_cmd)
  M._update_position()
  vim.cmd('normal zvzz')
  vim.cmd('wincmd p')
end

M.skip_item = function(delta)
  local pos = M._get_current_lnum()
  if pos == nil then
    return
  end
  local bufnr
  if util.is_aerial_buffer(bufnr) then
    bufnr = util.get_source_buffer()
  else
    bufnr = vim.api.nvim_get_current_buf()
  end

  local count = data[bufnr]:count()
  local new_num = pos.lnum + delta
  -- If we're not *exactly* on a location, make sure we hit the nearest location
  -- first even if we're currently considered to be "on" it
  if delta < 0 and pos.relative == 'below' then
    new_num = new_num + 1
  elseif delta > 0 and pos.relative == 'above' then
    new_num = new_num - 1
  end
  while new_num < 1 do
    new_num = new_num + count
  end
  while new_num > count do
    new_num = new_num - count
  end
  local item = data[bufnr]:item(new_num)
  if util.is_aerial_buffer() then
    M._jump_to_loc(new_num, 1)
    M._update_position()
    vim.cmd('normal zvzz')
    vim.cmd('wincmd p')
  else
    vim.fn.setpos('.', {0, item.lnum, item.col, 0})
  end
end

return M
