local backends = require("aerial.backends")
local bindings = require("aerial.bindings")
local config = require("aerial.config")
local data = require("aerial.data")
local loading = require("aerial.loading")
local render = require("aerial.render")
local util = require("aerial.util")

local api = vim.api

local M = {}

local function create_aerial_buffer(bufnr)
  local aer_bufnr = api.nvim_create_buf(false, true)

  if config.default_bindings then
    for _, binding in ipairs(bindings.keys) do
      local keys, command, _ = unpack(binding)
      if type(keys) == "string" then
        keys = { keys }
      end
      for _, key in ipairs(keys) do
        api.nvim_buf_set_keymap(aer_bufnr, "n", key, command, { silent = true, noremap = true })
      end
    end
  end
  -- Set buffer options
  api.nvim_buf_set_var(bufnr, "aerial_buffer", aer_bufnr)
  api.nvim_buf_set_var(aer_bufnr, "source_buffer", bufnr)
  loading.set_loading(aer_bufnr, not data:has_received_data(bufnr))
  api.nvim_buf_set_option(aer_bufnr, "buftype", "nofile")
  api.nvim_buf_set_option(aer_bufnr, "bufhidden", "wipe")
  api.nvim_buf_set_option(aer_bufnr, "buflisted", false)
  api.nvim_buf_set_option(aer_bufnr, "swapfile", false)
  api.nvim_buf_set_option(aer_bufnr, "modifiable", false)
  render.update_aerial_buffer(bufnr)
  return aer_bufnr
end

local function create_aerial_window(bufnr, aer_bufnr, direction, existing_win)
  -- We used to use < and > to indicate direction.
  if direction == "<" then
    direction = "left"
  end
  if direction == ">" then
    direction = "right"
  end
  if direction ~= "left" and direction ~= "right" and direction ~= "float" then
    error("Expected direction to be 'left', 'right', or 'float'")
    return
  end

  if aer_bufnr == -1 then
    aer_bufnr = create_aerial_buffer(bufnr)
  end

  local my_winid = api.nvim_get_current_win()
  if not existing_win then
    if direction == "float" then
      vim.api.nvim_open_win(aer_bufnr, true, {
        relative = "cursor",
        row = config.float.row,
        col = config.float.col,
        width = util.get_width(aer_bufnr),
        height = util.get_height(aer_bufnr),
        zindex = 125,
        style = "minimal",
        border = config.float.border,
      })
    else
      local winids
      if config.placement_editor_edge then
        winids = util.get_fixed_wins()
      else
        winids = util.get_fixed_wins(bufnr)
      end
      local split_target
      if direction == "left" then
        split_target = winids[1]
      else
        split_target = winids[#winids]
      end
      if my_winid ~= split_target then
        util.go_win_no_au(split_target)
      end
      if direction == "left" then
        vim.cmd("noau vertical leftabove split")
      else
        vim.cmd("noau vertical rightbelow split")
      end
    end
  else
    util.go_win_no_au(existing_win)
  end

  util.go_buf_no_au(aer_bufnr)
  api.nvim_win_set_option(0, "winfixwidth", true)
  api.nvim_win_set_option(0, "number", false)
  api.nvim_win_set_option(0, "signcolumn", "no")
  api.nvim_win_set_option(0, "foldcolumn", "0")
  api.nvim_win_set_option(0, "relativenumber", false)
  api.nvim_win_set_option(0, "wrap", false)
  api.nvim_win_set_var(0, "is_aerial_win", true)
  -- Set the filetype only after we enter the buffer so that FileType autocmds
  -- behave properly
  api.nvim_buf_set_option(aer_bufnr, "filetype", "aerial")
  util.set_win_width(0, util.get_width(aer_bufnr))

  local aer_winid = api.nvim_get_current_win()
  util.go_win_no_au(my_winid)
  return aer_winid
end

M.is_open = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return false
  else
    local winid = util.buf_first_win_in_tabpage(aer_bufnr)
    return winid ~= nil
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    vim.api.nvim_win_close(0, false)
    return
  end
  local aer_bufnr = util.get_aerial_buffer()
  local winid = util.buf_first_win_in_tabpage(aer_bufnr)
  if winid then
    vim.api.nvim_win_close(winid, false)
  end
end

M.maybe_open_automatic = function()
  if not config.open_automatic() then
    return false
  end
  if data[0]:count() < config.open_automatic_min_symbols then
    return false
  end
  if api.nvim_buf_line_count(0) < config.open_automatic_min_lines then
    return false
  end
  M.open(false)
  return true
end

M.open = function(focus, direction, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    winid = nil,
  })
  local backend = backends.get()
  if not backend then
    backends.log_support_err()
    return
  end
  local bufnr, aer_bufnr = util.get_buffers()
  if M.is_open() then
    if focus then
      local winid = util.buf_first_win_in_tabpage(aer_bufnr)
      api.nvim_set_current_win(winid)
    end
    return
  end
  direction = direction or util.detect_split_direction()
  local aer_winid = create_aerial_window(bufnr, aer_bufnr, direction, opts.winid)
  if not data:has_symbols(bufnr) then
    backend.fetch_symbols()
  end
  local my_winid = api.nvim_get_current_win()
  M.update_position(nil, my_winid)
  if focus then
    api.nvim_set_current_win(aer_winid)
  end
  vim.cmd("wincmd =")
