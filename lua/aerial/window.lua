local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local keymap_util = require("aerial.keymap_util")
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

  keymap_util.set_keymaps("", "aerial.actions", config.keymaps, aer_bufnr)
  vim.api.nvim_buf_set_var(bufnr, "aerial_buffer", aer_bufnr)
  -- Set buffer options
  vim.api.nvim_buf_set_var(aer_bufnr, "source_buffer", bufnr)
  vim.bo[aer_bufnr].buftype = "nofile"
  vim.bo[aer_bufnr].bufhidden = "wipe"
  vim.bo[aer_bufnr].buflisted = false
  vim.bo[aer_bufnr].swapfile = false
  vim.bo[aer_bufnr].modifiable = false

  if config.highlight_on_hover or config.autojump then
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "Aerial update highlights in the source buffer",
      buffer = aer_bufnr,
      callback = function()
        if config.highlight_on_hover then
          render.update_highlights(bufnr)
        end
        if config.autojump and vim.b[aer_bufnr].rendered then
          require("aerial.navigation").select({ jump = false, quiet = true })
        end
      end,
    })
  end
  if config.highlight_on_hover then
    vim.api.nvim_create_autocmd("BufLeave", {
      desc = "Aerial clear highlights in the source buffer",
      buffer = aer_bufnr,
      callback = function(params)
        render.clear_highlights(bufnr)
      end,
    })
  end
  vim.api.nvim_create_autocmd("BufWinEnter", {
    desc = "Aerial render symbols after buffer loads in window",
    buffer = aer_bufnr,
    once = true,
    callback = function(params)
      -- Defer it so we have time to set window options and variables on the float first
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        render.update_aerial_buffer(aer_bufnr)
        M.update_all_positions(bufnr, 0)
        M.center_symbol_in_view(bufnr)
      end, 1)
    end,
  })

  if not data.has_symbols(bufnr) then
    loading.set_loading(aer_bufnr, true)
    -- Give the backends 50ms to figure out if any of them are supported. If none are supported
    -- after that timeout, assume that they won't be and reset the loading status.
    vim.defer_fn(function()
      local backend = backends.get(bufnr)
      if not backend and loading.is_loading(aer_bufnr) then
        loading.set_loading(aer_bufnr, false)
        render.update_aerial_buffer(aer_bufnr)
      end
    end, 50)
  end
  return aer_bufnr
end

local default_win_opts = {
  list = false,
  winfixwidth = true,
  number = false,
  signcolumn = "no",
  foldcolumn = "0",
  relativenumber = false,
  wrap = false,
  spell = false,
}

---@param src_winid integer
---@param aer_winid integer
local function setup_aerial_win(src_winid, aer_winid, aer_bufnr)
  vim.api.nvim_win_set_buf(aer_winid, aer_bufnr)
  for k, v in pairs(default_win_opts) do
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = aer_winid })
  end
  for k, v in pairs(config.layout.win_opts) do
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = aer_winid })
  end
  vim.api.nvim_win_set_var(aer_winid, "is_aerial_win", true)

  vim.api.nvim_win_set_var(aer_winid, "source_win", src_winid)
  vim.api.nvim_win_set_var(src_winid, "aerial_win", aer_winid)
  -- Set the filetype only after we enter the buffer so that ftplugins behave properly
  vim.bo[aer_bufnr].filetype = "aerial"
  local width = vim.b[aer_bufnr].aerial_width
  if width and (not vim.w[aer_winid].aerial_set_width or config.layout.resize_to_content) then
    vim.api.nvim_win_set_width(aer_winid, width)
    vim.w[aer_winid].aerial_set_width = true
  end
  if config.layout.preserve_equality then
    vim.cmd.wincmd({ args = { "=" } })
  end
end

