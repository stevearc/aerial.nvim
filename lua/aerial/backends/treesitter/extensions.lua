local config = require("aerial.config")
-- This file is used by the markdown backend as well.
-- We pcall(require) so it doesn't error when nvim-treesitter isn't installed.
local _, utils = pcall(require, "nvim-treesitter.utils")
local helpers = require("aerial.backends.treesitter.helpers")
local M = {}

---@diagnostic disable deprecated

local get_node_text
if vim.treesitter.get_node_text then
  -- Neovim 0.9
  get_node_text = vim.treesitter.get_node_text
elseif vim.treesitter.query and vim.treesitter.query.get_node_text then
  get_node_text = vim.treesitter.query.get_node_text
else
  local ts_utils = require("nvim-treesitter.ts_utils")
  get_node_text = function(node, buf)
    return ts_utils.get_node_text(node, buf)[1]
  end
end

local default_methods = {
  get_parent = function(stack, match, node)
    local ts_utils = require("nvim-treesitter.ts_utils")
    for i = #stack, 1, -1 do
      local last_node = stack[i].node
      if ts_utils.is_parent(last_node, node) then
        return stack[i].item, last_node, i
      else
        table.remove(stack, i)
      end
    end
    return nil, nil, 0
  end,
  postprocess = function(bufnr, item, match) end,
  postprocess_symbols = function(bufnr, items) end,
}

setmetatable(M, {
  __index = function()
    return default_methods
  end,
})

local function get_line_len(bufnr, lnum)
  return vim.api.nvim_strwidth(vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1])
end

local function set_end_range(bufnr, items, last_line)
  if not items then
    return
  end
  if not last_line then
    last_line = vim.api.nvim_buf_line_count(bufnr)
  end
  local prev = nil
  for _, item in ipairs(items) do
    if prev then
      prev.end_lnum = item.lnum - 1
      prev.end_col = get_line_len(bufnr, prev.end_lnum)
      set_end_range(bufnr, prev.children, prev.end_lnum)
    end
    prev = item
  end
  if prev then
    prev.end_lnum = last_line
    prev.end_col = get_line_len(bufnr, last_line)
    set_end_range(bufnr, prev.children, last_line)
  end
end

M.elixir = {
  kind_map = {
    callback = "Function",
    def = "Function",
    defguard = "Function",
    defimpl = "Class",
    defmacro = "Function",
    defmacrop = "Function",
    defmodule = "Module",
    defp = "Function",
    defprotocol = "Interface",
    defstruct = "Struct",
    module_attribute = "Field",
    spec = "TypeParameter",
  },
  postprocess = function(bufnr, item, match)
    local identifier = (utils.get_at_path(match, "identifier") or {}).node
    if identifier then
      local name = get_node_text(identifier, bufnr) or "<parse error>"
      if name == "defp" then
        item.scope = "private"
      end
      item.kind = M.elixir.kind_map[name] or item.kind
      if name == "callback" and item.parent then
        item.parent.kind = "Interface"
      elseif name == "defstruct" and item.parent then
        item.parent.kind = "Struct"
        return false
      elseif name == "defimpl" then
        local protocol = (utils.get_at_path(match, "protocol") or {}).node
        local protocol_name = get_node_text(protocol, bufnr) or "<parse error>"
        item.name = string.format("%s > %s", item.name, protocol_name)
      elseif name == "test" then
        item.name = string.format("test %s", item.name)
      elseif name == "describe" then
        item.name = string.format("describe %s", item.name)
      end
    elseif item.kind == "Constant" then
      item.name = string.format("@%s", item.name)
    end
  end,
}

M.markdown = {
  get_parent = function(stack, match, node)
    local level_node = (utils.get_at_path(match, "level") or {}).node
    -- Parse the level out of e.g. atx_h1_marker
    local level = tonumber(string.match(level_node:type(), "%d")) - 1
    for i = #stack, 1, -1 do
      if stack[i].item.level < level or stack[i].node == node then
        return stack[i].item, stack[i].node, level
      else
        table.remove(stack, i)
      end
    end
    return nil, nil, level
  end,
  postprocess = function(bufnr, item, match)
    -- Strip leading whitespace
    item.name = string.gsub(item.name, "^%s*", "")
    return true
  end,
  postprocess_symbols = function(bufnr, items)
    set_end_range(bufnr, items)
  end,
}

M.go = {
  postprocess = function(bufnr, item, match)
    local receiver = (utils.get_at_path(match, "receiver") or {}).node
    if receiver then
      local receiver_text = get_node_text(receiver, bufnr) or "<parse error>"
      item.name = string.format("%s %s", receiver_text, item.name)
    end
    return true
  end,
}