end

M.focus = function()
  if not M.is_open() then
    return
  end
  local bufnr = api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  local winid = util.buf_first_win_in_tabpage(aer_bufnr)
  api.nvim_set_current_win(winid)
end

M.toggle = function(focus, direction)
  if util.is_aerial_buffer() then
    vim.api.nvim_win_close(0, false)
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

M.get_position_in_win = function(bufnr, winid)
  local cursor = api.nvim_win_get_cursor(winid or 0)
  local lnum = cursor[1]
  local col = cursor[2]
  local bufdata = data[bufnr]
  local selected = 0
  local relative = "above"
  bufdata:visit(function(item)
    if item.lnum > lnum then
      return true
    elseif item.lnum == lnum then
      if item.col > col then
        return true
      elseif item.col == col then
        selected = selected + 1
        relative = "exact"
        return true
      else
        relative = "below"
      end
    else
      relative = "below"
    end
    selected = selected + 1
  end)
  return {
    lnum = math.max(1, selected),
    relative = relative,
  }
end

M.update_all_positions = function(bufnr, last_focused_win)
  local source_buffer = util.get_buffers(bufnr)
  local all_source_wins = util.get_fixed_wins(source_buffer)
  M.update_position(all_source_wins, last_focused_win)
end

-- winids can be nil, a winid, or a list of winids
M.update_position = function(winids, last_focused_win)
  if not config.highlight_mode or config.highlight_mode == "none" then
    return
  end
  if winids == nil or winids == 0 then
    winids = { api.nvim_get_current_win() }
  elseif type(winids) ~= "table" then
    winids = { winids }
  end
  if #winids == 0 then
    return
  end
  local win_bufnr = api.nvim_win_get_buf(winids[1])
  local bufnr, aer_bufnr = util.get_buffers(win_bufnr)
  if not data:has_symbols(bufnr) then
    return
  end
  if util.is_aerial_buffer(win_bufnr) then
    winids = util.get_fixed_wins(bufnr)
  end

  local bufdata = data[bufnr]
  for _, target_win in ipairs(winids) do
    local pos = M.get_position_in_win(bufnr, target_win)
    if pos ~= nil then
      bufdata.positions[target_win] = pos
      if last_focused_win and (last_focused_win == true or last_focused_win == target_win) then
        bufdata.last_position = pos.lnum
      end
    end
  end

  render.update_highlights(bufnr)
  if last_focused_win then
    local aer_winid = util.buf_first_win_in_tabpage(aer_bufnr)
    if aer_winid then
      local last_position = bufdata.last_position
      local lines = api.nvim_buf_line_count(aer_bufnr)

      -- When aerial window is global, the items can change and cursor will move
      -- before the symbols are published, which causes the line number to be
      -- invalid.
      if lines >= last_position then
        api.nvim_win_set_cursor(aer_winid, { bufdata.last_position, 0 })
      end
    end
  end
end

return M
