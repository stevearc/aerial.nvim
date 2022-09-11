local backends = require("aerial.backends")
local bindings = require("aerial.bindings")
local config = require("aerial.config")
local data = require("aerial.data")
local layout = require("aerial.layout")
local loading = require("aerial.loading")
local render = require("aerial.render")
local util = require("aerial.util")

local M = {}

local function create_aerial_buffer(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local aer_bufnr = vim.api.nvim_create_buf(false, true)

  if config.default_bindings then
    for _, binding in ipairs(bindings.keys) do
      local keys, command, _ = unpack(binding)
      if type(keys) == "string" then
        keys = { keys }
      end
      for _, key in ipairs(keys) do
        vim.api.nvim_buf_set_keymap(aer_bufnr, "n", key, command, { silent = true, noremap = true })
      end
    end
  end
  vim.api.nvim_buf_set_var(bufnr, "aerial_buffer", aer_bufnr)
  -- Set buffer options
  vim.api.nvim_buf_set_var(aer_bufnr, "source_buffer", bufnr)
  vim.api.nvim_buf_set_option(aer_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(aer_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(aer_bufnr, "buflisted", false)
  vim.api.nvim_buf_set_option(aer_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(aer_bufnr, "modifiable", false)
  -- Set the filetype only after we enter the buffer so that ftplugins behave properly
  vim.api.nvim_buf_call(aer_bufnr, function()
    vim.api.nvim_buf_set_option(aer_bufnr, "filetype", "aerial")
  end)
  -- We create an autocmd to render the first time this buffer is displayed in a window
  vim.cmd(string.format(
    [[
    au CursorMoved <buffer=%d> lua require('aerial.autocommands').on_cursor_move(true)
    au BufLeave <buffer=%d> lua require('aerial.autocommands').on_leave_aerial_buf()
    au BufWinEnter <buffer=%d> ++nested ++once lua require('aerial.render').update_aerial_buffer(%d)
  ]],
    aer_bufnr,
    aer_bufnr,
    aer_bufnr,
    aer_bufnr
  ))
  if not data:has_symbols(bufnr) then
    loading.set_loading(aer_bufnr, true)
  end
  return aer_bufnr
end

---@param src_winid integer
---@param aer_winid integer
local function setup_aerial_win(src_winid, aer_winid, aer_bufnr)
  if src_winid == 0 then
    src_winid = vim.api.nvim_get_current_win()
  end
  if aer_winid == 0 then
    aer_winid = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_win_set_option(aer_winid, "listchars", "tab:> ")
  vim.api.nvim_win_set_option(aer_winid, "winfixwidth", true)
  vim.api.nvim_win_set_option(aer_winid, "number", false)
  vim.api.nvim_win_set_option(aer_winid, "signcolumn", "no")
  vim.api.nvim_win_set_option(aer_winid, "foldcolumn", "0")
  vim.api.nvim_win_set_option(aer_winid, "relativenumber", false)
  vim.api.nvim_win_set_option(aer_winid, "wrap", false)
  vim.api.nvim_win_set_option(aer_winid, "spell", false)
  vim.api.nvim_win_set_var(aer_winid, "is_aerial_win", true)

  vim.api.nvim_win_set_var(aer_winid, "source_win", src_winid)
  vim.api.nvim_win_set_var(src_winid, "aerial_win", aer_winid)
  util.restore_width(aer_winid, aer_bufnr)
end

local function create_aerial_window(bufnr, aer_bufnr, direction, existing_win)
  if direction ~= "left" and direction ~= "right" and direction ~= "float" then
    error("Expected direction to be 'left', 'right', or 'float'")
    return
  end

  if aer_bufnr == -1 then
    aer_bufnr = create_aerial_buffer(bufnr)
  end

  local my_winid = vim.api.nvim_get_current_win()
  local aer_winid
  if not existing_win then
    if direction == "float" then
      local rel = config.float.relative
      local width = layout.calculate_width(rel, nil, config.layout)
      local height = layout.calculate_height(rel, nil, config.float)
      local row = layout.calculate_row(rel, height)
      local col = layout.calculate_col(rel, width)
      local win_config = {
        relative = rel,
        row = row,
        col = col,
        width = width,
        height = height,
        zindex = 125,
        style = "minimal",
        border = config.float.border,
      }
      if rel == "win" then
        win_config.win = vim.api.nvim_get_current_win()
      end
      local new_config = config.float.override(win_config) or win_config
      aer_winid = vim.api.nvim_open_win(aer_bufnr, false, new_config)
      -- We store this as a window variable because relative=cursor gets
      -- turned into relative=win when checking nvim_win_get_config()
      vim.api.nvim_win_set_var(aer_winid, "relative", new_config.relative)
    else
      local modifier
      if config.layout.placement == "edge" then
        modifier = direction == "left" and "topleft" or "botright"
      elseif config.layout.placement == "group" then
        local split_target
        local winids = util.get_fixed_wins(bufnr)
        if direction == "left" then
          split_target = winids[1]
        else
          split_target = winids[#winids]
        end
        if my_winid ~= split_target then
          util.go_win_no_au(split_target)
        end
        modifier = direction == "left" and "leftabove" or "rightbelow"
      else
        modifier = direction == "left" and "leftabove" or "rightbelow"
      end
      vim.cmd(string.format("noau vertical %s split", modifier))
      aer_winid = vim.api.nvim_get_current_win()
      util.go_win_no_au(my_winid)
    end
  else
    aer_winid = existing_win
  end

  setup_aerial_win(my_winid, aer_winid, aer_bufnr)
  vim.api.nvim_win_set_buf(aer_winid, aer_bufnr)

  return aer_winid
end

---@param src_bufnr integer source buffer
---@param src_winid integer window containing source buffer
---@param aer_winid integer aerial window
M.open_aerial_in_win = function(src_bufnr, src_winid, aer_winid)
  local aer_bufnr = util.get_aerial_buffer(src_bufnr)
  if aer_bufnr == -1 then
    aer_bufnr = create_aerial_buffer(src_bufnr)
  end
  setup_aerial_win(src_winid, aer_winid, aer_bufnr)
  vim.api.nvim_win_set_buf(aer_winid, aer_bufnr)
  local backend = backends.get(src_bufnr)
  if backend and not data:has_symbols(src_bufnr) then
    backend.fetch_symbols(src_bufnr)
  end
end

---@param bufnr? integer
---@return integer|nil
local function get_aerial_win_for_buf(bufnr)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr ~= -1 then
    return util.buf_first_win_in_tabpage(aer_bufnr)
  end
end

---@param opts? {bufnr?: integer, winid?: integer}
---@return boolean
M.is_open = function(opts)
  if not opts then
    opts = { winid = 0 }
  end
  if opts.winid then
    return util.get_aerial_win(opts.bufnr) ~= nil
  else
    return get_aerial_win_for_buf(opts.bufnr) ~= nil
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    vim.api.nvim_win_close(0, false)
    return
  end
  local aer_win = util.get_aerial_win()
  if aer_win then
    vim.api.nvim_win_close(aer_win, false)
  else
    -- No aerial buffer for this buffer.
    local backend = backends.get(0)
    -- If this buffer has no supported symbols backend or no symbols,
    -- look for other aerial windows and close the first
    if backend == nil or not data:has_symbols(0) then
      for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local winbuf = vim.api.nvim_win_get_buf(winid)
        if util.is_aerial_buffer(winbuf) then
          vim.api.nvim_win_close(winid, false)
          break
        end
      end
    end
  end
end

M.close_all = function()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if util.is_aerial_buffer(vim.api.nvim_win_get_buf(winid)) then
      vim.api.nvim_win_close(winid, false)
    end
  end
end

M.close_all_but_current = function()
  local _, aer_winid = util.get_winids(0)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if winid ~= aer_winid and util.is_aerial_buffer(bufnr) then
      vim.api.nvim_win_close(winid, false)
    end
  end
end

---@param bufnr? integer
---@return boolean
M.maybe_open_automatic = function(bufnr)
  if config.open_automatic(bufnr or 0) then
    M.open(false)
    return true
  else
    return false
  end
end

M.open = function(focus, direction, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    winid = nil,
  })
  if util.is_aerial_buffer(0) then
    return
  end
  local backend = backends.get(0)
  if not backend then
    backends.log_support_err()
    return
  end
  local bufnr, aer_bufnr = util.get_buffers()
  local aerial_win = util.get_aerial_win()
  if aerial_win and aer_bufnr == vim.api.nvim_win_get_buf(aerial_win) then
    if focus then
      vim.api.nvim_set_current_win(aerial_win)
    end
    return
  end
  direction = direction or util.detect_split_direction()
  local aer_winid = create_aerial_window(bufnr, aer_bufnr, direction, opts.winid or aerial_win)
  if not data:has_symbols(bufnr) then
    backend.fetch_symbols(bufnr)
  end
  local my_winid = vim.api.nvim_get_current_win()
  M.update_position(nil, my_winid)
  if focus then
    vim.api.nvim_set_current_win(aer_winid)
  end
end

M.open_all = function()
  if config.attach_mode == "global" then
    return M.open()
  end
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not util.is_ignored_win(winid) and not util.is_floating_win(winid) then
      vim.api.nvim_win_call(winid, function()
        M.open()
      end)
    end
  end
end

M.focus = function()
  local aerial_win = util.get_aerial_win()
  if aerial_win then
    vim.api.nvim_set_current_win(aerial_win)
  end
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

---@param bufnr? integer
---@param winid? integer
---@return aerial.CursorPosition
M.get_position_in_win = function(bufnr, winid)
  local cursor = vim.api.nvim_win_get_cursor(winid or 0)
  local lnum = cursor[1]
  local col = cursor[2]
  local bufdata = data:get_or_create(bufnr)
  return M.get_symbol_position(bufdata, lnum, col)
end

---Returns -1 if item is before position, 0 if equal, 1 if after
---@param range aerial.Range
---@param lnum integer
---@param col integer
---@return integer
---@return boolean True when position is fully inside the range
local function compare(range, lnum, col)
  if range.lnum > lnum then
    return 1, false
  elseif range.lnum == lnum then
    if range.col > col then
      return 1, false
    elseif range.col == col then
      return 0, true
    else
      return -1, range.end_lnum > lnum or (range.end_lnum == lnum and range.end_col >= col)
    end
  else
    return -1, range.end_lnum > lnum or (range.end_lnum == lnum and range.end_col >= col)
  end
end

---@class aerial.CursorPosition
---@field lnum integer
---@field closest_symbol aerial.Symbol
---@field exact_symbol aerial.Symbol|nil
---@field relative "exact"|"below"|"above"

---@param bufdata aerial.BufData
---@param lnum integer
---@param col integer
---@return aerial.CursorPosition
M.get_symbol_position = function(bufdata, lnum, col)
  local selected = 0
  local relative = "above"
  local prev = nil
  local exact_symbol
  local symbol = bufdata:visit(function(item)
    local cmp, inside = compare(item, lnum, col)
    if inside then
      exact_symbol = item
      if item.selection_range then
        cmp = compare(item.selection_range, lnum, col)
      end
    end
    if cmp < 0 then
      relative = "below"
    elseif cmp == 0 then
      selected = selected + 1
      relative = "exact"
      return item
    else
      return prev or item
    end
    prev = item
    selected = selected + 1
  end)
  -- Check if we're on the last symbol
  if symbol == nil then
    symbol = prev
  end
  return {
    lnum = math.max(1, selected),
    closest_symbol = symbol,
    exact_symbol = exact_symbol,
    relative = relative,
  }
end

-- Updates all cursor positions for a given source buffer
M.update_all_positions = function(bufnr, last_focused_win)
  local source_buffer = util.get_buffers(bufnr)
  local all_source_wins = util.get_non_ignored_fixed_wins(source_buffer)
  M.update_position(all_source_wins, last_focused_win)
end

-- Update the cursor position for one or more windows
-- winids can be nil, a winid, or a list of winids
M.update_position = function(winids, last_focused_win)
  if not config.highlight_mode or config.highlight_mode == "none" then
    return
  end
  if winids == nil or winids == 0 then
    winids = { vim.api.nvim_get_current_win() }
  elseif type(winids) ~= "table" then
    winids = { winids }
  end
  if #winids == 0 then
    return
  end
  local win_bufnr = vim.api.nvim_win_get_buf(winids[1])
  local bufnr, aer_bufnr = util.get_buffers(win_bufnr)
  if not data:has_symbols(bufnr) then
    return
  end
  if util.is_aerial_buffer(win_bufnr) then
    winids = util.get_non_ignored_fixed_wins(bufnr)
  end

  local bufdata = data[bufnr]
  for _, target_win in ipairs(winids) do
    local pos = M.get_position_in_win(bufnr, target_win)
    if pos ~= nil then
      bufdata.positions[target_win] = pos
      if last_focused_win and (last_focused_win == true or last_focused_win == target_win) then
        bufdata.last_win = target_win
      end
    end
  end

  render.update_highlights(bufnr)
  if last_focused_win then
    local aer_winid = util.buf_first_win_in_tabpage(aer_bufnr)
    if aer_winid then
      local last_position = bufdata.positions[bufdata.last_win]
      local lines = vim.api.nvim_buf_line_count(aer_bufnr)

      -- When aerial window is global, the items can change and cursor will move
      -- before the symbols are published, which causes the line number to be
      -- invalid.
      if last_position and lines >= last_position.lnum then
        vim.api.nvim_win_set_cursor(aer_winid, { last_position.lnum, 0 })
      end
    end
  end
end

return M
