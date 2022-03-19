local util = require("aerial.util")
local config = require("aerial.config")

local BufData = {
  new = function(t)
    local new = {
      items = {},
      positions = {},
      last_win = -1,
      collapsed = {},
    }
    setmetatable(new, { __index = t })
    return new
  end,

  item = function(self, idx)
    local i = 1
    return self:visit(function(item)
      if i == idx then
        return item
      end
      i = i + 1
    end)
  end,

  indexof = function(self, target)
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
  end,

  _get_item_key = function(_, item)
    local key = string.format("%s:%s", item.kind, item.name)
    while item.parent do
      item = item.parent
      key = string.format("%s:%s", item.name, key)
    end
    return key
  end,

  is_collapsed = function(self, item)
    local key = self:_get_item_key(item)
    return self.collapsed[key]
  end,

  set_collapsed = function(self, item, collapsed)
    local key = self:_get_item_key(item)
    if collapsed then
      self.collapsed[key] = true
    else
      self.collapsed[key] = nil
    end
  end,

  is_collapsable = function(_, item)
    return config.manage_folds or (item.children and not vim.tbl_isempty(item.children))
  end,

  get_root_of = function(_, item)
    while item.parent do
      item = item.parent
    end
    return item
  end,

  visit = function(self, callback, opts)
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
  end,

  flatten = function(self, filter, opts)
    local items = {}
    self:visit(function(item)
      if not filter or filter(item) then
        table.insert(items, item)
      end
    end, opts)
    return items
  end,

  count = function(self, incl_hidden)
    local count = 0
    self:visit(function(_)
      count = count + 1
    end, { incl_hidden = incl_hidden })
    return count
  end,
}

local Data = setmetatable({}, {
  __index = function(t, buf)
    local bufnr, _ = util.get_buffers(buf)
    local bufdata = rawget(t, bufnr)
    if not bufdata then
      bufdata = BufData:new()
      t[bufnr] = bufdata
    end
    return bufdata
  end,
})

function Data:has_received_data(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local bufdata = rawget(self, bufnr)
  return bufdata ~= nil
end

function Data:has_symbols(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local bufdata = rawget(self, bufnr)
  return bufdata ~= nil and bufdata.items[1] ~= nil
end

return Data
