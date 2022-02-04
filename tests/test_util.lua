local data = require("aerial.data")
local backends = require("aerial.backends")
local config = require("aerial.config")
local M = {}

local function summarize(received, expected)
  local lines = { "RECEIVED" }
  local max_len = 8
  local function summary(symbol)
    return string.format("%s %s", symbol.kind, symbol.name)
  end
  for _, symbol in ipairs(received) do
    local s = summary(symbol)
    max_len = math.max(max_len, string.len(s))
    table.insert(lines, s)
  end
  lines[1] = lines[1] .. string.rep(" ", max_len - string.len(lines[1]) + 4) .. "EXPECTED"
  for i, symbol in ipairs(expected) do
    local j = i + 1
    if lines[j] then
      local padding = string.rep(" ", max_len - string.len(lines[j]))
      lines[j] = lines[j] .. padding .. " <> " .. summary(symbol)
    else
      lines[j] = string.rep(" ", max_len) .. " <> " .. summary(symbol)
    end
  end
  return table.concat(lines, "\n")
end

M.test_file_symbols = function(backend_name, filename, expected)
  config.setup({
    backends = { backend_name },
    filter_kind = false,
  })
  vim.cmd(string.format("edit %s", filename))
  local backend = backends.get(0)
  backend.fetch_symbols_sync()
  local items = data[0].items
  vim.api.nvim_buf_delete(0, { force = true })
  M.assert_tree_equals(items, expected)
end

M.assert_tree_equals = function(received, expected, path)
  path = path or {}
  assert.equals(
    type(expected),
    type(received),
    string.format(
      "Symbol list mismatch at %s: %s ~= %s",
      table.concat(path, "/"),
      type(received),
      type(expected)
    )
  )
  if type(received) ~= "table" then
    return
  end
  assert.equals(
    #expected,
    #received,
    string.format(
      "Number of symbols at '/%s' do not match %d ~= %d\n%s",
      table.concat(path, "/"),
      #received,
      #expected,
      summarize(received, expected)
    )
  )
  for i, child in ipairs(received) do
    local exp_child = expected[i]
    local lines = { "Symbol mismatch: {" }
    local fields = { "kind", "name", "level", "lnum", "col", "end_lnum", "end_col" }
    for _, field in ipairs(fields) do
      local s_field = string.rep(" ", 8 - string.len(field)) .. field
      local line = string.format("%s = %s", s_field, exp_child[field])
      if child[field] ~= exp_child[field] then
        line = line .. string.format("  [%s]", child[field])
      end
      table.insert(lines, line)
    end
    table.insert(lines, "}")
    local err_msg = table.concat(lines, "\n")
    for _, field in ipairs(fields) do
      assert.equals(exp_child[field], child[field], err_msg)
    end
    table.insert(path, exp_child.name)
    M.assert_tree_equals(child.children, exp_child.children, path)
    table.remove(path, #path)
  end
end

return M
