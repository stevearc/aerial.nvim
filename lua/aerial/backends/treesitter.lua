local backends = require("aerial.backends")
local config = require("aerial.config")
local parsers = require("nvim-treesitter.parsers")
local query = require("nvim-treesitter.query")
local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require("nvim-treesitter.utils")
local M = {}

local language_kind_map = {
  lua = {
    function_definition = "Function",
    local_function = "Function",
    ["function"] = "Function",
  },
  python = {
    function_definition = "Function",
    class_definition = "Class",
  },
  rst = {
    section = "Namespace",
  },
}

M.is_supported = function(bufnr)
  local lang = parsers.get_buf_lang(bufnr)
  return parsers.has_parser(lang)
end

M.fetch_symbols_sync = function(timeout)
  local bufnr = 0
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
      if query.has_query_files(lang, "aerial") then
        for match in query.iter_group_results(bufnr, "aerial", tree:root(), lang) do
          local name_node = (utils.get_at_path(match, "name") or {}).node
          local type_node = (utils.get_at_path(match, "type") or {}).node
          local parent, parent_node, level = get_parent(type_node)
          if type_node and type_node ~= parent_node then
            local row, col = type_node:start()
            local kind = kind_map[type_node:type()]
            if not kind then
              vim.api.nvim_err_writeln(
                string.format("Missing entry in aerial treesitter kind_map: %s", type_node:type())
              )
              break
            end
            local name
            if name_node then
              name = ts_utils.get_node_text(name_node, bufnr)[1] or "<parse error>"
            else
              name = "<Anonymous>"
            end
            local item = {
              kind = kind_map[type_node:type()],
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
    end)
  end
  backends.set_symbols(0, items)
end

M.fetch_symbols = M.fetch_symbols_sync

M.attach = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  vim.cmd(string.format(
    [[augroup AerialTS
      au! * <buffer=%d>
      au TextChanged <buffer=%d> lua require'aerial.backends.treesitter'._on_text_changed()
      au InsertLeave <buffer=%d> lua require'aerial.backends.treesitter'._on_insert_leave()
    augroup END
    ]],
    bufnr,
    bufnr,
    bufnr
  ))
  M.fetch_symbols()
end

M.detach = function(bufnr)
  vim.cmd(string.format(
    [[augroup AerialTS
      au! * <buffer=%d>
    augroup END
    ]],
    bufnr
  ))
end

local timer = nil
local function throttle_update()
  if timer or not backends.is_backend_attached(0, "treesitter") then
    return
  end
  timer = vim.loop.new_timer()
  timer:start(
    config["treesitter.update_delay"],
    0,
    vim.schedule_wrap(function()
      timer:close()
      timer = nil
      M.fetch_symbols()
    end)
  )
end

M._on_text_changed = function()
  throttle_update()
end

M._on_insert_leave = function()
  throttle_update()
end

return M
