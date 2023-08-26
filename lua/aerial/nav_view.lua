local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local keymap_util = require("aerial.keymap_util")
local layout = require("aerial.layout")
local navigation = require("aerial.navigation")
local util = require("aerial.util")
local window = require("aerial.window")
local M = {}

---@class aerial.NavPanel
---@field winid integer
---@field bufnr integer
---@field width integer
---@field height integer
---@field symbols aerial.Symbol[]

---@class aerial.Nav
---@field left aerial.NavPanel
---@field main aerial.NavPanel
---@field right aerial.NavPanel
---@field bufnr integer
---@field autocmds integer[]
local AerialNav = {}

---@type nil|aerial.Nav
local _active_nav = nil

---@return integer
local function create_buf()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = "aerial-nav"
  return bufnr
end

function AerialNav.new(bufnr, winid)
  local left_buf = create_buf()
  local width = math.floor((layout.get_editor_width() - 6) / 3)
  local left_win = vim.api.nvim_open_win(left_buf, false, {
    relative = "editor",
    row = 1,
    col = 1,
    width = width,
    height = 20,
    border = config.nav.border,
    style = "minimal",
  })
  local main_buf = create_buf()
  local main_win = vim.api.nvim_open_win(main_buf, true, {
    relative = "editor",
    row = 1,
    col = width + 2,
    width = width,
    height = 20,
    -- If you want a rounded border, convert the main window border to 'single' so the center joints
    -- have a cleaner look
    border = config.nav.border == "rounded" and "single" or config.nav.border,
    style = "minimal",
    zindex = 51,
  })
  local right_buf = create_buf()
  local right_win = vim.api.nvim_open_win(right_buf, false, {
    relative = "editor",
    row = 1,
    col = 2 * (width + 2),
    width = width,
    height = 20,
    border = config.nav.border,
    style = "minimal",
  })
  for _, floatwin in ipairs({ left_win, main_win, right_win }) do
    vim.api.nvim_set_option_value(
      "winhighlight",
      "AerialNormal:AerialNormalFloat",
      { scope = "local", win = floatwin }
    )
  end
  local nav = setmetatable({
    winid = winid,
    bufnr = bufnr,
    left = {
      bufnr = left_buf,
      winid = left_win,
      width = 80,
      height = 20,
      symbols = {},
    },
    main = {
      bufnr = main_buf,
      winid = main_win,
      width = 80,
      height = 20,
      symbols = {},
    },
    right = {
      bufnr = right_buf,
      winid = right_win,
      width = 80,
      height = 20,
      symbols = {},
    },
    autocmds = {},
  }, {
    __index = AerialNav,
  })
  keymap_util.set_keymaps("", "aerial.nav_actions", config.nav.keymaps, main_buf, nav)
  vim.api.nvim_create_autocmd("WinLeave", {
    desc = "Close Aerial nav window on leave",
    nested = true,
    once = true,
    callback = function()
      M.close()
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    desc = "Close Aerial nav window on leave",
    nested = true,
    once = true,
    buffer = main_buf,
    callback = function()
      M.close()
    end,
  })
  -- Defer the CursorMoved autocmd so it doesn't fire immediately
  vim.schedule(function()
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "Update symbols on cursor move",
      buffer = main_buf,
      callback = function()
        local symbol = nav:get_current_symbol()
        if symbol then
          if config.nav.autojump then
            navigation.select_symbol(symbol, winid, bufnr, { jump = false })
          end
          nav:focus_symbol(symbol)
        end
      end,
    })
  end)
  table.insert(
    nav.autocmds,
    vim.api.nvim_create_autocmd("VimResized", {
      desc = "Update aerial nav view",
      callback = function()
        nav:relayout()
      end,
    })
  )
  return nav
end

---@return nil|aerial.Symbol
function AerialNav:get_current_symbol()
  local lnum = vim.api.nvim_win_get_cursor(self.main.winid)[1]
  return self.main.symbols[lnum]
end

---@param symbol nil|aerial.Symbol
---@return aerial.Symbol[]
---@return integer
local function get_all_siblings(symbol)
  local ret = {}
  if not symbol then
    return ret, 1
  end
  table.insert(ret, symbol)
  local i = 1
  local iter = symbol
  while assert(iter).prev_sibling do
    iter = iter.prev_sibling
    i = i + 1
    table.insert(ret, 1, iter)
  end
  iter = symbol
  while assert(iter).next_sibling do
    iter = iter.next_sibling
    table.insert(ret, iter)
  end
  return ret, i
end

