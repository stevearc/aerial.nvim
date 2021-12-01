local backends = require("aerial.backends")
local config = require("aerial.config")
local language_kind_map = require("aerial.backends.treesitter.language_kind_map")
local util = require("aerial.backends.util")
local M = {}

M.is_supported = function(bufnr)
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end
  local lang = parsers.get_buf_lang(bufnr)
  if not parsers.has_parser(lang) then
    return false
  end
  local query = require("nvim-treesitter.query")
  return query.has_query_files(lang, "aerial")
end

M.fetch_symbols_sync = function(timeout)
  local parsers = require("nvim-treesitter.parsers")
  local query = require("nvim-treesitter.query")
  local ts_utils = require("nvim-treesitter.ts_utils")
  local utils = require("nvim-treesitter.utils")
  local bufnr = 0
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local parser = parsers.get_parser(bufnr)
  local items = {}
  if parser then
    local stack = {}
    local function get_parent(node)
      if #stack == 0 or not node then
        return nil, nil, 0
      end
      local len = #stack
      local last_node, last_item = unpack(stack[len])
      if ts_utils.is_parent(last_node, node) then
        return last_item, last_node, len
      else
        table.remove(stack, len)
        return get_parent(node)
      end
    end

    parser:for_each_tree(function(tree, lang_tree)
      local lang = lang_tree:lang()
      local kind_map = language_kind_map[lang]
      local include_kind = config.get_filter_kind_map(filetype)
      if query.has_query_files(lang, "aerial") then
        for match in query.iter_group_results(bufnr, "aerial", tree:root(), lang) do
          local name_node = (utils.get_at_path(match, "name") or {}).node
          local type_node = (utils.get_at_path(match, "type") or {}).node
          local loc_node = (utils.get_at_path(match, "location") or {}).node
          local parent, parent_node, level = get_parent(type_node)
          if type_node and type_node ~= parent_node then
            local kind = kind_map[type_node:type()]
            if not kind then
              vim.api.nvim_err_writeln(
                string.format("Missing entry in aerial treesitter kind_map: %s", type_node:type())
              )
              break
            end
            if include_kind[kind] then
              local row, col
              if loc_node then
                row, col = loc_node:start()
              else
                row, col = type_node:start()
              end
              local name
              if name_node then
                name = ts_utils.get_node_text(name_node, bufnr)[1] or "<parse error>"
              else
                name = "<Anonymous>"
              end
              local item = {
                kind = kind,
                name = name,
                level = level,
                parent = parent,
                lnum = row + 1,
                col = col,
              }
              if parent then
                if not parent.children then
                  parent.children = {}
                end
                table.insert(parent.children, item)
              else
                table.insert(items, item)
              end
              table.insert(stack, { type_node, item })
            end
          end
        end
      end
    end)
  end
  backends.set_symbols(bufnr, items)
end

M.fetch_symbols = M.fetch_symbols_sync

M.attach = function(bufnr)
  util.add_change_watcher(bufnr, "treesitter")
  M.fetch_symbols()
end

M.detach = function(bufnr)
  util.remove_change_watcher(bufnr, "treesitter")
end

return M
