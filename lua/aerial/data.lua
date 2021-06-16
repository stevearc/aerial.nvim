local BufData = {
  new = function(t)
    local new = {
      items = {},
      positions = {},
      last_position = {},
    }
    setmetatable(new, {__index = t})
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

  visit = function(self, callback)
    local function visit_item(item)
      local ret = callback(item)
      if ret then return ret end
      if item.children then
        for _,child in ipairs(item.children) do
          ret = visit_item(child)
          if ret then return ret end
        end
      end
    end
    for _,item in ipairs(self.items) do
      local ret = visit_item(item)
      if ret then return ret end
    end
  end,

  count = function(self)
    local count = 0
    self:visit(function(_)
      count = count + 1
    end)
    return count
  end,
}

local Data = setmetatable({}, {
  __index = function(t, bufnr)
    if bufnr == 0 then
      bufnr = vim.api.nvim_get_current_buf()
    end
    local bufdata = rawget(t, bufnr)
    if not bufdata then
      bufdata = BufData:new()
      t[bufnr] = bufdata
    end
    return bufdata
  end
})

function Data:has_symbols(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return rawget(self, bufnr) ~= nil
end

return Data
