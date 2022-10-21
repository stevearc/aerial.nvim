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
  require("aerial").next(-1 * params.count)
end

M.next_up = function(params)
  require("aerial").up(1, params.count)
end

M.prev_up = function(params)
  require("aerial").up(-1, params.count)
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
  require("aerial").tree_cmd("open", { recurse = params.bang })
end

M.tree_close = function(params)
  require("aerial").tree_cmd("close", { recurse = params.bang })
end

M.tree_toggle = function(params)
  require("aerial").tree_cmd("toggle", { recurse = params.bang })
end

M.tree_open_all = function(params)
  require("aerial").tree_open_all()
end

M.tree_close_all = function(params)
  require("aerial").tree_close_all()
end

M.tree_sync_folds = function(params)
  require("aerial").tree_sync_folds()
end

M.tree_set_collapse_level = function(params)
  require("aerial").tree_set_collapse_level(0, tonumber(params.args))
end

M.info = function(params)
  require("aerial").info()
end

return M
