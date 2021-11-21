# aerial.nvim
A code outline window for skimming and quick navigation

https://user-images.githubusercontent.com/506791/122652728-18688500-d0f5-11eb-80aa-910f7e6a5f46.mp4

## Requirements
Neovim 0.5

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
  -- Jump forwards/backwards with '{' and '}'
  vim.api.nvim_buf_set_keymap(0, 'n', '{', '<cmd>AerialPrev<CR>', {})
  vim.api.nvim_buf_set_keymap(0, 'n', '}', '<cmd>AerialNext<CR>', {})
  -- Jump up the tree with '[[' or ']]'
  vim.api.nvim_buf_set_keymap(0, 'n', '[[', '<cmd>AerialPrevUp<CR>', {})
  vim.api.nvim_buf_set_keymap(0, 'n', ']]', '<cmd>AerialNextUp<CR>', {})

  -- This is a great place to set up all your other LSP mappings
end

-- Set up your LSP clients here, using the custom on_attach method
require'lspconfig'.vimls.setup{
  on_attach = custom_attach,
}
```

## Commands

Command               | arg            | description
-------               | ---            | -----------
`AerialToggle[!]`     | `left`/`right` | Open or close the aerial window. With `[!]` cursor stays in current window
`AerialOpen[!]`       | `left`/`right` | Open the aerial window. With `[!]` cursor stays in current window
`AerialClose`         |                | Close the aerial window
`AerialPrev`          | N=1            | Jump backwards N symbols
`AerialNext`          | N=1            | Jump forwards N symbols
`AerialPrevUp`        | N=1            | Jump up the tree N levels, moving backwards
`AerialNextUp`        | N=1            | Jump up the tree N levels, moving forwards
`AerialGo`            | N=1, `v`/`h`   | Jump to the Nth symbol
`AerialTreeOpen[!]`   |                | Expand tree at current location. `[!]` makes it recursive.
`AerialTreeClose[!]`  |                | Collapse tree at current location. `[!]` makes it recursive.
`AerialTreeToggle[!]` |                | Toggle tree at current location. `[!]` makes it recursive.
`AerialTreeOpenAll`   |                | Open all tree nodes
`AerialTreeCloseAll`  |                | Collapse all tree nodes
`AerialTreeSyncFolds` |                | Sync code folding with current tree state

## Options

```lua
vim.g.aerial = {
  -- Priority list of preferred backends for aerial
  backends = { "lsp", "treesitter" },

  -- Enum: persist, close, auto, global
  --   persist - aerial window will stay open until closed
  --   close   - aerial window will close when original file is no longer visible
  --   auto    - aerial window will stay open as long as there is a visible
  --             buffer to attach to
  --   global  - same as 'persist', and will always show symbols for the current buffer
  close_behavior = "auto",

  -- Set to false to remove the default keybindings for the aerial buffer
  default_bindings = true,

  -- Enum: prefer_right, prefer_left, right, left
  -- Determines the default direction to open the aerial window. The 'prefer'
  -- options will open the window in the other direction *if* there is a
  -- different buffer in the way of the preferred direction
  default_direction = "prefer_right",

  -- A list of all symbols to display. Set to false to display all symbols.
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Method",
    "Struct",
  },

  -- Enum: split_width, full_width, last, none
  -- Determines line highlighting mode when multiple buffers are visible
  highlight_mode = "split_width",

  -- When jumping to a symbol, highlight the line for this many ms
  -- Set to 0 or false to disable
  highlight_on_jump = 300,

  -- Fold code when folding the tree. Only works when manage_folds is enabled
  link_tree_to_folds = true,

  -- Fold the tree when folding code. Only works when manage_folds is enabled
  link_folds_to_tree = false,

  -- Use symbol tree for folding. Set to true or false to enable/disable
  -- 'auto' will manage folds if your previous foldmethod was 'manual'
  manage_folds = "auto",

  -- The maximum width of the aerial window
  max_width = 40,

  -- The minimum width of the aerial window.
  -- To disable dynamic resizing, set this to be equal to max_width
  min_width = 10,

  -- Set default symbol icons to use Nerd Font icons (see https://www.nerdfonts.com/)
  nerd_font = "auto",

  -- Whether to open aerial automatically when entering a buffer.
  -- Can also be specified per-filetype as a map (see below)
  open_automatic = false,

  -- If open_automatic is true, only open aerial if the source buffer is at
  -- least this long
  open_automatic_min_lines = 0,

  -- If open_automatic is true, only open aerial if there are at least this many symbols
  open_automatic_min_symbols = 0,

  -- Set to true to only open aerial at the far right/left of the editor
  -- Default behavior opens aerial relative to current window
  placement_editor_edge = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

  lsp = {
    -- Fetch document symbols when LSP diagnostics change.
    -- If you set this to false, you will need to manually fetch symbols
    diagnostics_trigger_update = true,

    -- Set to false to not update the symbols when there are LSP errors
    update_when_errors = true,
  },

  treesitter = {
    -- How long to wait after a buffer change before updating
    update_delay = 300,
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

-- backends can also be specified as a filetype map.
vim.g.aerial = {
  backends = {
    -- use underscore to specify the default behavior
    ['_']  = {'lsp', 'treesitter'},
    python = {'treesitter'},
    rust   = {'lsp'},
  }
}

-- filter_kind can also be specified as a filetype map.
vim.g.aerial = {
  filter_kind = {
    -- use underscore to specify the default behavior
    ['_']  = {"Class", "Function", "Interface", "Method", "Struct"},
    c = {"Namespace", "Function", "Struct", "Enum"}
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
The default keybindings in the aerial window. You can add your own in
`ftplugin/aerial.vim`, and remove these by setting `g:aerial_default_bindings =
0`.

Key       | Command
---       | -------
`<CR>`    | Jump to the symbol under the cursor
`<C-v>`   | Jump to the symbol in a vertical split
`<C-s>`   | Jump to the symbol in a horizontal split
`<p>`     | Scroll to the symbol (stay in aerial buffer)
`<C-j>`   | Go down one line and scroll to that symbol
`<C-k>`   | Go up one line and scroll to that symbol
`{`       | Jump to the previous symbol
`}`       | Jump to the next symbol
`[[`      | Jump up the tree, moving backwards
`]]`      | Jump up the tree, moving forwards
`q`       | Close the aerial window
`o`/`za`  | Toggle the symbol under the cursor open/closed
`O`/`zA`  | Recursive toggle the symbol under the cursor open/closed
`l`/`zo`  | Expand the symbol under the cursor
`L`/`zO`  | Recursive expand the symbol under the cursor
`h`/`zc`  | Collapse the symbol under the cursor
`H`/`zC`  | Recursive collapse the symbol under the cursor
`zM`      | Collapse all nodes in the tree
`zR`      | Expand all nodes in the tree
`zx`/`zX` | Sync code folding to the tree (useful if they get out of sync)

## Fuzzy Finding

### Telescope

If you have [telescope](https://github.com/nvim-telescope/telescope.nvim)
installed, there is an extension for fuzzy finding and jumping to symbols. It
functions similarly to the builtin `lsp_document_symbols` picker, the main
difference being that the aerial extension uses the `filter_kind` configuration
option to prefilter the results.

Load the extension with:

```lua
require('telescope').load_extension('aerial')
```

You can then begin fuzzy finding with `:Telescope aerial`

### fzf

If you have [fzf](https://github.com/junegunn/fzf.vim) installed you can trigger
fuzzy finding with `:call aerial#fzf()`. To create a mapping:
```vim
nmap <silent> <leader>ds <cmd>call aerial#fzf()<cr>
```

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

## FAQ

**Q: I accidentally opened a file into the aerial window and it looks bad. How can I prevent this from happening?**

Try installing [stickybuf](https://github.com/stevearc/stickybuf.nvim). It was designed to prevent exactly this problem.
