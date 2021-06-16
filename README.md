# aerial.nvim
A code outline window for skimming and quick navigation

![Demo image](https://user-images.githubusercontent.com/506791/94113785-46d26180-fdfc-11ea-84e5-0d8e5a9b3e8d.gif)

## Requirements
Neovim 0.5 (nightly)

It's powered by LSP, so you'll need to have that already set up and working.

## Installation
aerial.nvim works with [Pathogen](https://github.com/tpope/vim-pathogen)

```sh
cd ~/.vim/bundle/
git clone https://github.com/stevearc/aerial.nvim
```

and [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'stevearc/aerial.nvim'
```

## Configuration

Step one is to get a Neovim LSP set up, which is beyond the scope of this guide.
See [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for instructions.

After you have a functioning LSP setup, you will need to customize the
`on_attach` callback.

```lua
local aerial = require'aerial'

local custom_attach = function(client)
  aerial.on_attach(client)

  -- Aerial does not set any mappings by default, so you'll want to set some up
  local mapper = function(mode, key, result)
    vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
  end
  -- Toggle the aerial window with <leader>a
  mapper('n', '<leader>a', '<cmd>lua require"aerial".toggle()<CR>')
  -- Jump forwards/backwards with '[[' and ']]'
  mapper('n', '[[', '<cmd>lua require"aerial".prev_item()<CR>zvzz')
  mapper('v', '[[', '<cmd>lua require"aerial".prev_item()<CR>zvzz')
  mapper('n', ']]', '<cmd>lua require"aerial".next_item()<CR>zvzz')
  mapper('v', ']]', '<cmd>lua require"aerial".next_item()<CR>zvzz')

  -- This is a great place to set up all your other LSP mappings
end

-- Set up your LSP clients here, using the custom on_attach method
require'lspconfig'.vimls.setup{
  on_attach = custom_attach,
}
```

A full list of commands and options can be found [in the
docs](https://github.com/stevearc/aerial.nvim/blob/master/doc/aerial.txt)
