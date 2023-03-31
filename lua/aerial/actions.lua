local aerial = require("aerial")

local M = {}

M.show_help = {
  desc = "Show default keymaps",
  callback = function()
    local config = require("aerial.config")
    require("aerial.keymap_util").show_help("aerial.actions", config.keymaps)
  end,
}

M.jump = {
  desc = "Jump to the symbol under the cursor",
  callback = aerial.select,
}

M.jump_vsplit = {
  desc = "Jump to the symbol in a vertical split",
  callback = function()
    aerial.select({ split = "v" })
  end,
}

M.jump_split = {
  desc = "Jump to the symbol in a horizontal split",
  callback = function()
    aerial.select({ split = "h" })
  end,
}

M.scroll = {
  desc = "Scroll to the symbol (stay in aerial buffer)",
  callback = function()
    aerial.select({ jump = false })
  end,
}

M.down_and_scroll = {
  desc = "Go down one line and scroll to that symbol",
  callback = function()
    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] + 1
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    aerial.select({ jump = false })
  end,
}

M.up_and_scroll = {
  desc = "Go up one line and scroll to that symbol",
  callback = function()
    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] - 1
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    aerial.select({ jump = false })
  end,
}

M.prev = {
  desc = "Jump to the previous symbol",
  callback = aerial.prev,
}

M.next = {
  desc = "Jump to the next symbol",
  callback = aerial.next,
}

M.prev_up = {
  desc = "Jump up the tree, moving backwards in the file",
  callback = aerial.prev_up,
}

M.next_up = {
  desc = "Jump up the tree, moving forwards in the file",
  callback = aerial.next_up,
}

M.close = {
  desc = "Close the aerial window",
  callback = function()
    local source_win = require("aerial.util").get_winids(0)
    if source_win then
      vim.api.nvim_set_current_win(source_win)
    end
    aerial.close()
  end,
}

M.tree_toggle = {
  desc = "Toggle the symbol under the cursor open/closed",
  callback = aerial.tree_toggle,
}

M.tree_toggle_recursive = {
  desc = "Recursively toggle the symbol under the cursor open/closed",
  callback = function()
    aerial.tree_toggle({ recursive = true })
  end,
}

M.tree_open = {
  desc = "Expand the symbol under the cursor",
  callback = aerial.tree_open,
}

M.tree_open_recursive = {
  desc = "Recursively expand the symbol under the cursor",
  callback = function()
    aerial.tree_open({ recursive = true })
  end,
}

M.tree_close = {
  desc = "Collapse the symbol under the cursor",
  callback = aerial.tree_close,
}

M.tree_close_recursive = {
  desc = "Recursively collapse the symbol under the cursor",
  callback = function()
    aerial.tree_close({ recursive = true })
  end,
}

M.tree_increase_fold_level = {
  desc = "Increase the fold level of the tree",
  callback = function()
    aerial.tree_increase_fold_level(0, vim.v.count)
  end,
}

M.tree_decrease_fold_level = {
  desc = "Decrease the fold level of the tree",
  callback = function(params)
    aerial.tree_decrease_fold_level(0, vim.v.count)
  end,
}

M.tree_open_all = {
  desc = "Expand all nodes in the tree",
  callback = aerial.tree_open_all,
}

M.tree_close_all = {
  desc = "Collapse all nodes in the tree",
  callback = aerial.tree_close_all,
}

M.tree_sync_folds = {
  desc = "Sync code folding to the tree (useful if they get out of sync)",
  callback = aerial.tree_sync_folds,
}

return M
