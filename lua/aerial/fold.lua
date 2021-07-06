local config = require("aerial.config")
local data = require("aerial.data")
local util = require("aerial.util")
local M = {}

M.foldexpr = function(lnum, debug)
  if util.is_aerial_buffer() then
    return "0"
  end
  if not data:has_symbols(0) then
    return "0"
  end
  local bufdata = data[0]
  local lastItem = {}
  local foldItem = { level = -1 }
  bufdata:visit(function(item)
    lastItem = item
    if item.lnum > lnum then
      return true
    elseif bufdata:is_collapsable(item) then
      foldItem = item
    end
  end, {
    incl_hidden = true,
  })
  local levelstr = string.format("%d", foldItem.level + 1)
  if lnum == foldItem.lnum then
    levelstr = ">" .. levelstr
  elseif vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1] == "" then
    levelstr = "-1"
  end

  if debug then
    levelstr = string.format("%s %s:%d:%d", levelstr, lastItem.name, lastItem.level, lastItem.lnum)
  end
  return levelstr
end

local prev_fdm = "_aerial_prev_foldmethod"
local prev_fde = "_aerial_prev_foldexpr"
M.restore_foldmethod = function()
  local ok, prev_foldmethod = pcall(vim.api.nvim_win_get_var, 0, prev_fdm)
  if ok and prev_foldmethod then
    vim.api.nvim_win_del_var(0, prev_fdm)
    vim.wo.foldmethod = prev_foldmethod
  end
  local ok2, prev_foldexpr = pcall(vim.api.nvim_win_get_var, 0, prev_fde)
  if ok2 and prev_foldexpr then
    vim.api.nvim_win_del_var(0, prev_fde)
    vim.wo.foldexpr = prev_foldexpr
  end
end

M.maybe_set_foldmethod = function(bufnr)
  local manage_folds = config.manage_folds
  if not manage_folds then
    return
  end
  if not data:has_symbols(bufnr) then
    return
  end
  local winids
  if bufnr then
    winids = util.get_fixed_wins(bufnr)
  else
    winids = { vim.api.nvim_get_current_win() }
  end
  for _, winid in ipairs(winids) do
    local fdm = vim.api.nvim_win_get_option(winid, "foldmethod")
    local fde = vim.api.nvim_win_get_option(winid, "foldexpr")
    if manage_folds == true or manage_folds == 1 or (manage_folds == "auto" and fdm == "manual") then
      vim.api.nvim_win_set_var(winid, prev_fdm, fdm)
      vim.api.nvim_win_set_var(winid, prev_fde, fde)
      vim.api.nvim_win_set_option(winid, "foldmethod", "expr")
      vim.api.nvim_win_set_option(winid, "foldexpr", "aerial#foldexpr()")
    end
  end
end

M.sync_tree_folds = function(winid)
  if not util.is_managing_folds(winid) then
    return
  end
  util.go_win_no_au(winid)
  local view = vim.fn.winsaveview()
  vim.cmd("normal! zxzR")
  local bufdata = data[0]
  local items = bufdata:flatten(nil, { incl_hidden = true })
  table.sort(items, function(a, b)
    return a.level > b.level
  end)
  for _, item in ipairs(items) do
    if bufdata:is_collapsed(item) then
      vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
      vim.cmd("normal! zc")
    end
  end

  vim.fn.winrestview(view)
end

local function win_do_action(winid, action, lnum, recurse)
  util.go_win_no_au(winid)
  if vim.fn.foldlevel(lnum) == 0 then
    M.sync_tree_folds(winid)
  end
  if vim.fn.foldlevel(lnum) == 0 then
    return
  end
  local view = vim.fn.winsaveview()
  vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  local key
  if action == "open" then
    key = "o"
  elseif action == "close" then
    key = "c"
  elseif action == "toggle" then
    key = "a"
  end
  if key and recurse then
    key = string.upper(key)
  end
  if key then
    vim.cmd("normal! z" .. key)
  end
  vim.fn.winrestview(view)
end

M.fold_action = function(action, lnum, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    recurse = false,
  })
  local my_winid = vim.api.nvim_get_current_win()
  local wins
  local bufnr, _ = util.get_buffers()
  wins = util.get_fixed_wins(bufnr)
  for _, winid in ipairs(wins) do
    if util.is_managing_folds(winid) then
      win_do_action(winid, action, lnum, opts.recurse)
    end
  end
  util.go_win_no_au(my_winid)
end

return M
