local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local M = {}

---@param symbol aerial.Symbol
---@return string
local function serialize_symbol(symbol)
  local pieces = { string.rep("  ", symbol.level) }
  if symbol.scope then
    vim.list_extend(pieces, { symbol.scope, " " })
  end
  vim.list_extend(
    pieces,
    { symbol.kind, " ", symbol.name, "|", tostring(symbol.lnum), ":", tostring(symbol.col) }
  )
  if symbol.end_lnum then
    vim.list_extend(pieces, { "-", tostring(symbol.end_lnum) })
    if symbol.end_col then
      vim.list_extend(pieces, { ":", tostring(symbol.end_col) })
    end
  end
  local rng = symbol.selection_range
  if rng then
    vim.list_extend(
      pieces,
      { " (", rng.lnum, ":", rng.col, "-", rng.end_lnum, ":", rng.end_col, ")" }
    )
  end

  return table.concat(pieces, "")
end

---@param symbols table
---@param lines? string[]
---@return string[]
local function serialize_symbols(symbols, lines)
  if not lines then
    lines = {}
  end
  for _, symbol in ipairs(symbols) do
    table.insert(lines, serialize_symbol(symbol))
    serialize_symbols(symbol.children or {}, lines)
  end
  return lines
end

---@param expected string
---@param received string
local function format_mismatch(expected, received)
  local expected_lines = vim.split(expected, "\n")
  local received_lines = vim.split(received, "\n")
  local max_width = 1
  for _, line in ipairs(expected_lines) do
    local width = vim.api.nvim_strwidth(line)
    if width > max_width then
      max_width = width
    end
  end

  local ret = {}
  for i = 1, math.max(#expected_lines, #received_lines) do
    local l1 = expected_lines[i] or ""
    local l2 = received_lines[i] or ""
    local sep = " < > "
    if l1 ~= l2 then
      sep = " </> "
    end
    table.insert(ret, l1 .. string.rep(" ", max_width - vim.api.nvim_strwidth(l1)) .. sep .. l2)
  end
  return table.concat(ret, "\n")
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
  local serialized = table.concat(serialize_symbols(items), "\n")
  if vim.fn.filereadable(symbols_file) == 0 or vim.env.UPDATE_SYMBOLS then
    local fd = assert(vim.loop.fs_open(symbols_file, "w", 420)) -- 0644
    vim.loop.fs_write(fd, serialized)
    vim.loop.fs_close(fd)
    print("Updated " .. symbols_file)
  else
    local fd = assert(vim.loop.fs_open(symbols_file, "r", 420)) -- 0644
    local stat = assert(vim.loop.fs_fstat(fd))
    local snapshot = assert(vim.loop.fs_read(fd, stat.size))
    vim.loop.fs_close(fd)
    if serialized ~= snapshot then
      assert(serialized == snapshot, "Symbols mismatch\n" .. format_mismatch(snapshot, serialized))
    end
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
