local backends = require("aerial.backends")
local data = require("aerial.data")
local navigation = require("aerial.navigation")
local M = {}

M.get_labels = function(opts)
  opts = opts or {}
  local backend = backends.get()
  if not backend then
    backends.log_support_err()
    return nil
  elseif not data:has_symbols(0) then
    backend.fetch_symbols_sync(0, opts)
  end
  local results = {}
  if data:has_symbols(0) then
    data[0]:visit(function(item)
      local label = string.format("%d:%s", item.lnum, item.name)
      table.insert(results, label)
    end)
  end
  return results
end

M.goto_symbol = function(symbol)
  local colon = string.find(symbol, ":")
  local lnum = tonumber(string.sub(symbol, 1, colon - 1))
  local name = string.sub(symbol, colon + 1)
  local idx = 1
  data[0]:visit(function(item)
    if lnum == item.lnum and name == item.name then
      navigation.select({
        index = idx,
      })
      return true
    end
    idx = idx + 1
  end)
end

return M
