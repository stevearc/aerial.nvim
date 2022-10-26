vim.cmd([[set runtimepath+=.]])
-- Force load the nvim-treesitter query predicates
require("nvim-treesitter.query_predicates")

vim.o.swapfile = false
vim.bo.swapfile = false
-- Neovim 0.5 doesn't have julia filetype detection
vim.cmd([[autocmd BufRead,BufNewFile *.jl setfiletype julia]])
-- Neovim below 0.7 doesn't have org filetype detection
vim.cmd([[autocmd BufRead,BufNewFile *.org setfiletype org]])
-- Neovim doesn't have built-in norg filetype detection
vim.cmd([[autocmd BufRead,BufNewFile *.norg setfiletype norg]])

local langs = {}
for lang, _ in vim.fs.dir("queries") do
  table.insert(langs, lang)
end
require("nvim-treesitter.configs").setup({
  ensure_installed = langs,
  sync_install = true,
})
