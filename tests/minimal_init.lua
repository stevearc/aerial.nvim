vim.cmd([[set runtimepath+=.]])

vim.o.swapfile = false
vim.bo.swapfile = false
vim.filetype.add({
  extension = {
    norg = "norg", -- Neovim doesn't have built-in norg filetype detection
    usd = "usd", -- Neovim doesn't have built-in USD filetype detection
    usda = "usd", -- Neovim doesn't have built-in USD filetype detection
    smk = "snakemake", -- Neovim doesn't have built-in Snakemake filetype detection
  },
})

local langs = {}
for lang, _ in vim.fs.dir("queries") do
  -- "help" has been renamed to "vimdoc"
  if lang ~= "help" then
    table.insert(langs, lang)
  end
end
require("nvim-treesitter.configs").setup({
  ensure_installed = langs,
  sync_install = true,
})
-- this needs to be run a second time to make tests behave
require("nvim-treesitter").setup()
