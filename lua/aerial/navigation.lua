local window = require 'aerial.window'
local data = require 'aerial.data'
local util = require 'aerial.util'
local config = require 'aerial.config'

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
  local bufnr = vim.fn.bufnr()
  local lnum = vim.fn.getcurpos()[2]
  if util.is_aerial_buffer(bufnr) then
    bufnr = util.get_source_buffer()
    local winid = M._get_virt_winid(bufnr, 1)
    if winid == -1 then
      return nil
    end
    local positions = data.positions_by_buf[bufnr]
    if positions == nil then
      return nil
    end
    local cached_lnum = positions[winid]
    return {
      ['lnum'] = cached_lnum,
      ['relative'] = 'exact',
    }
  end
  local items = data.items_by_buf[bufnr]
  if items == nil then
    return nil
  end
  local selected = 1
  local relative = 'above'
  for idx,item in ipairs(items) do
    if item.lnum > lnum then
      break
    elseif item.lnum == lnum then
      relative = 'exact'
    else
      relative = 'below'
    end
    selected = idx
  end
  return {
    ['lnum'] = selected,
    ['relative'] = relative
  }
end

M._update_position = function()
  local pos = M._get_current_lnum()
  if pos == nil then
    return
  end
  local bufnr = vim.fn.bufnr()
  local mywin = vim.fn.win_getid()
  data.positions_by_buf[bufnr] = data.positions_by_buf[bufnr] or {}
  data.positions_by_buf[bufnr][mywin] = pos.lnum
  data.last_position_by_buf[bufnr] = pos.lnum
  window.update_highlights(bufnr)
end

M._jump_to_loc = function(item_no, virt_winnr, split_cmd)
  virt_winnr = virt_winnr or 1
  split_cmd = split_cmd or 'belowright vsplit'
  local bufnr = util.get_source_buffer()
  local items = data.items_by_buf[bufnr]
  if items == nil then
    return
  end
  local item = items[item_no]
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

  local items = data.items_by_buf[bufnr]
  local count = 0
  for _ in pairs(items) do count = count + 1 end
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
  local item = items[new_num]
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
