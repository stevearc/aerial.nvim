local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
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

local allowed_fields = {
  "kind",
  "name",
  "level",
  "lnum",
  "col",
  "end_lnum",
  "end_col",
  "scope",
  "selection_range",
}
local function sanitize_symbols(symbols)
  for _, item in ipairs(symbols) do
    for k, _ in pairs(item) do
      if k == "children" then
        sanitize_symbols(item[k])
      elseif not vim.tbl_contains(allowed_fields, k) then
        item[k] = nil
      end
    end
  end
  return symbols
end

---@param backend_name string
---@param filename string
---@param symbols_file string
M.test_file_symbols = function(backend_name, filename, symbols_file)
  config.setup({
    backends = { backend_name },
    filter_kind = false,
  })
  vim.cmd(string.format("edit %s", filename))
  local backend = backends.get(0)
  if not backend then
    local msg = string.format(
      "Could not find aerial backend for %s with filetype '%s'. If this is not correct, you may need a special filetype rule in tests/minimal_init.lua.",
      filename,
      vim.bo.filetype
    )
    assert(backend, msg)
  end
  backend.fetch_symbols_sync()
  local items = data.get_or_create(0).items
  vim.api.nvim_buf_delete(0, { force = true })
  if vim.fn.filereadable(symbols_file) == 0 or vim.env.UPDATE_SYMBOLS then
    local content = sanitize_symbols(vim.deepcopy(items))
    local formatted_json = vim.fn.system("jq --sort-keys", vim.json.encode(content))
    local fd = assert(vim.loop.fs_open(symbols_file, "w", 420)) -- 0644
    vim.loop.fs_write(fd, formatted_json)
    vim.loop.fs_close(fd)
    print("Updated " .. symbols_file)
  else
    local fd = assert(vim.loop.fs_open(symbols_file, "r", 420)) -- 0644
    local stat = assert(vim.loop.fs_fstat(fd))
    local content = assert(vim.loop.fs_read(fd, stat.size))
    vim.loop.fs_close(fd)
    local expected = vim.json.decode(content)
    M.assert_tree_equals(items, expected)
  end
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
    for _, field in ipairs(allowed_fields) do
      local s_field = string.rep(" ", 17 - string.len(field)) .. field
      local line = string.format("%s = %s", s_field, vim.inspect(exp_child[field]))
      if not vim.deep_equal(child[field], exp_child[field]) then
        line = line .. string.format("  [%s]", vim.inspect(child[field]))
      end
      table.insert(lines, line)
    end
    table.insert(lines, "}")
    local err_msg = table.concat(lines, "\n")
    for _, field in ipairs(allowed_fields) do
      assert.same(exp_child[field], child[field], err_msg)
    end
    table.insert(path, exp_child.name)
    M.assert_tree_equals(child.children, exp_child.children, path)
    table.remove(path, #path)
  end
end

M.reset_editor = function()
  require("aerial").setup({})
  require("aerial").sync_load()
  vim.cmd.tabonly({ mods = { silent = true } })
  for i, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if i > 1 then
      vim.api.nvim_win_close(winid, true)
    end
  end
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))
  vim.bo.bufhidden = "wipe"
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

return M
