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

local langs = {}
for lang, _ in vim.fs.dir("queries") do
  -- "help" has been renamed to "vimdoc"
  if lang ~= "help" then
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
  -- Use compiler that includes c++14 features by default
  -- If `cc` doesn't implement those, override it for tests run with
  -- `CC=gcc-13 ./run_tests.sh`
  local parser_config = require("nvim-treesitter.parsers").configs
  parser_config.norg = {
    install_info = {
      url = "https://github.com/nvim-neorg/tree-sitter-norg",
      files = { "src/parser.c", "src/scanner.cc" },
      branch = "main",
    },
    tier = 3,
  }

  vim.api.nvim_create_user_command("RunTests", function(opts)
    local path = opts.fargs[1] or "tests"
    require("nvim-treesitter.install").install(langs, { skip = { installed = true } }, function()
      vim.schedule(function()
        require("plenary.test_harness").test_directory(
          path,
          -- nvim-treesitter `main` sets up some useful filetype mappings
          -- as a plugin, which doesn't get executed by plenary buster
          -- when running with `minimal_init`
          --
          -- While this can be circumvented by setting all the associations
          -- in the init, for some reason they don't get picked up by the
          -- time a spec gets executed, leading to false negatives
          { init = "./tests/minimal_init.lua" }
        )
      end)
    end)
  end, { nargs = "?" })
end