M.help = {
  _get_level = function(node)
    local level_str = node:type():match("^h(%d+)$")
    if level_str then
      return tonumber(level_str)
    else
      return 99
    end
  end,
  get_parent = function(stack, match, node)
    -- Fix the symbol nesting
    local level = M.help._get_level(node)
    for i = #stack, 1, -1 do
      local last = stack[i]
      if M.help._get_level(last.node) < level then
        return last.item, last.node, i
      else
        table.remove(stack, i)
      end
    end
    return nil, nil, 0
  end,
  postprocess = function(bufnr, item, match)
    -- The name node of headers only captures the final node.
    -- We need to get _all_ word nodes
    local pieces = {}
    local node = match.name.node
    if vim.startswith(match.type.node:type(), "h") then
      while node and node:type() == "word" do
        local row, col = node:start()
        table.insert(pieces, 1, get_node_text(node, bufnr))
        node = node:prev_sibling()
        item.lnum = row + 1
        item.col = col
        if item.selection_range then
          item.selection_range.lnum = row + 1
          item.selection_range.col = col
        end
      end
      item.name = table.concat(pieces, " ")
    end
  end,
  postprocess_symbols = function(bufnr, items)
    -- Sometimes helpfiles have a bunch of tags at the top in the same line. Collapse them.
    while #items > 1 and items[1].lnum == items[2].lnum do
      table.remove(items, 2)
    end
    -- Remove the first tag under a header IF that tag appears on the same line
    for _, item in ipairs(items) do
      if item.children and item.children[1] then
        local child = item.children[1]
        if child.lnum == item.lnum then
          table.remove(item.children, 1)
        end
        M.help.postprocess_symbols(bufnr, item.children)
      end
    end
  end,
}
M.vimdoc = M.help

M.rust = {
  postprocess = function(bufnr, item, match)
    if item.kind == "Class" then
      local trait_node = (utils.get_at_path(match, "trait") or {}).node
      local type = (utils.get_at_path(match, "rust_type") or {}).node
      local name = get_node_text(type, bufnr) or "<parse error>"
      if trait_node then
        local trait = get_node_text(trait_node, bufnr) or "<parse error>"
        name = string.format("%s > %s", name, trait)
      end
      item.name = name
    end
  end,
}

M.ruby = {
  postprocess = function(bufnr, item, match)
    local method = (utils.get_at_path(match, "method") or {}).node
    if method then
      local fn = get_node_text(method, bufnr) or "<parse error>"
      if fn ~= item.name then
        item.name = fn .. " " .. item.name
      end
    end
  end,
}

M.lua = {
  postprocess = function(bufnr, item, match)
    local method = (utils.get_at_path(match, "method") or {}).node
    if method then
      local fn = get_node_text(method, bufnr) or "<parse error>"
      if fn == "it" or fn == "describe" then
        item.name = fn .. " " .. string.sub(item.name, 2, string.len(item.name) - 1)
      end
    end
  end,
}

M.javascript = {
  postprocess = function(bufnr, item, match)
    local method = (utils.get_at_path(match, "method") or {}).node
    local modifier = (utils.get_at_path(match, "modifier") or {}).node
    local string = (utils.get_at_path(match, "string") or {}).node
    if method and string then
      local fn = get_node_text(method, bufnr) or "<parse error>"
      if modifier then
        fn = fn .. "." .. (get_node_text(modifier, bufnr) or "<parse error>")
      end
      local str = get_node_text(string, bufnr) or "<parse error>"
      item.name = fn .. " " .. str
    end
  end,
}

local function c_postprocess(bufnr, item, match)
  local root = (utils.get_at_path(match, "root") or {}).node
  if root then
    while
      root
      and not vim.tbl_contains({
        "identifier",
        "field_identifier",
        "qualified_identifier",
        "destructor_name",
        "operator_name",
      }, root:type())
    do
      -- Search the declarator downwards until you hit the identifier
      local next = root:field("declarator")[1]
      if next ~= nil then
        root = next
      else
        break
      end
    end
    item.name = get_node_text(root, bufnr) or "<parse error>"
    if config.treesitter.experimental_selection_range and not item.selection_range then
      item.selection_range = helpers.range_from_nodes(root, root)
    end
  end
end

M.c = {
  postprocess = c_postprocess,
}
M.cpp = {
  postprocess = c_postprocess,
}

M.rst = {
  postprocess_symbols = function(bufnr, items)
    set_end_range(bufnr, items)
  end,
}

M.typescript = {
  postprocess = function(bufnr, item, match)
    local value_node = (utils.get_at_path(match, "var_type") or {}).node
    if value_node then
      if value_node:type() == "arrow_function" then
        item.kind = "Function"
      end
    end
    local method = (utils.get_at_path(match, "method") or {}).node
    local modifier = (utils.get_at_path(match, "modifier") or {}).node
    local string = (utils.get_at_path(match, "string") or {}).node
    if method and string then
      local fn = get_node_text(method, bufnr) or "<parse error>"
      if modifier then
        fn = fn .. "." .. (get_node_text(modifier, bufnr) or "<parse error>")
      end
      local str = get_node_text(string, bufnr) or "<parse error>"
      item.name = fn .. " " .. str
    end
  end,
}

M.latex = {
  postprocess = function(bufnr, item, match)
    local type_node = (utils.get_at_path(match, "type") or {}).node
    local base_type = type_node:type()
    if base_type == "title_declaration" then
      item.name = "Title: " .. item.name
    elseif base_type == "author_declaration" then
      item.name = "Authors: " .. item.name
    end
  end,
}

-- tsx needs the same transformations as typescript for now.
-- This may not always be the case.
M.tsx = M.typescript

for _, lang in pairs(M) do
  setmetatable(lang, { __index = default_methods })
end

return M
