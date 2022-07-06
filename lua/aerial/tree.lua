local M = {}

local function _get_target(bufdata, action, item, bubble)
  if not bubble then
    return item
  end
  while
    item
    and (not bufdata:is_collapsable(item) or (action == "close" and bufdata:is_collapsed(item)))
  do
    item = item.parent
  end
  return item
end

M.edit_tree_node = function(bufdata, action, index, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    bubble = true,
    recurse = false,
  })
  local did_update = false
  local function do_action(item)
    if not item or not bufdata:is_collapsable(item) then
      return
    end
    local is_collapsed = bufdata:is_collapsed(item)
    if action == "toggle" then
      action = is_collapsed and "open" or "close"
    end
    if action == "open" then
      did_update = did_update or is_collapsed
      bufdata:set_collapsed(item, false)
      if opts.recurse and item.children then
        for _, child in ipairs(item.children) do
          do_action(child)
        end
      end
      return item
    elseif action == "close" then
      did_update = did_update or not is_collapsed
      bufdata:set_collapsed(item, true)
      if opts.recurse and item.parent then
        return do_action(item.parent)
      end
      return item
    else
      error(string.format("Unknown action '%s'", action))
    end
  end
  local current_item = bufdata:item(index)
  local target = _get_target(bufdata, action, current_item, opts.bubble)
  local item = do_action(target)
  return did_update, bufdata:indexof(item)
end

return M
