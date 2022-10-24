local util = require("aerial.util")
local config = require("aerial.config")

---@class aerial.Range
---@field lnum integer
---@field end_lnum integer
---@field col integer
---@field end_col integer

---@class aerial.Symbol
---@field kind string
---@field name string
---@field level integer
---@field parent? aerial.Symbol
---@field lnum integer
---@field end_lnum integer
---@field col integer
---@field end_col integer
---@field selection_range? aerial.Range
---@field children? aerial.Symbol[]

---@class aerial.BufData
---@field bufnr integer
---@field items aerial.Symbol[]
---@field flat_items aerial.Symbol[]
---@field positions any
---@field last_win integer
---@field collapsed table<string, boolean>
---@field collapse_level integer
local BufData = {}

---@param bufnr integer
function BufData.new(bufnr)
  local new = {
    bufnr = bufnr,
    items = {},
    flat_items = {},
    positions = {},
    last_win = -1,
    collapsed = {},
    collapse_level = 99,
  }
  -- cache the evaluation of managing folds
  new.manage_folds = config.manage_folds(bufnr)
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
  return item
    and (
      self.collapsed[item.id]
      or (self.collapse_level <= item.level and self.collapsed[item.id] ~= false)
    )
end

---@param item aerial.Symbol
---@param collapsed boolean
function BufData:set_collapsed(item, collapsed)
  self.collapsed[item.id] = collapsed
end

---@param item aerial.Symbol
---@return boolean
function BufData:is_collapsable(item)
  return self.manage_folds or (item.children and not vim.tbl_isempty(item.children))
end

function BufData:_next_non_collapsed(item)
  while item do
    if item.next_sibling then
      return item.next_sibling
    end
    item = item.parent
  end
end

function BufData:iter(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    skip_hidden = true,
  })
  local j = 0
  return function(_, i, a, b)
    i = i + 1
    j = j + 1
    local item = self.flat_items[i]
    if opts.skip_hidden and item and self:is_collapsed(item.parent) then
      item = self:_next_non_collapsed(item.parent)
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

---@param include_hidden boolean
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
  local bufdata = M.get_or_create(buf)
  bufdata.items = items
  bufdata.flat_items = {}
  local i = 1
  bufdata:visit(function(item)
    item.idx = i
    item.id = string.format("%d:%s", i, item.name)
    table.insert(bufdata.flat_items, item)
    i = i + 1
    if item.children then
      local child
      for _, next_sibling in ipairs(item.children) do
        if child then
          child.next_sibling = next_sibling
        end
        child = next_sibling
      end
    end
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
---@param bufnr integer
---@return boolean
function M.has_symbols(bufnr)
  local bufdata = M.get(bufnr)
  return bufdata ~= nil and bufdata.items[1] ~= nil
end

return M
