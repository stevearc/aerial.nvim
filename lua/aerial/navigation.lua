local data = require 'aerial.data'
local util = require 'aerial.util'
local config = require 'aerial.config'
local window = require 'aerial.window'

local M = {}

local function _get_current_lnum(winid)
  local bufnr = vim.api.nvim_get_current_buf()
  if data:has_symbols(bufnr) then
    local bufdata = data[bufnr]
    local cached_lnum = bufdata.positions[winid]
    if cached_lnum then
      return cached_lnum
    end
  end

  if util.is_aerial_buffer(bufnr) then
    bufnr = util.get_source_buffer()
  end
  if data:has_symbols(bufnr) then
    return window.get_position_in_win(bufnr, winid)
  else
    return nil
  end
end

local function get_target_win()
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
  if winid == -1 then
    return nil
  end
  return winid
end

M.next = function(step, opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    same_level = false
  })
  step = step or 1
  local winid = get_target_win()
  if not winid then
    error("Could not find destination window")
    return
  end
  local pos = _get_current_lnum(winid)
  if pos == nil then
    return
  end
  local bufnr, _ = util.get_buffers()

  local bufdata = data[bufnr]
  -- If we're not *exactly* on a location, make sure we hit the nearest location
  -- first even if we're currently considered to be "on" it
  if step < 0 and pos.relative == 'below' then
    step = step + 1
  elseif step > 0 and pos.relative == 'above' then
    step = step - 1
  end
  local new_num
  if opts.same_level then
    local item = bufdata:item(pos.lnum)
    local all_items = data[bufnr]:flatten(function(candidate)
      return candidate.level == item.level
    end)
    local idx = ((util.tbl_indexof(all_items, item) + step - 1) % #all_items) + 1
    new_num = bufdata:indexof(all_items[idx])
  else
    local count = bufdata:count()
    new_num = ((pos.lnum + step - 1) % count) + 1
  end
  M.select{
    index = new_num,
    jump = false,
    winid = winid,
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
  local winid = opts.winid
  if not winid then
    winid = get_target_win()
  end
  if not winid then
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
    local my_winid = vim.api.nvim_get_current_win()
    util.go_win_no_au(winid)
    vim.cmd(split)
    winid = vim.api.nvim_get_current_win()
    util.go_win_no_au(my_winid)
  end
  local bufnr, _ = util.get_buffers()
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.api.nvim_win_set_cursor(winid, {item.lnum, item.col})
  if config.post_jump_cmd ~= '' then
    vim.fn.win_execute(winid, config.post_jump_cmd, true)
  end

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
