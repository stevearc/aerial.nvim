return {
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
}
