local config = require("aerial.config")
local util = require("aerial.util")

---@alias aerial.Scope "private"|"public"|"protected"

---@class aerial.Range
---@field lnum integer
---@field end_lnum integer
---@field col integer
---@field end_col integer

---@class aerial.Symbol : aerial.SymbolBase
---@field level integer
---@field end_lnum integer
---@field end_col integer
---@field parent? aerial.Symbol
---@field selection_range? aerial.Range
---@field children? aerial.Symbol[]
---@field prev_sibling? aerial.Symbol
---@field next_sibling? aerial.Symbol
---@field id? string
---@field idx? integer

---@class aerial.BufData
---@field bufnr integer
---@field items aerial.Symbol[]
---@field flat_items aerial.Symbol[]
---@field positions any
---@field last_win nil|integer
---@field collapsed table<string, boolean>
---@field collapse_level integer
---@field max_level integer
---@field manage_folds boolean
local BufData = {}

---@param bufnr integer
function BufData.new(bufnr)
  local new = {
    bufnr = bufnr,
    items = {},
    flat_items = {},
    positions = {},
    last_win = nil,
    collapsed = {},
    collapse_level = 99,
  }
  -- cache the evaluation of managing folds
  new.manage_folds = config.manage_folds(bufnr) and config.link_tree_to_folds
  setmetatable(new, { __index = BufData })
  return new
end

---@param idx integer
---@return aerial.Symbol|nil
function BufData:item(idx)
  for _, item, i in self:iter({ skip_hidden = true }) do
    if i == idx then
      return item
    end
  end
end

---@param target? aerial.Symbol
---@return integer|nil
function BufData:indexof(target)
  if target == nil then
    return nil
  end
  for _, item, i in self:iter({ skip_hidden = true }) do
    if item == target then
      return i
    end
  end
end

function BufData:clear_collapsed()
  self.collapsed = {}
end

---@param item aerial.Symbol
---@return boolean
function BufData:is_collapsed(item)
  return item and self.collapsed[item.id]
end

---@param item aerial.Symbol
---@param collapsed boolean
function BufData:set_collapsed(item, collapsed)
  self.collapsed[item.id] = collapsed
end

---@param item aerial.Symbol
---@return boolean?
function BufData:is_collapsable(item)
  return self.manage_folds or (item.children and not vim.tbl_isempty(item.children))
end

---@param level integer
function BufData:set_fold_level(level)
  level = math.min(99, math.max(0, level))
  self.collapse_level = level
  for _, item in ipairs(self.flat_items) do
    if self:is_collapsable(item) then
      self:set_collapsed(item, level <= item.level)
    end
  end
  return level
end

---@param item aerial.Symbol
---@return nil|aerial.Symbol
local function _next_non_collapsed(item)
  while item do
    if item.next_sibling then
      return item.next_sibling
    end
    item = item.parent
  end
end

---@param opts? {skip_hidden?: boolean}
function BufData:iter(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    skip_hidden = true,
  })
  local j = 0
  ---@return nil|integer
  ---@return nil|aerial.Symbol
  ---@return nil|integer
  return function(_, i, a, b)
    i = i + 1
    j = j + 1
    ---@type nil|aerial.Symbol
    local item = self.flat_items[i]
    if opts.skip_hidden and item and self:is_collapsed(item.parent) then
      item = _next_non_collapsed(item.parent)
    end
    if item then
      return item.idx, item, j
    else
      return nil, nil, nil
    end
  end,
    nil,
    0
end

---@param callback fun(item: aerial.Symbol)
function BufData:visit(callback)
  local function visit_item(item)
    callback(item)
    if item.children then
      for _, child in ipairs(item.children) do
        visit_item(child)
      end
    end
  end
  for _, item in ipairs(self.items) do
    visit_item(item)
  end
end

---@param opts nil|{skip_hidden: nil|boolean}
---@return integer
function BufData:count(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    skip_hidden = true,
  })
  if not opts.skip_hidden then
    return #self.flat_items
  end
  local count = 0
  for _, _, i in self:iter(opts) do
    count = i
  end
  return count
end

local buf_to_symbols = {}

local M = {}

---@param buf nil|integer
---@return nil|aerial.BufData
function M.get(buf)
  buf = buf or 0
  local bufnr, _ = util.get_buffers(buf)
  return buf_to_symbols[bufnr]
end

---@param buf nil|integer
---@return aerial.BufData
function M.get_or_create(buf)
  buf = buf or 0
  local bufnr, _ = util.get_buffers(buf)
  if not bufnr then
    error("Could not find source buffer")
  end
  local bufdata = buf_to_symbols[bufnr]
  if not bufdata then
    bufdata = BufData.new(bufnr)
    if bufnr then
      buf_to_symbols[bufnr] = bufdata
    end
  end
  return bufdata
end

---@param buf nil|integer
---@param items aerial.Symbol[]
function M.set_symbols(buf, items)
  local bufnr = util.get_buffers(buf)
  local bufdata = M.get_or_create(bufnr)
  bufdata.items = items
  bufdata.flat_items = {}
  bufdata.max_level = 0
  local i = 1
  local prev_by_level = {}
  local max_level = 0
  bufdata:visit(function(item)
    item.idx = i
    item.id = string.format("%d:%s", i, item.name)
    local prev = prev_by_level[item.level]
    if prev then
      prev.next_sibling = item
      item.prev_sibling = prev
    end
    for j = item.level + 1, max_level do
      prev_by_level[j] = nil
    end
    max_level = item.level
    prev_by_level[item.level] = item
    bufdata.max_level = math.max(bufdata.max_level, item.level)
    table.insert(bufdata.flat_items, item)
    i = i + 1
  end)
end

---@param buf nil|integer
function M.delete_buf(buf)
  local bufnr, _ = util.get_buffers(buf)
  if bufnr then
    buf_to_symbols[bufnr] = nil
  end
end

---Return true if the backend has finished fetching symbols
---@param bufnr integer
---@return boolean
function M.has_received_data(bufnr)
  return M.get(bufnr) ~= nil
end

---Return true if the buffer has any symbols
---@param bufnr nil|integer
---@return boolean
function M.has_symbols(bufnr)
  local bufdata = M.get(bufnr)
  return bufdata ~= nil and bufdata.items[1] ~= nil
end

return M
