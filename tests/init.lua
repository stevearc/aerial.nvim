vim.cmd([[set runtimepath+=.]])
vim.cmd([[runtime! plugin/plenary.vim]])
vim.cmd([[runtime! plugin/nvim-treesitter.vim]])

vim.o.swapfile = false
vim.bo.swapfile = false
-- Neovim 0.5 doesn't have julia filetype detection
vim.cmd([[autocmd BufRead,BufNewFile *.jl setfiletype julia]])

require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
})
