# aerial.nvim
Show a table-of-contents pane next to your code for quick navigation

TODO: screenshots

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
    vim.fn.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
  end
  -- Toggle the aerial pane with <leader>a
  mapper('n', '<leader>a', '<cmd>lua require"aerial".toggle()<CR>')
  -- Jump forwards/backwards with '[[' and ']]'
  mapper('n', '[[', '<cmd>lua require"aerial".prev_item()<CR>zzzv')
  mapper('v', '[[', '<cmd>lua require"aerial".prev_item()<CR>zzzv')
  mapper('n', ']]', '<cmd>lua require"aerial".next_item()<CR>zzzv')
  mapper('v', ']]', '<cmd>lua require"aerial".next_item()<CR>zzzv')

  -- This is a great place to set up all your other LSP mappings
end

-- Set up your LSP clients here, using the custom on_attach method
require'nvim_lsp'.vimls.setup{
  on_attach = custom_attach,
}
```

A full list of commands and options can be found [in the
docs](https://github.com/stevearc/aerial.nvim/blob/master/doc/aerial.txt)
