local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require("nvim-treesitter.utils")
local M = {}

local function default_get_parent(stack, match, node)
  for i = #stack, 1, -1 do
    local last_node = stack[i].node
    if ts_utils.is_parent(last_node, node) then
      return stack[i].item, last_node, i
    else
      table.remove(stack, i)
    end
  end
  return nil, nil, 0
end

local function default_postprocess(bufnr, item, match) end

setmetatable(M, {
  __index = function()
    return {
      get_parent = default_get_parent,
      postprocess = default_postprocess,
    }
  end,
})

M.markdown = {
  get_parent = function(stack, match, node)
    local level_node = (utils.get_at_path(match, "level") or {}).node
    -- Parse the level out of e.g. atx_h1_marker
    local level = tonumber(string.sub(level_node:type(), 6, 6)) - 1
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
}

M.rust = {
  get_parent = default_get_parent,
  postprocess = function(bufnr, item, match)
    if item.kind == "Class" then
      local trait_node = (utils.get_at_path(match, "trait") or {}).node
      local type = (utils.get_at_path(match, "rust_type") or {}).node
      local name = ts_utils.get_node_text(type, bufnr)[1] or "<parse error>"
      if trait_node then
        local trait = ts_utils.get_node_text(trait_node, bufnr)[1] or "<parse error>"
        name = string.format("%s > %s", name, trait)
      end
      item.name = name
    end
  end,
}

return M
