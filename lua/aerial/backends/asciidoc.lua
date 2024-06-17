local backend_util = require("aerial.backends.util")
local backends = require("aerial.backends")
local config = require("aerial.config")
local util = require("aerial.util")

local M = {}

M.is_supported = function(bufnr)
  if
    not (
      vim.tbl_contains(util.get_filetypes(bufnr), "asciidoc")
      or vim.tbl_contains(util.get_filetypes(bufnr), "loongdoc")
    )
  then
    return false, "Filetype is not asciidoc"
  end
  return true, nil
end

M.fetch_symbols_sync = function(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local items = {}
  local stack = {}
  local block_kind = ""
  local inside_code_block = false
  for lnum, line in ipairs(lines) do
    local idx, len = string.find(line, "^=+ ")
    if idx == 1 and not inside_code_block then
      local level = len - 2
      local parent = stack[math.min(level, #stack)]
      local item = {
        kind = "Interface",
        name = string.sub(line, len + 1),
        level = level,
        parent = parent,
        lnum = lnum,
        col = 0,
        end_lnum = 0,
      }
      if parent then
        if not parent.children then
          parent.children = {}
        end
        table.insert(parent.children, item)
      else
        if
          not config.post_parse_symbol
          or config.post_parse_symbol(bufnr, item, {
              backend_name = "asciidoc",
              lang = "asciidoc",
            })
            ~= false
        then
          table.insert(items, item)
        end
      end
      while #stack > level and #stack > 0 do
        table.remove(stack, #stack)
      end
      table.insert(stack, item)
    elseif
      line == "----"
      or line == "****"
      or line == "...."
      or line == "===="
      or line == "|==="
    then
      if not inside_code_block then
        block_kind = line
        inside_code_block = true
      elseif block_kind == line then
        inside_code_block = false
      end
    end
  end
  backends.set_symbols(bufnr, items, { backend_name = "asciidoc", lang = "asciidoc" })
end

M.fetch_symbols = M.fetch_symbols_sync

M.attach = function(bufnr)
  backend_util.add_change_watcher(bufnr, "asciidoc")
end

M.detach = function(bufnr)
  backend_util.remove_change_watcher(bufnr, "asciidoc")
end

return M
