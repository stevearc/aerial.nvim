local backend_util = require("aerial.backends.util")
local backends = require("aerial.backends")
local config = require("aerial.config")
local util = require("aerial.util")

local M = {}

M.is_supported = function(bufnr)
  if not vim.tbl_contains(util.get_filetypes(bufnr), "man") then
    return false, "Filetype is not man"
  end
  return true, nil
end

M.fetch_symbols_sync = function(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local items = {}
  local last_header
  local prev_lnum = 0
  local prev_line = ""
  local function finalize_header(lnum)
    if last_header then
      last_header.end_lnum = prev_lnum
      last_header.end_col = prev_line:len()
    end
  end
  for lnum, line in ipairs(lines) do
    local header = line:match("^[A-Z].+")
    local padding, arg = line:match("^(%s+)(-.+)")
    if header and lnum > 1 then
      finalize_header()
      local item = {
        kind = "Interface",
        name = header,
        level = 0,
        lnum = lnum,
        col = 0,
      }
      if
        not config.post_parse_symbol
        or config.post_parse_symbol(bufnr, item, {
            backend_name = "man",
            lang = "man",
          })
          ~= false
      then
        last_header = item
        table.insert(items, item)
      end
    elseif arg then
      local item = {
        kind = "Interface",
        name = arg,
        level = last_header and 1 or 0,
        lnum = lnum,
        parent = last_header,
        col = padding:len(),
        end_lnum = lnum,
        end_col = line:len(),
      }
      if
        not config.post_parse_symbol
        or config.post_parse_symbol(bufnr, item, {
            backend_name = "man",
            lang = "man",
          })
          ~= false
      then
        if last_header then
          last_header.children = last_header.children or {}
          table.insert(last_header.children, item)
        else
          table.insert(items, item)
        end
      end
    end
    prev_lnum = lnum
    prev_line = line
  end
  finalize_header()
  backends.set_symbols(bufnr, items, { backend_name = "man", lang = "man" })
end

M.fetch_symbols = M.fetch_symbols_sync

M.attach = function(bufnr)
  backend_util.add_change_watcher(bufnr, "man")
end

M.detach = function(bufnr)
  backend_util.remove_change_watcher(bufnr, "man")
end

return M
