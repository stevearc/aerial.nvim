local util = require 'aerial.util'

local BufData = {
  new = function(t)
    local new = {
      items = {},
      positions = {},
      last_position = 1,
      collapsed = {},
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

  _is_collapsed = function(self, item)
    local key = self:_get_item_key(item)
    return self.collapsed[key]
  end,

  _is_collapsable = function(_, item)
      return item.children and not vim.tbl_isempty(item.children)
  end,

  _get_config = function(self, item)
    return {
      collapsed = self:_is_collapsed(item),
      has_children = self:_is_collapsable(item),
    }
  end,

  action = function(self, action, opts)
    opts = vim.tbl_extend('keep', opts or {}, {
      recurse = false,
      bubble = true,
    })
    local did_update = false
    local function do_action(item, bubble)
      if bubble then
        while item and not self:_is_collapsable(item) do
          item = item.parent
        end
      end
      if not item or not self:_is_collapsable(item) then
        return
      end
      local key = self:_get_item_key(item)
      if action == 'toggle' then
        action = self.collapsed[key] and 'open' or 'close'
      end
      if action == 'open' then
        did_update = did_update or self.collapsed[key]
        self.collapsed[key] = nil
        if opts.recurse then
          for _,child in ipairs(item.children) do
            do_action(child, false)
          end
        end
      elseif action == 'close' then
        did_update = did_update or not self.collapsed[key]
        self.collapsed[key] = true
        if opts.recurse and item.parent then
          return do_action(item.parent, false)
        end
        return item
      else
        error(string.format("Unknown action '%s'", action))
      end
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_item = self:item(cursor[1])
    local item = do_action(current_item, opts.bubble)
    return did_update, self:indexof(item)
  end,

  visit = function(self, callback, opts)
    opts = vim.tbl_extend('keep', opts or {}, {
      incl_hidden = false,
    })
    local function visit_item(item)
      local ret = callback(item, self:_get_config(item))
      if ret then return ret end
      if item.children
        and (opts.incl_hidden or not self:_is_collapsed(item)) then
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

  count = function(self, incl_hidden)
    local count = 0
    self:visit(function(_)
      count = count + 1
    end, {incl_hidden = incl_hidden})
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
  end
})

function Data:has_symbols(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return rawget(self, bufnr) ~= nil
end

return Data
