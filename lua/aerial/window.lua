local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local loading = require("aerial.loading")
local render = require("aerial.render")
local util = require("aerial.util")

local api = vim.api
local fn = vim.fn

local M = {}

local function create_aerial_buffer(bufnr)
  local aer_bufnr = api.nvim_create_buf(false, true)

  util.go_buf_no_au(aer_bufnr)
  if config.default_bindings then
    local map = function(keys, cmd)
      if type(keys) == "string" then
        keys = { keys }
      end
      for _, key in ipairs(keys) do
        api.nvim_buf_set_keymap(aer_bufnr, "n", key, cmd, { silent = true, noremap = true })
      end
    end
    map("<CR>", "<cmd>lua require'aerial'.select()<CR>")
    map("<C-v>", "<cmd>lua require'aerial'.select({split='v'})<CR>")
    map("<C-s>", "<cmd>lua require'aerial'.select({split='h'})<CR>")
    map("p", "<cmd>lua require'aerial'.select({jump=false})<CR>")
    map("<C-j>", "j<cmd>lua require'aerial'.select({jump=false})<CR>")
    map("<C-k>", "k<cmd>lua require'aerial'.select({jump=false})<CR>")
    map("}", "<cmd>AerialNext<CR>")
    map("{", "<cmd>AerialPrev<CR>")
    map("]]", "<cmd>AerialNextUp<CR>")
    map("[[", "<cmd>AerialPrevUp<CR>")
    map("q", "<cmd>AerialClose<CR>")
    map({ "o", "za" }, "<cmd>AerialTreeToggle<CR>")
    map({ "O", "zA" }, "<cmd>AerialTreeToggle!<CR>")
    map({ "l", "zo" }, "<cmd>AerialTreeOpen<CR>")
    map({ "L", "zO" }, "<cmd>AerialTreeOpen!<CR>")
    map({ "h", "zc" }, "<cmd>AerialTreeClose<CR>")
    map({ "H", "zC" }, "<cmd>AerialTreeClose!<CR>")
    map("zR", "<cmd>AerialTreeOpenAll<CR>")
    map("zM", "<cmd>AerialTreeCloseAll<CR>")
    map({ "zx", "zX" }, "<cmd>AerialTreeSyncFolds<CR>")
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
  api.nvim_buf_set_option(aer_bufnr, "filetype", "aerial")
  render.update_aerial_buffer(bufnr)
  return aer_bufnr
end

local function create_aerial_window(bufnr, aer_bufnr, direction, existing_win)
  if direction == "<" then
    direction = "left"
  end
  if direction == ">" then
    direction = "right"
  end
  if direction ~= "left" and direction ~= "right" then
    error("Expected direction to be 'left' or 'right'")
    return
  end
  local my_winid = api.nvim_get_current_win()
  if not existing_win then
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
  else
    util.go_win_no_au(existing_win)
  end

  if aer_bufnr == -1 then
    aer_bufnr = create_aerial_buffer(bufnr)
  end
  util.go_buf_no_au(aer_bufnr)

  if not existing_win then
    api.nvim_win_set_width(0, util.get_width())
  end
  api.nvim_win_set_option(0, "winfixwidth", true)
  api.nvim_win_set_option(0, "number", false)
  api.nvim_win_set_option(0, "signcolumn", "no")
  api.nvim_win_set_option(0, "foldcolumn", "0")
  api.nvim_win_set_option(0, "relativenumber", false)
  api.nvim_win_set_option(0, "wrap", false)
  api.nvim_win_set_var(0, "is_aerial_win", true)
  local aer_winid = api.nvim_get_current_win()
  util.go_win_no_au(my_winid)
  return aer_winid
end

M.is_open = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return false
  else
    local winid = fn.bufwinid(aer_bufnr)
    return winid ~= -1
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    vim.cmd("close")
    return
  end
  local aer_bufnr = util.get_aerial_buffer()
  local winnr = fn.bufwinnr(aer_bufnr)
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
      local winid = fn.bufwinid(aer_bufnr)
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
  local winid = fn.bufwinid(aer_bufnr)
  api.nvim_set_current_win(winid)
end

M.toggle = function(focus, direction)
  if util.is_aerial_buffer() then
    vim.cmd("close")
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

M.update_all_positions = function(bufnr, update_last)
  local winids = fn.win_findbuf(bufnr)
  M.update_position(winids, update_last)
end

M.update_position = function(winid, update_last)
  if not config.highlight_mode or config.highlight_mode == "none" then
    return
  end
  if winid == 0 then
    winid = api.nvim_get_current_win()
  end
  local win_bufnr = api.nvim_win_get_buf(winid)
  local bufnr, aer_bufnr = util.get_buffers(win_bufnr)
  if not data:has_symbols(bufnr) then
    return
  end
  local winids
  if not winid or util.is_aerial_buffer(win_bufnr) then
    winids = util.get_fixed_wins(bufnr)
  elseif type(winid) == "table" then
    winids = winid
  else
    winids = { winid }
  end

  local bufdata = data[bufnr]
  for _, target_win in ipairs(winids) do
    local pos = M.get_position_in_win(bufnr, target_win)
    if pos ~= nil then
      bufdata.positions[target_win] = pos
      if update_last and (update_last == true or update_last == target_win) then
        bufdata.last_position = pos.lnum
      end
    end
  end

  render.update_highlights(bufnr)
  if update_last then
    local aer_winid = fn.bufwinid(aer_bufnr)

    if aer_winid ~= -1 then
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
