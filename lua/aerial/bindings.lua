local util = require("aerial.util")
local M = {}

M.keys = {
  { { "?", "g?" }, "<cmd>lua require'aerial.bindings'.show()<CR>", "Show default keymaps" },
  { "<CR>", "<cmd>lua require'aerial'.select()<CR>", "Jump to the symbol under the cursor" },
  {
    "<C-v>",
    "<cmd>lua require'aerial'.select({split='v'})<CR>",
    "Jump to the symbol in a vertical split",
  },
  {
    "<C-s>",
    "<cmd>lua require'aerial'.select({split='h'})<CR>",
    "Jump to the symbol in a horizontal split",
  },
  {
    "p",
    "<cmd>lua require'aerial'.select({jump=false})<CR>",
    "Scroll to the symbol (stay in aerial buffer)",
  },
  {
    "<C-j>",
    "j<cmd>lua require'aerial'.select({jump=false})<CR>",
    "Go down one line and scroll to that symbol",
  },
  {
    "<C-k>",
    "k<cmd>lua require'aerial'.select({jump=false})<CR>",
    "Go up one line and scroll to that symbol",
  },
  { "{", "<cmd>AerialPrev<CR>", "Jump to the previous symbol" },
  { "}", "<cmd>AerialNext<CR>", "Jump to the next symbol" },
  { "[[", "<cmd>AerialPrevUp<CR>", "Jump up the tree, moving backwards" },
  { "]]", "<cmd>AerialNextUp<CR>", "Jump up the tree, moving forwards" },
  { "q", "<cmd>AerialClose<CR>", "Close the aerial window" },
  {
    { "o", "za" },
    "<cmd>AerialTreeToggle<CR>",
    "Toggle the symbol under the cursor open/closed",
  },
  {
    { "O", "zA" },
    "<cmd>AerialTreeToggle!<CR>",
    "Recursive toggle the symbol under the cursor open/closed",
  },
  { { "l", "zo" }, "<cmd>AerialTreeOpen<CR>", "Expand the symbol under the cursor" },
  { { "L", "zO" }, "<cmd>AerialTreeOpen!<CR>", "Recursive expand the symbol under the cursor" },
  { { "h", "zc" }, "<cmd>AerialTreeClose<CR>", "Collapse the symbol under the cursor" },
  {
    { "H", "zC" },
    "<cmd>AerialTreeClose!<CR>",
    "Recursive collapse the symbol under the cursor",
  },
  { "zR", "<cmd>AerialTreeOpenAll<CR>", "Expand all nodes in the tree" },
  { "zM", "<cmd>AerialTreeCloseAll<CR>", "Collapse all nodes in the tree" },
  {
    { "zx", "zX" },
    "<cmd>AerialTreeSyncFolds<CR>",
    "Sync code folding to the tree (useful if they get out of sync)",
  },
  {
    "<2-LeftMouse>",
    "<cmd>lua require'aerial'.select()<CR>",
    "Jump to the symbol under the cursor",
  },
}

M.show = function()
  local lhs = {}
  local rhs = {}
  local max_left = 1
  for _, binding in ipairs(M.keys) do
    local keys, _, desc = unpack(binding)
    if type(keys) ~= "table" then
      keys = { keys }
    end
    local keystr = table.concat(keys, "/")
    max_left = math.max(max_left, vim.api.nvim_strwidth(keystr))
    table.insert(lhs, keystr)
    table.insert(rhs, desc)
  end

  local lines = {}
  local max_line = 1
  for i = 1, #lhs do
    local left = lhs[i]
    local right = rhs[i]
    local line = string.format(" %s   %s", util.rpad(left, max_left), right)
    max_line = math.max(max_line, vim.api.nvim_strwidth(line))
    table.insert(lines, line)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  local ns = vim.api.nvim_create_namespace("AerialKeymap")
  for i = 1, #lhs do
    vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
      end_col = max_left + 1,
      hl_group = "Special",
    })
  end
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<c-c>", "<cmd>close<CR>", opts)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight
  vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = math.max(0, (editor_height - #lines) / 2),
    col = math.max(0, (editor_width - max_line - 1) / 2),
    width = math.min(editor_width, max_line + 1),
    height = math.min(editor_height, #lines),
    zindex = 150,
    style = "minimal",
    border = "rounded",
  })
end

return M
