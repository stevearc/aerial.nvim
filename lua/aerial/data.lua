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
  local i = 1
  return self:visit(function(item)
    if i == idx then
      return item
    end
    i = i + 1
  end)
end

---@param target? aerial.Symbol
---@return integer|nil
function BufData:indexof(target)
  if target == nil then
    return nil
  end
  local i = 1
  return self:visit(function(item)
    if item == target then
      return i
    end
    i = i + 1
  end)
end

function BufData:clear_collapsed()
  self.collapsed = {}
end

---@param item aerial.Symbol
---@return boolean
function BufData:is_collapsed(item)
  return self.collapsed[item.id]
    or (self.collapse_level <= item.level and self.collapsed[item.id] ~= false)
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

---@generic T
---@param callback fun(item: aerial.Symbol, ctx: {collapsed: boolean, is_last_by_level: boolean}): T
---@param opts? {incl_hidden: boolean|nil}
---@return T
function BufData:visit(callback, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    incl_hidden = false,
  })
  -- Stack of bools where each one indicates if the item at that level is the
  -- last of its siblings
  local is_last_by_level = {}
  local function visit_item(item)
    local ret = callback(item, {
      collapsed = self:is_collapsed(item),
      is_last_by_level = is_last_by_level,
    })
    if ret then
      return ret
    end
    if item.children and (opts.incl_hidden or not self:is_collapsed(item)) then
      local children_len = #item.children
      for i, child in ipairs(item.children) do
        is_last_by_level[child.level] = i == children_len
        ret = visit_item(child)
        if ret then
          return ret
        end
      end
    end
  end
  for _, item in ipairs(self.items) do
    local ret = visit_item(item)
    if ret then
      return ret
    end
  end
end

---@param filter fun(item: aerial.Symbol): boolean
---@param opts? {incl_hidden: boolean|nil}
---@return aerial.Symbol[]
function BufData:flatten(filter, opts)
  local items = {}
  self:visit(function(item)
    if not filter or filter(item) then
      table.insert(items, item)
    end
  end, opts)
  return items
end

---@param incl_hidden boolean
---@return integer
function BufData:count(incl_hidden)
  if incl_hidden then
    return #self.flat_items
  end
  local count = 0
  self:visit(function(_)
    count = count + 1
  end, { incl_hidden = incl_hidden })
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
  bufdata.flat_items = bufdata:flatten(nil, { incl_hidden = true })
  for i, item in ipairs(bufdata.flat_items) do
    item.id = string.format("%d:%s", i, item.name)
  end
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