---@param bufnr nil|integer
---@param aer_bufnr nil|integer
---@param direction "left"|"right"|"float"
---@param existing_win nil|integer
---@return integer
local function create_aerial_window(bufnr, aer_bufnr, direction, existing_win)
  if direction ~= "left" and direction ~= "right" and direction ~= "float" then
    error("Expected direction to be 'left', 'right', or 'float'")
  end

  if not aer_bufnr then
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
      local new_config = config.float.override(win_config, my_winid) or win_config
      aer_winid = vim.api.nvim_open_win(aer_bufnr, false, new_config)
      -- We store this as a window variable because relative=cursor gets
      -- turned into relative=win when checking nvim_win_get_config()
      vim.api.nvim_win_set_var(aer_winid, "relative", new_config.relative)
      local win_enter_au
      win_enter_au = vim.api.nvim_create_autocmd("WinEnter", {
        desc = "After entering aerial win, add hook to close it when leaving",
        callback = function()
          if vim.api.nvim_get_current_win() == aer_winid then
            vim.api.nvim_create_autocmd("WinLeave", {
              desc = "Close aerial floating win when leaving",
              callback = function()
                pcall(vim.api.nvim_win_close, aer_winid, true)
              end,
              once = true,
              nested = true,
            })
            vim.api.nvim_del_autocmd(win_enter_au)
          elseif not vim.api.nvim_win_is_valid(aer_winid) then
            vim.api.nvim_del_autocmd(win_enter_au)
          end
        end,
      })
    else
      local modifier
      if config.layout.placement == "edge" then
        modifier = direction == "left" and "topleft" or "botright"
      else
        modifier = direction == "left" and "leftabove" or "rightbelow"
      end
      vim.cmd(string.format("noau vertical %s 1split", modifier))
      aer_winid = vim.api.nvim_get_current_win()
    end
  else
    aer_winid = existing_win
  end

  util.go_win_no_au(aer_winid)
  setup_aerial_win(my_winid, aer_winid, aer_bufnr)
  util.go_win_no_au(my_winid)

  return aer_winid
end

---@param src_bufnr integer source buffer
---@param src_winid integer window containing source buffer
---@param aer_winid integer aerial window
M.open_aerial_in_win = function(src_bufnr, src_winid, aer_winid)
  if src_winid == 0 then
    src_winid = vim.api.nvim_get_current_win()
  end
  if aer_winid == 0 then
    aer_winid = vim.api.nvim_get_current_win()
  end
  local aer_bufnr = util.get_aerial_buffer(src_bufnr)
  -- If aerial is already open in the window, early return
  if aer_bufnr == vim.api.nvim_win_get_buf(aer_winid) then
    -- Always update the source/aerial win pointers because attach_mode = "global" requires that
    -- they be up to date. We may be calling open_aerial_in_win for same buffer but in a new win.
    vim.api.nvim_win_set_var(aer_winid, "source_win", src_winid)
    vim.api.nvim_win_set_var(src_winid, "aerial_win", aer_winid)
    return
  end
  if not aer_bufnr then
    aer_bufnr = create_aerial_buffer(src_bufnr)
  end
  local my_winid = vim.api.nvim_get_current_win()
  util.go_win_no_au(aer_winid)
  setup_aerial_win(src_winid, aer_winid, aer_bufnr)
  util.go_win_no_au(my_winid)
  local backend = backends.get(src_bufnr)
  if backend and not data.has_symbols(src_bufnr) then
    backend.fetch_symbols(src_bufnr)
  end
end

---@param opts? {bufnr?: integer, winid?: integer}
---@return boolean
M.is_open = function(opts)
  if not opts then
    opts = { winid = 0 }
  end
  if opts.winid then
    return util.get_aerial_win(opts.winid) ~= nil
  else
    local aer_bufnr = util.get_aerial_buffer(opts.bufnr)
    if aer_bufnr then
      return util.buf_first_win_in_tabpage(aer_bufnr) ~= nil
    end
    return false
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    local source_win = util.get_source_win(0)
    vim.api.nvim_win_close(0, false)
    if source_win then
      vim.api.nvim_set_current_win(source_win)
    end
  else
    local aer_win = util.get_aerial_win()
    if aer_win then
      vim.api.nvim_win_close(aer_win, false)
    else
      -- No aerial buffer for this buffer.
      local backend = backends.get(0)
      -- If this buffer has no supported symbols backend, or no symbols, or is ignored,
      -- look for other aerial windows and close the first
      if backend == nil or not data.has_symbols(0) or util.is_ignored_win() then
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(winid) then
            local winbuf = vim.api.nvim_win_get_buf(winid)
            if util.is_aerial_buffer(winbuf) then
              vim.api.nvim_win_close(winid, false)
              break
            end
          end
        end
      end
    end
  end
  if config.layout.preserve_equality then
    vim.cmd.wincmd({ args = { "=" } })
  end
end

M.close_all = function()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if
      vim.api.nvim_win_is_valid(winid) and util.is_aerial_buffer(vim.api.nvim_win_get_buf(winid))
    then
      vim.api.nvim_win_close(winid, false)
    end
  end
end

M.close_all_but_current = function()
  local _, aer_winid = util.get_winids(0)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(winid) then
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if winid ~= aer_winid and util.is_aerial_buffer(bufnr) then
        vim.api.nvim_win_close(winid, false)
      end
    end
  end
end

---@param bufnr? integer
---@return boolean
M.maybe_open_automatic = function(bufnr)
  bufnr = bufnr or 0
  if config.open_automatic(bufnr) and backends.get(bufnr) then
    M.open(false)
    return true
  else
    return false
  end
