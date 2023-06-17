local config = require("aerial.config")
local data = require("aerial.data")
local fold = require("aerial.fold")
local render = require("aerial.render")
local util = require("aerial.util")
local window = require("aerial.window")
local M = {}

local function _get_target(bufdata, action, item, bubble)
  if not bubble then
    return item
  end
  while
    item
    and (not bufdata:is_collapsable(item) or (action == "close" and bufdata:is_collapsed(item)))
  do
    item = item.parent
  end
  return item
end

local function _post_tree_mutate(bufnr, new_cursor_pos)
  bufnr = bufnr or 0
  render.update_aerial_buffer(bufnr)
  local mywin = vim.api.nvim_get_current_win()
  window.update_all_positions(bufnr, mywin)
  local _, aer_bufnr = util.get_buffers(bufnr)
  if new_cursor_pos then
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == aer_bufnr then
        vim.api.nvim_win_set_cursor(winid, { new_cursor_pos, 0 })
      end
    end
  end
end

local function edit_tree_node(bufdata, action, index, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    bubble = true,
    recurse = false,
  })
  local did_update = false
  local function do_action(item)
    if not item or not bufdata:is_collapsable(item) then
      return
    end
    local is_collapsed = bufdata:is_collapsed(item)
    if action == "toggle" then
      action = is_collapsed and "open" or "close"
    end
    if action == "open" then
      did_update = did_update or is_collapsed
      bufdata:set_collapsed(item, false)
      if opts.recurse and item.children then
        for _, child in ipairs(item.children) do
          do_action(child)
        end
      end
      return item
    elseif action == "close" then
      did_update = did_update or not is_collapsed
      bufdata:set_collapsed(item, true)
      if opts.recurse and item.parent then
        return do_action(item.parent)
      end
      return item
    else
      error(string.format("Unknown action '%s'", action))
    end
  end
  local current_item = bufdata:item(index)
  local target = _get_target(bufdata, action, current_item, opts.bubble)
  local item = do_action(target)
  return did_update, bufdata:indexof(item)
end

---Perform an action on the symbol tree.
---@param action "open"|"close"|"toggle" can be one of the following:
---    open    Open the tree at the selected location
---    close   Collapse the tree at the selected location
---    toggle  Toggle the collapsed state at the selected location
---@param opts nil|table
---    index   nil|integer The index of the symbol to perform the action on. Defaults to cursor location.
---    fold    nil|boolean If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)
---    recurse nil|boolean If true, perform the action recursively on all children (default false)
---    bubble  nil|boolean If true and current symbol has no children, perform the action on the nearest parent (default true)
local function tree_cmd(action, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    index = nil,
    fold = true,
  })
  local index
  local item
  if opts.index then
    index = opts.index
  elseif util.is_aerial_buffer() then
    index = vim.api.nvim_win_get_cursor(0)[1]
  else
    local pos = window.get_position_in_win()
    index = pos.lnum
    item = pos.exact_symbol
  end
  if item == nil then
    item = data.get_or_create(0):item(index)
  end
  if not item then
    return
  end
  local lnum = item.lnum
  local did_update, new_cursor_pos = edit_tree_node(data.get_or_create(0), action, index, opts)
  if did_update then
    if config.link_tree_to_folds and opts.fold then
      fold.fold_action(action, lnum, {
        recurse = opts.recurse,
      })
    end
    _post_tree_mutate(0, new_cursor_pos)
  end
end

M.open = function(opts)
  tree_cmd("open", opts)
end

M.close = function(opts)
  tree_cmd("close", opts)
end

M.toggle = function(opts)
  tree_cmd("toggle", opts)
end

---Set the collapse level of the symbol tree
---@param bufnr nil|integer
---@param level integer 0 is all closed, use 99 to open all
M.set_collapse_level = function(bufnr, level)
  bufnr = util.get_buffers(bufnr or 0)
  if not bufnr or not data.has_symbols(bufnr) then
    return
  end
  local bufdata = data.get_or_create(bufnr)
  level = bufdata:set_fold_level(level)
  if config.link_tree_to_folds then
    local wins
    if config.attach_mode == "global" then
      wins = vim.tbl_filter(function(winid)
        return vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr
      end, vim.api.nvim_list_wins())
    else
      local source_win = util.get_winids(0)
      if source_win and vim.api.nvim_win_get_buf(source_win) == bufnr then
        wins = { source_win }
      else
        wins = util.get_fixed_wins(bufnr)
        -- Hacky way to only use the first window found
        wins[2] = nil
      end
    end

    for _, winid in ipairs(wins) do
      vim.api.nvim_set_option_value("foldlevel", level, { scope = "local", win = winid })
    end
  end
  _post_tree_mutate(bufnr)
end

M.increase_fold_level = function(bufnr, count)
  count = math.max(1, count or 1)
  bufnr = util.get_buffers(bufnr or 0)
  if not data.has_symbols(bufnr) then
    return
  end
  local bufdata = data.get_or_create(bufnr)
  M.set_collapse_level(bufnr, bufdata.collapse_level + count)
end

M.decrease_fold_level = function(bufnr, count)
  count = math.max(1, count or 1)
  bufnr = util.get_buffers(bufnr or 0)
  if not data.has_symbols(bufnr) then
    return
  end
  local bufdata = data.get_or_create(bufnr)
  -- If the current level is 99, start the decrement from the max level instead
  local max_level = bufdata.max_level
  -- When folding is enabled, leaves can be folded so add 1
  if config.manage_folds(bufnr) and config.link_tree_to_folds then
    max_level = max_level + 1
  end
  local start = math.min(bufdata.collapse_level, max_level)
  M.set_collapse_level(bufnr, start - count)
end

M.open_all = function(bufnr)
  bufnr = util.get_buffers(bufnr or 0)
  if not data.has_symbols(bufnr) then
    return
  end
  data.get_or_create(bufnr):clear_collapsed()
  M.set_collapse_level(bufnr, 99)
end

---Collapse all nodes in the symbol tree
---@param bufnr nil|integer
M.close_all = function(bufnr)
  bufnr = util.get_buffers(bufnr or 0)
  if not data.has_symbols(bufnr) then
    return
  end
  data.get_or_create(bufnr):clear_collapsed()
  M.set_collapse_level(bufnr, 0)
end

return M
