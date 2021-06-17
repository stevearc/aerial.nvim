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

## Setup

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
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>a', '<cmd>AerialToggle!<CR>', {})
  -- Jump forwards/backwards with '[[' and ']]'
  vim.api.nvim_buf_set_keymap(0, 'n', '[[', '<cmd>AerialPrev<CR>', {})
  vim.api.nvim_buf_set_keymap(0, 'n', ']]', '<cmd>AerialNext<CR>', {})

  -- This is a great place to set up all your other LSP mappings
end

-- Set up your LSP clients here, using the custom on_attach method
require'lspconfig'.vimls.setup{
  on_attach = custom_attach,
}
```

## Commands

Command         | arg            | description
-------         | ---            | -----------
`AerialToggle`  | `left`/`right` | Open (and enter) or close the aerial window
`AerialToggle!` | `left`/`right` | Open or close the aerial window
`AerialOpen`    | `left`/`right` | Open (and enter) the aerial window
`AerialOpen!`   | `left`/`right` | Open the aerial window
`AerialClose`   |                | Close the aerial window
`AerialPrev`    | N=1            | Jump backwards N symbols
`AerialNext`    | N=1            | Jump forwards N symbols
`AerialGo`      | N=1, `v`/`h`   | Jump to the Nth symbol

## Options

```lua
vim.g.aerial = {
  -- Enum: persist, close, auto
  --   persist - aerial window will stay open until closed
  --   close   - aerial window will close when original file is no longer visible
  --   auto    - aerial window will stay open as long as there is a visible
  --             buffer to attach to
  close_behavior = 'auto',
  -- Enum: prefer_right, prefer_left, right, left
  -- Determines the default direction to open the aerial window. The 'prefer'
  -- options will open the window in the other direction *if* there is a
  -- different buffer in the way of the preferred direction
  default_direction = 'prefer_right',
  -- Fetch document symbols when LSP diagnostics change.
  -- If you set this to false, you will need to manually fetch symbols
  diagnostics_trigger_update = true,
  -- Enum: split_width, full_width, last, none
  -- Determines line highlighting mode when multiple buffers are visible
  highlight_mode = 'split_width',
  -- When jumping to a symbol, highlight the line for this many ms
  -- Set to 0 or false to disable
  highlight_on_jump = 300,
  -- The maximum width of the aerial window
  max_width = 40,
  -- The minimum width of the aerial window.
  -- To disable dynamic resizing, set this to be equal to max_width
  min_width = 10,
  -- Set default symbol icons to use Nerd Font icons (see https://www.nerdfonts.com/)
  nerd_font = 'auto',
  -- Whether to open aerial automatically when entering a buffer.
  -- Can also be specified per-filetype as a map (see below)
  open_automatic = false,
  -- If open_automatic is true, only open aerial if the source buffer is at
  -- least this long
  open_automatic_min_lines = 0,
  -- If open_automatic is true, only open aerial if there are at least this many symbols
  open_automatic_min_symbols = 0,
  -- Run this command after jumping to a symbol ('' will disable)
  post_jump_cmd = 'normal! zvzz',
  -- Set to false to not update the symbols when there are LSP errors
  update_when_errors = true,
  -- A list of all symbols to display
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Method",
    "Struct",
  },
}

-- open_automatic can be specified as a filetype map. For example, the below
-- configuration will open automatically in all filetypes except python and rust
vim.g.aerial = {
  open_automatic = {
    -- use underscore to specify the default behavior
    ['_']  = true,
    python = false,
    rust   = false,
  }
}

-- You can also override the default icons.
vim.g.aerial = {
  icons = {
    Class          = '';
    -- The icon to use when a class has been collapsed in the tree
    ClassCollapsed = '喇';
    Function       = '';
    Constant       = '[c]'
    -- The default icon to use when any symbol is collapsed in the tree
    Collapsed      = '▶';
  }
}
```

Setting options in vimscript works the same way
```vim
" You can specify with global variables prefixed with 'aerial_'
let g:aerial_default_direction = 'left'
" Or you can set the g:aerial dict all at once
let g:aerial = {
  \ 'default_direction': 'left',
\}
```

All possible SymbolKind values can be found [in the LSP
spec](https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#symbolKind).
These are the values used for configuring icons, highlight groups, and
filtering.

## Default Keybindings
The default keybindings in the aerial window are 

Key     | Command
---     | -------
`<CR>`  | Jump to the symbol under the cursor
`<C-v>` | Jump to the symbol in a vertical split
`<C-s>` | Jump to the symbol in a horizontal split
`<p>`   | Scroll to the symbol (stay in aerial buffer)
`<C-j>` | Go down one line and scroll to that symbol
`<C-k>` | Go up one line and scroll to that symbol
`[[`    | Jump to the previous symbol
`]]`    | Jump to the next symbol
`q`     | Close the aerial window
`o`     | Toggle the tree
`O`     | Toggle the tree recursively

## Highlight

There are highlight groups created for each `SymbolKind`. There will be one for
the name of the symbol (`Aerial<SymbolKind>`, and one for the icon
(`Aerial<SymbolKind>Icon`). For example:

```vim
hi link AerialClass Type
hi link AerialClassIcon Special
hi link AerialFunction Special
hi AerialFunctionIcon guifg=#cb4b16 guibg=NONE guisp=NONE gui=NONE cterm=NONE

" There's also this group for the cursor position
hi link AerialLine QuickFixLine
```