end

---@param focus? boolean
---@param direction? "left"|"right"|"float"
M.open = function(focus, direction)
  if util.is_aerial_buffer(0) then
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
  local aer_winid = create_aerial_window(bufnr, aer_bufnr, direction, aerial_win)
  local backend = backends.get(0)
  if backend and not data.has_symbols(bufnr) then
    backend.fetch_symbols(bufnr)
  end
  if focus then
    vim.api.nvim_set_current_win(aer_winid)
  end
end

M.open_all = function()
  if config.attach_mode == "global" then
    return M.open()
  end
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if
      vim.api.nvim_win_is_valid(winid)
      and not util.is_ignored_win(winid)
      and not util.is_floating_win(winid)
    then
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
  if util.is_aerial_buffer() or M.is_open() then
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
  local bufdata = data.get_or_create(bufnr)
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
---@param include_hidden nil|boolean
---@return aerial.CursorPosition
M.get_symbol_position = function(bufdata, lnum, col, include_hidden)
  local selected = 0
  local relative = "above"
  local prev = nil
  local exact_symbol

  local symbol
  for _, item in bufdata:iter({ skip_hidden = not include_hidden }) do
    ---@diagnostic disable-next-line: param-type-mismatch
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
      symbol = item
      break
    else
      symbol = prev or item
      break
    end
    prev = item
    selected = selected + 1
  end
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
---@param winids nil|integer|integer[]
---@param last_focused_win nil|integer
M.update_position = function(winids, last_focused_win)
  if winids == nil or winids == 0 then
    winids = { vim.api.nvim_get_current_win() }
  elseif type(winids) ~= "table" then
    winids = { winids }
  end
  if #winids == 0 then
    return
  end
  if last_focused_win == 0 then
    last_focused_win = vim.api.nvim_get_current_win()
  end
  -- If the last_focused_win is actually an aerial window, instead use the source window for that
  -- aerial win (if any)
  if last_focused_win and util.is_aerial_win(last_focused_win) then
    last_focused_win = util.get_source_win(last_focused_win)
  end
  local win_bufnr = vim.api.nvim_win_get_buf(winids[1])
  local bufnr = util.get_buffers(win_bufnr)
  if not bufnr or not data.has_symbols(bufnr) then
    return
  end
  if util.is_aerial_buffer(win_bufnr) then
    winids = util.get_non_ignored_fixed_wins(bufnr)
  end

  local bufdata = data.get_or_create(bufnr)
  for _, target_win in ipairs(winids) do
    local pos = M.get_position_in_win(bufnr, target_win)
    if pos ~= nil then
      bufdata.positions[target_win] = pos
      if last_focused_win == target_win then
        bufdata.last_win = target_win
      end
    end
  end

  render.update_highlights(bufnr)
  if last_focused_win then
    local aer_winid = util.get_aerial_win(last_focused_win)
    if aer_winid then
      local last_position = bufdata.positions[bufdata.last_win]
      local aer_bufnr = vim.api.nvim_win_get_buf(aer_winid)
      local num_lines = vim.api.nvim_buf_line_count(aer_bufnr)

      -- When aerial window is global, the items can change and cursor will move
      -- before the symbols are published, which causes the line number to be
      -- invalid.
      if last_position and num_lines >= last_position.lnum then
        vim.api.nvim_win_set_cursor(aer_winid, { last_position.lnum, 0 })
      end
    end
  end
end

---@param buffer nil|integer
M.center_symbol_in_view = function(buffer)
  local bufnr, aer_bufnr = util.get_buffers(buffer)
  if not bufnr or not data.has_symbols(bufnr) or not aer_bufnr then
    return
  end
  local bufdata = data.get_or_create(bufnr)
  if not bufdata.last_win then
    return
  end
  if vim.api.nvim_buf_is_valid(aer_bufnr) and vim.api.nvim_win_is_valid(bufdata.last_win) then
    local last_position = bufdata.positions[bufdata.last_win]
    if last_position then
      local lnum = last_position.lnum
      local height = vim.api.nvim_win_get_height(bufdata.last_win)
      local max_topline = vim.api.nvim_buf_line_count(aer_bufnr) - height
      local topline = math.max(1, math.min(max_topline, lnum - math.floor(height / 2)))
      local aerial_win = util.buf_first_win_in_tabpage(aer_bufnr)
      if aerial_win then
        vim.api.nvim_win_call(aerial_win, function()
          vim.fn.winrestview({ lnum = lnum, topline = topline })
        end)
      end
    end
  end
end

return M
