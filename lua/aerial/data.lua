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
---@field items aerial.Symbol[]
---@field positions any
---@field last_win integer
---@field collapsed table<string, boolean>
---@field collapse_level integer
local BufData = {}

function BufData.new()
  local new = {
    items = {},
    positions = {},
    last_win = -1,
    collapsed = {},
    collapse_level = 99,
  }
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

---@param item aerial.Symbol
---@return string
function BufData:_get_item_key(item)
  local key = string.format("%s:%s", item.kind, item.name)
  while item.parent do
    item = item.parent
    key = string.format("%s:%s", item.name, key)
  end
  return key
end

function BufData:clear_collapsed()
  self.collapsed = {}
end

---@param item aerial.Symbol
---@return boolean
function BufData:is_collapsed(item)
  local key = self:_get_item_key(item)
  return self.collapsed[key] or (self.collapse_level <= item.level and self.collapsed[key] ~= false)
end

---@param item aerial.Symbol
---@param collapsed boolean
function BufData:set_collapsed(item, collapsed)
  local key = self:_get_item_key(item)
  self.collapsed[key] = collapsed
end

---@param item aerial.Symbol
---@return boolean
function BufData:is_collapsable(item)
  return config.manage_folds or (item.children and not vim.tbl_isempty(item.children))
end

---@param item aerial.Symbol
---@return aerial.Symbol
function BufData:get_root_of(item)
  while item.parent do
    item = item.parent
  end
  return item
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
  local count = 0
  self:visit(function(_)
    count = count + 1
  end, { incl_hidden = incl_hidden })
  return count
end

local Data = setmetatable({}, {
  __index = function(t, buf)
    return t:get_or_create(buf)
  end,
})

---@return aerial.BufData
function Data.create()
  return BufData:new()
end

---@param buf integer
---@return aerial.BufData
function Data:get_or_create(buf)
  local bufnr, _ = util.get_buffers(buf)
  local bufdata = rawget(self, bufnr)
  if not bufdata then
    bufdata = BufData:new()
    if bufnr then
      self[bufnr] = bufdata
    end
  end
  return bufdata
end

---@param buf integer
---@param items aerial.Symbol[]
function Data:set_symbols(buf, items)
  local bufdata = self:get_or_create(buf)
  bufdata.items = items
end

---@param buf integer
function Data:delete_buf(buf)
  local bufnr, _ = util.get_buffers(buf)
  if bufnr then
    self[bufnr] = nil
  end
end

---@param bufnr integer
---@return boolean
function Data:has_received_data(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local bufdata = rawget(self, bufnr)
  return bufdata ~= nil
end

---@param bufnr integer
---@return boolean
function Data:has_symbols(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local bufdata = rawget(self, bufnr)
  return bufdata ~= nil and bufdata.items[1] ~= nil
end

return Data