---@param panel aerial.NavPanel
local function render_symbols(panel)
  local bufnr = panel.bufnr
  local lines = {}
  local highlights = {}
  local max_len = 1
  for i, item in ipairs(panel.symbols) do
    local kind = config.get_icon(bufnr, item.kind)
    local text = util.remove_newlines(string.format("%s %s", kind, item.name))
    table.insert(lines, text)
    local text_cols = vim.api.nvim_strwidth(text)
    table.insert(highlights, { "Aerial" .. item.kind .. "Icon", i - 1, 0, kind:len() })
    table.insert(highlights, { "Aerial" .. item.kind, i - 1, kind:len(), -1 })
    max_len = math.max(max_len, text_cols)
  end

  -- If there are no symbols in this section, add some indicator of that
  if #lines == 0 then
    table.insert(lines, "<none>")
    table.insert(highlights, { "Comment", 0, 0, -1 })
  end

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false

  local ns = vim.api.nvim_create_namespace("aerial")
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(bufnr, ns, unpack(hl))
  end
  panel.width = max_len
  panel.height = #lines
end

---@param panel aerial.NavPanel
function AerialNav:preview_symbol(panel)
  local symbol = self:get_current_symbol()
  if symbol then
    vim.api.nvim_win_set_buf(panel.winid, self.bufnr)
    navigation.select_symbol(symbol, panel.winid, self.bufnr, { jump = false })
  end
end

---@param symbol aerial.Symbol
function AerialNav:focus_symbol(symbol)
  local siblings, lnum = get_all_siblings(symbol)
  self.main.symbols = siblings
  self.left.symbols = get_all_siblings(symbol.parent)
  self.right.symbols = symbol.children or {}

  render_symbols(self.left)
  render_symbols(self.main)
  if config.nav.preview and vim.tbl_isempty(self.right.symbols) then
    self:preview_symbol(self.right)
  else
    vim.api.nvim_win_set_buf(self.right.winid, self.right.bufnr)
    render_symbols(self.right)
  end

  if vim.api.nvim_win_is_valid(self.main.winid) then
    vim.api.nvim_win_set_cursor(self.main.winid, { lnum, 0 })
  end
  self:relayout()
end

function AerialNav:relayout()
  local total_width = layout.get_editor_width()
  local total_height = layout.get_editor_height()
  local main_width = layout.calculate_width("editor", self.main.width, config.nav, 0)
  local desired_height = math.max(self.left.height, math.max(self.main.height, self.right.height))
  local height = layout.calculate_height("editor", desired_height, config.nav, 0)
  local main_col = math.floor((total_width - main_width) / 2)
  local main_row = math.floor((total_height - height) / 2)
  vim.api.nvim_win_set_config(self.main.winid, {
    relative = "editor",
    width = main_width,
    height = height,
    row = main_row,
    col = main_col,
  })

  local border_width = config.nav.border == "none" and 0 or 1
  local width_remaining = math.floor((total_width - main_width) / 2)
  if config.nav.border ~= "none" then
    width_remaining = width_remaining - (2 * border_width)
  end

  local left_width = layout.calculate_width("editor", self.left.width, config.nav, 0)
  if left_width > width_remaining then
    left_width = width_remaining
  end
  vim.api.nvim_win_set_config(self.left.winid, {
    relative = "editor",
    width = left_width,
    height = height,
    row = main_row,
    col = main_col - left_width - border_width,
  })
  local right_width = layout.calculate_width("editor", self.right.width, config.nav, 0)
  if right_width > width_remaining then
    right_width = width_remaining
  end
  vim.api.nvim_win_set_config(self.right.winid, {
    relative = "editor",
    width = right_width,
    height = height,
    row = main_row,
    col = main_col + main_width + border_width,
  })
  for k, v in pairs(config.nav.win_opts) do
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = self.main.winid })
    -- Hack: we generally don't want the left/right to have cursorline enabled
    if k ~= "cursorline" then
      vim.api.nvim_set_option_value(k, v, { scope = "local", win = self.left.winid })
      vim.api.nvim_set_option_value(k, v, { scope = "local", win = self.right.winid })
    end
  end
end

function AerialNav:close()
  for _, winid in ipairs({ self.left.winid, self.main.winid, self.right.winid }) do
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_close(winid, true)
    end
  end
  for _, id in ipairs(self.autocmds) do
    vim.api.nvim_del_autocmd(id)
  end
  for _, bufnr in ipairs({ self.left.bufnr, self.main.bufnr, self.right.bufnr }) do
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end
  self.autocmds = {}
end

---@return boolean
M.is_open = function()
  return _active_nav ~= nil
end

M.open = function()
  if M.is_open() then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local winid = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local backend = backends.get(bufnr)
  if not backend then
    backends.log_support_err()
    return
  end
  if not data.has_symbols(bufnr) then
    backend.fetch_symbols(bufnr)
  end
  _active_nav = AerialNav.new(bufnr, winid)
  local bufdata = data.get(bufnr)
  if bufdata then
    local pos = window.get_symbol_position(bufdata, cursor[1], cursor[2], true)
    if pos.closest_symbol then
      _active_nav:focus_symbol(pos.closest_symbol)
    end
  end
end

M.toggle = function()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

M.close = function()
  if not M.is_open() then
    return
  end
  local nav = _active_nav
  _active_nav = nil
  if nav then
    nav:close()
  end
end

return M
