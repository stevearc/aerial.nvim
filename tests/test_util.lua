local data = require("aerial.data")
local backends = require("aerial.backends")
local M = {}

M.test_file_symbols = function(backend_name, filename, expected)
  vim.g.aerial_backends = { backend_name }
  vim.cmd(string.format("edit %s", filename))
  local backend = backends.get(0)
  backend.fetch_symbols_sync()
  M.assert_tree_equals(data[0].items, expected)
end

M.assert_tree_equals = function(received, expected)
  assert.equals(
    type(received),
    type(expected),
    string.format("Symbol list mismatch %s ~= %s", type(received), type(expected))
  )
  if type(received) ~= "table" then
    return
  end
  assert.equals(
    #received,
    #expected,
    string.format("Number of symbols do not match %d ~= %d", #received, #expected)
  )
  for i, child in ipairs(received) do
    local exp_child = expected[i]
    local err_msg = string.format(
      [[Symbol mismatch: {
  kind  = %s, (%s)
  name  = %s, (%s)
  level = %s, (%s)
  lnum  = %s, (%s)
  col   = %s, (%s)
}]],
      child.kind,
      exp_child.kind,
      child.name,
      exp_child.name,
      child.level,
      exp_child.level,
      child.lnum,
      exp_child.lnum,
      child.col,
      exp_child.col
    )
    local fields = { "kind", "name", "level", "lnum", "col" }
    for _, field in ipairs(fields) do
      assert.equals(child[field], exp_child[field], err_msg)
    end
    M.assert_tree_equals(child.children, exp_child.children)
  end
end

return M
