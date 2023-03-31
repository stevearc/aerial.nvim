local M = {}

local function is_float(value)
  local _, p = math.modf(value)
  return p ~= 0
end

local function calc_float(value, max_value)
  if value and is_float(value) then
    return math.min(max_value, value * max_value)
  else
    return value
  end
end

---@return integer
M.get_editor_width = function()
  return vim.o.columns
end

---@return integer
M.get_editor_height = function()
  local editor_height = vim.o.lines - vim.o.cmdheight
  -- Subtract 1 if tabline is visible
  if vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1) then
    editor_height = editor_height - 1
  end
  -- Subtract 1 if statusline is visible
  if
    vim.o.laststatus >= 2 or (vim.o.laststatus == 1 and #vim.api.nvim_tabpage_list_wins(0) > 1)
  then
    editor_height = editor_height - 1
  end
  return editor_height
end

local function calc_list(values, max_value, aggregator, limit)
  local ret = limit
  if type(values) == "table" then
    for _, v in ipairs(values) do
      ret = aggregator(ret, calc_float(v, max_value))
    end
    return ret
  else
    ret = aggregator(ret, calc_float(values, max_value))
  end
  return ret
end

local function calculate_dim(desired_size, size, min_size, max_size, total_size)
  local ret = calc_float(size, total_size)
  local min_val = calc_list(min_size, total_size, math.max, 1)
  local max_val = calc_list(max_size, total_size, math.min, total_size)
  if not ret then
    if not desired_size then
      ret = (min_val + max_val) / 2
    else
      ret = calc_float(desired_size, total_size)
    end
  end
  ret = math.min(ret, max_val)
  ret = math.max(ret, min_val)
  return math.floor(ret)
end

local function get_max_width(relative, winid)
  if relative == "editor" then
    return M.get_editor_width()
  else
    return vim.api.nvim_win_get_width(winid or 0)
  end
end

local function get_max_height(relative, winid)
  if relative == "editor" then
    return M.get_editor_height()
  else
    return vim.api.nvim_win_get_height(winid or 0)
  end
end

M.calculate_col = function(relative, width, winid)
  if relative == "cursor" then
    return 1
  else
    return math.floor((get_max_width(relative, winid) - width) / 2)
  end
end

M.calculate_row = function(relative, height, winid)
  if relative == "cursor" then
    return 1
  else
    return math.floor((get_max_height(relative, winid) - height) / 2)
  end
end

M.calculate_width = function(relative, desired_width, config, winid)
  return calculate_dim(
    desired_width,
    config.width,
    config.min_width,
    config.max_width,
    get_max_width(relative, winid)
  )
end

M.calculate_height = function(relative, desired_height, config, winid)
  return calculate_dim(
    desired_height,
    config.height,
    config.min_height,
    config.max_height,
    get_max_height(relative, winid)
  )
end

return M
