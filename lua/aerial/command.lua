local M = {}

M.toggle = function(params)
  local direction
  if params.args ~= "" then
    direction = params.args
  end
  require("aerial").toggle({
    focus = not params.bang,
    direction = direction,
  })
end

M.open = function(params)
  local direction
  if params.args ~= "" then
    direction = params.args
  end
  require("aerial").open({
    focus = not params.bang,
    direction = direction,
  })
end

M.open_all = function(params)
  require("aerial").open_all()
end

M.close = function(params)
  require("aerial").close()
end

M.close_all = function(params)
  require("aerial").close_all()
end

M.close_all_but_current = function(params)
  require("aerial").close_all_but_current()
end

M.next = function(params)
  require("aerial").next(params.count)
end

M.prev = function(params)
  require("aerial").prev(params.count)
end

M.next_up = function(params)
  require("aerial").next_up(params.count)
end

M.prev_up = function(params)
  require("aerial").prev_up(params.count)
end

M.go = function(params)
  local opts = {
    jump = not params.bang,
    index = params.count,
    split = params.args,
  }
  require("aerial").select(opts)
end

M.tree_open = function(params)
  require("aerial").tree_open({ recurse = params.bang })
end

M.tree_close = function(params)
  require("aerial").tree_close({ recurse = params.bang })
end

M.tree_toggle = function(params)
  require("aerial").tree_toggle({ recurse = params.bang })
end

M.tree_open_all = function(params)
  require("aerial").tree_open_all()
end

M.tree_close_all = function(params)
  require("aerial").tree_close_all()
end

M.tree_sync_folds = function(params)
  require("aerial").sync_folds()
end

M.tree_set_collapse_level = function(params)
  require("aerial").tree_set_collapse_level(0, tonumber(params.args))
end

M.info = function(params)
  local data = require("aerial").info()
  print("Aerial Info")
  print("-----------")
  print(string.format("Filetype: %s", data.filetype))
  if data.ignore.ignored then
    print(
      string.format(
        "Aerial ignores this window: %s. See the 'ignore' config in :help aerial-options",
        data.ignore.message
      )
    )
  end
  print("Configured backends:")
  for _, status in ipairs(data.backends) do
    local line = "  " .. status.name
    if status.supported then
      line = line .. " (supported)"
    else
      line = line .. " (not supported) [" .. status.error .. "]"
    end
    if status.attached then
      line = line .. " (attached)"
    end
    print(line)
  end
  print(string.format("Show symbols: %s", data.filter_kind_map))
end

M.nav_toggle = function()
  require("aerial.nav_view").toggle()
end

M.nav_open = function()
  require("aerial.nav_view").open()
end

M.nav_close = function()
  require("aerial.nav_view").close()
end

return M
