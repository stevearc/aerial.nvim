local data = require("aerial.data")
local backends = require("aerial.backends")
local M = {}

M.test_file_symbols = function(backend_name, filename, expected)
  vim.g.aerial_backends = { backend_name }
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
    type(received),
    type(expected),
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
    #received,
    #expected,
    string.format(
      "Number of symbols at '/%s' do not match %d ~= %d",
      table.concat(path, "/"),
      #received,
      #expected
    )
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
    table.insert(path, exp_child.name)
    M.assert_tree_equals(child.children, exp_child.children, path)
    table.remove(path, #path)
  end
end

return M
