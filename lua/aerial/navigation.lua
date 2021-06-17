local data = require 'aerial.data'
local util = require 'aerial.util'
local config = require 'aerial.config'
local window = require 'aerial.window'

local M = {}

local function _get_pos_in_win(bufnr, winid)
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

local function _get_current_lnum()
  local bufnr = vim.api.nvim_get_current_buf()
  if util.is_aerial_buffer(bufnr) then
    bufnr = util.get_source_buffer()
    local winid = vim.fn.bufwinid(bufnr)
    if winid == -1 then
      return nil
    end
    local bufdata = data[bufnr]
    local cached_lnum = bufdata.positions[winid]
    return cached_lnum == nil and nil or {
      ['lnum'] = cached_lnum,
      ['relative'] = 'exact',
    }
  else
    if data:has_symbols(bufnr) then
      return _get_pos_in_win(bufnr)
    else
      return nil
    end
  end
end

M.next = function(step)
  step = step or 1
  local pos = _get_current_lnum()
  if pos == nil then
    return
  end
  local bufnr, _ = util.get_buffers()

  local count = data[bufnr]:count()
  local new_num = pos.lnum + step
  -- If we're not *exactly* on a location, make sure we hit the nearest location
  -- first even if we're currently considered to be "on" it
  if step < 0 and pos.relative == 'below' then
    new_num = new_num + 1
  elseif step > 0 and pos.relative == 'above' then
    new_num = new_num - 1
  end
  while new_num < 1 do
    new_num = new_num + count
  end
  while new_num > count do
    new_num = new_num - count
  end
  M.select{
    index = new_num,
    jump = false,
  }
  if util.is_aerial_buffer() then
    vim.api.nvim_win_set_cursor(0, {new_num, 0})
  end
end

M.select = function(opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    index = nil,
    split = nil,
    jump = true,
  })
  local bufnr, _ = util.get_buffers()
  local my_winid = vim.api.nvim_get_current_win()
  local winid
  if util.is_aerial_buffer() then
    if string.find(vim.o.switchbuf, "uselast") then
      vim.cmd("noau wincmd p")
      winid = vim.api.nvim_get_current_win()
      util.go_win_no_au(my_winid)
    else
      winid = vim.fn.win_findbuf(bufnr)[1]
    end
  else
    winid = vim.api.nvim_get_current_win()
  end
  if not winid or winid == -1 then
    error("Could not find destination window")
    return
  end
  if opts.index == nil then
    if util.is_aerial_buffer() then
      opts.index = vim.api.nvim_win_get_cursor(0)[1]
    else
      local bufdata = data[0]
      opts.index = bufdata.positions[winid]
    end
    opts.index = opts.index or 1
  end

  local item = data[0]:item(opts.index)
  if not item then
    error(string.format("Symbol %s is outside the bounds", opts.index))
    return
  end

  if opts.split then
    local split = opts.split
    if split == 'vertical' or split == 'v' then
      split = 'belowright vsplit'
    elseif split == 'horizontal' or split == 'h' or split == 's' then
      split = 'belowright split'
    end
    util.go_win_no_au(winid)
    vim.cmd(split)
    winid = vim.api.nvim_get_current_win()
    util.go_win_no_au(my_winid)
  end
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.api.nvim_win_set_cursor(winid, {item.lnum, item.col})
  vim.fn.win_execute(winid, 'normal! zvzz', true)

  if opts.jump then
    vim.api.nvim_set_current_win(winid)
  else
    window.update_position(winid)
  end
  if config.highlight_on_jump then
    util.flash_highlight(bufnr, item.lnum, config.highlight_on_jump)
  end
end

return M
