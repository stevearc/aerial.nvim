vim.cmd([[set runtimepath+=.]])

vim.o.swapfile = false
vim.bo.swapfile = false
vim.filetype.add({
  -- Neovim doesn't have built-in filetype detection for these filetypes
  extension = {
    just = "just",
    norg = "norg",
    objdump = "objdump",
    usd = "usd",
    usda = "usd",
    smk = "snakemake",
    dj = "djot",
    nu = "nu",
  },
})

local orgmode_ok, orgmode = pcall(require, "orgmode")
if orgmode_ok then
  pcall(orgmode.setup)
end

local skip_lang_install = {
  help = true, -- "help" has been renamed to "vimdoc"
  org = true, -- "org" is provided by a dedicated plugin.
}

local langs = {}
for lang, _ in vim.fs.dir("queries") do
  if not skip_lang_install[lang] then
    table.insert(langs, lang)
  end
end
local master_nvim_ts, configs = pcall(require, "nvim-treesitter.configs")
if master_nvim_ts then
  ---@diagnostic disable-next-line: missing-fields
  configs.setup({
    ensure_installed = langs,
    sync_install = true,
  })
  -- this needs to be run a second time to make tests behave
  require("nvim-treesitter").setup()

  vim.api.nvim_create_user_command("RunTests", function(opts)
    local path = opts.fargs[1] or "tests"
    require("plenary.test_harness").test_directory(
      path,
      { minimal_init = "./tests/minimal_init.lua" }
    )
  end, { nargs = "?" })
else
  require("nvim-treesitter").install(langs):wait(60000)

  vim.api.nvim_create_user_command("RunTests", function(opts)
    local path = opts.fargs[1] or "tests"
    require("plenary.test_harness").test_directory(path, { init = "./tests/minimal_init.lua" })
  end, { nargs = "?" })
end
