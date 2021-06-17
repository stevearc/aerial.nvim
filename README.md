# aerial.nvim
A code outline window for skimming and quick navigation

![Screenshot from 2021-06-16 19-05-43](https://user-images.githubusercontent.com/506791/122320750-9cddbc80-ced7-11eb-937e-90eed107f94e.png)
![Screenshot from 2021-06-16 19-17-00](https://user-images.githubusercontent.com/506791/122320760-9ea78000-ced7-11eb-8982-3d051992e91f.png)

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
  -- Toggle the aerial window with <leader>a
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>a', '<cmd>lua require"aerial".toggle()<CR>', {})
  -- Jump forwards/backwards with '[[' and ']]'
  vim.api.nvim_buf_set_keymap(0, 'n', '[[', '<cmd>lua require"aerial".prev_item()<CR>zvzz', {})
  vim.api.nvim_buf_set_keymap(0, 'v', '[[', '<cmd>lua require"aerial".prev_item()<CR>zvzz', {})
  vim.api.nvim_buf_set_keymap(0, 'n', ']]', '<cmd>lua require"aerial".next_item()<CR>zvzz', {})
  vim.api.nvim_buf_set_keymap(0, 'v', ']]', '<cmd>lua require"aerial".next_item()<CR>zvzz', {})

  -- This is a great place to set up all your other LSP mappings
end

-- Set up your LSP clients here, using the custom on_attach method
require'lspconfig'.vimls.setup{
  on_attach = custom_attach,
}
```

A full list of commands and options can be found [in the
docs](https://github.com/stevearc/aerial.nvim/blob/master/doc/aerial.txt)

The default keybindings in the aerial window are [in the
ftplugin](https://github.com/stevearc/aerial.nvim/blob/master/ftplugin/aerial.vim)
