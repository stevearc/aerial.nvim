# aerial.nvim

A code outline window for skimming and quick navigation

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
  - [Treesitter](#treesitter)
  - [LSP](#lsp)
  - [Markdown](#markdown)
  - [Keymaps](#keymaps)
- [Commands](#commands)
- [Options](#options)
- [Default keybindings](#default-keybindings)
- [Third-party integrations](#third-party-integrations)
  - [Telescope](#telescope)
  - [Fzf](#fzf)
  - [Lualine](#lualine)
- [Highlight](#highlight)
- [FAQ](#faq)

https://user-images.githubusercontent.com/506791/122652728-18688500-d0f5-11eb-80aa-910f7e6a5f46.mp4

## Requirements

- Neovim 0.5+ for LSP symbols, 0.7+ for treesitter symbols
- One or more of the following:
  - A working LSP setup (see [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig))
  - [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with languages installed

## Installation

aerial supports all the usual plugin managers

<details>
  <summary>Packer</summary>

```lua
require('packer').startup(function()
    use {
      'stevearc/aerial.nvim',
      config = function() require('aerial').setup() end
    }
end)
```

</details>

<details>
  <summary>Paq</summary>

```lua
require "paq" {
    {'stevearc/aerial.nvim'};
}
```

</details>

<details>
  <summary>vim-plug</summary>

```vim
Plug 'stevearc/aerial.nvim'
```

</details>

<details>
  <summary>dein</summary>

```vim
call dein#add('stevearc/aerial.nvim')
```

</details>

<details>
  <summary>Pathogen</summary>

```sh
git clone --depth=1 https://github.com/stevearc/aerial.nvim.git ~/.vim/bundle/
```

</details>

<details>
  <summary>Neovim native package</summary>

```sh
git clone --depth=1 https://github.com/stevearc/aerial.nvim.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/aerial/start/aerial.nvim
```

</details>

## Setup

Somewhere in your init.lua you will need to call `aerial.setup()`. See below for
[a full list of options](#options).

```lua
require('aerial').setup({})
```

In addition, you will need to follow the setup steps for at least one of the
symbol sources listed below. You can configure your preferred source(s) with the
`backends` option (see [Options](#options)). The default is to prefer Treesitter
when it's available and fall back to LSP.

### Treesitter

First ensure you have
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) installed
and configured for all languages you want to support. That's all! Aerial will
automatically fetch symbols from treesitter.

<details>
  <summary>Supported languages</summary>

- bash
- c
- c_sharp
- cpp
- dart
- elixir
- go
- java
- javascript
- json
- julia
- lua
- make
- markdown
- norg
- org
- php
- python
- rst
- ruby
- rust
- teal
- tsx
- typescript
- vim
- yaml

Don't see your language here? [Request support for
it](https://github.com/stevearc/aerial.nvim/issues/new?assignees=stevearc&labels=enhancement&template=feature-request--treesitter-language-.md&title=)

</details>

### LSP

First ensure you have a functioning LSP setup (see
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)). Once complete, add
the aerial `on_attach` callback to your config:

```lua
-- Set up your LSP clients here, using the aerial on_attach method
require("lspconfig").vimls.setup{
  on_attach = require("aerial").on_attach,
}
-- Repeat this for each language server you have configured
```

If you have your own custom `on_attach` function, call aerial's `on_attach` from
inside it:

```lua
local function my_custom_attach(client, bufnr)
  -- your code here
  require("aerial").on_attach(client, bufnr)
end
```

### Markdown

There is a simple custom backend that does rudimentary parsing of markdown
headers. It should work well enough in most cases, but does not parse the full
markdown spec.

There is now an experimental [treesitter parser for
markdown](https://github.com/nvim-treesitter/nvim-treesitter/issues/872), so you
can install that and try the treesitter backend instead.

### Keymaps

While not required, you may want to add some keymaps for aerial. The best way to
do this is with the `on_attach` option:

```lua
require("aerial").setup({
  on_attach = function(bufnr)
    -- Toggle the aerial window with <leader>a
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>a', '<cmd>AerialToggle!<CR>', {})
    -- Jump forwards/backwards with '{' and '}'
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
    -- Jump up the tree with '[[' or ']]'
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrevUp<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNextUp<CR>', {})
  end
})
```

## Commands

| Command                      | arg                    | description                                                                |
| ---------------------------- | ---------------------- | -------------------------------------------------------------------------- |
| `AerialToggle[!]`            | `left`/`right`/`float` | Open or close the aerial window. With `[!]` cursor stays in current window |
| `AerialOpen[!]`              | `left`/`right`/`float` | Open the aerial window. With `[!]` cursor stays in current window          |
| `AerialOpenAll`              |                        | Open an aerial window for each visible window                              |
| `AerialClose`                |                        | Close the aerial window                                                    |
| `AerialCloseAll`             |                        | Close all visible aerial windows                                           |
| `AerialCloseAllButCurrent`   |                        | Close all visible aerial windows except for the focused one                |
| `AerialPrev`                 | N=1                    | Jump backwards N symbols                                                   |
| `AerialNext`                 | N=1                    | Jump forwards N symbols                                                    |
| `AerialPrevUp`               | N=1                    | Jump up the tree N levels, moving backwards                                |
| `AerialNextUp`               | N=1                    | Jump up the tree N levels, moving forwards                                 |
| `AerialGo`                   | N=1, `v`/`h`           | Jump to the Nth symbol                                                     |
| `AerialTreeOpen[!]`          |                        | Expand tree at current location. `[!]` makes it recursive.                 |
| `AerialTreeClose[!]`         |                        | Collapse tree at current location. `[!]` makes it recursive.               |
| `AerialTreeToggle[!]`        |                        | Toggle tree at current location. `[!]` makes it recursive.                 |
| `AerialTreeOpenAll`          |                        | Open all tree nodes                                                        |
| `AerialTreeCloseAll`         |                        | Collapse all tree nodes                                                    |
| `AerialTreeSetCollapseLevel` | N                      | Collapse symbols at a depth greater than N (0 collapses all)               |
| `AerialTreeSyncFolds`        |                        | Sync code folding with current tree state                                  |
| `AerialInfo`                 |                        | Print out debug info related to aerial                                     |

## Options

```lua
-- Call the setup function to change the default behavior
require("aerial").setup({
  -- Priority list of preferred backends for aerial.
  -- This can be a filetype map (see :help aerial-filetype-map)
  backends = { "treesitter", "lsp", "markdown" },

  layout = {
    -- These control the width of the aerial window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a list of mixed types.
    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
    max_width = { 40, 0.2 },
    width = nil,
    min_width = 10,

    -- Enum: prefer_right, prefer_left, right, left, float
    -- Determines the default direction to open the aerial window. The 'prefer'
    -- options will open the window in the other direction *if* there is a
    -- different buffer in the way of the preferred direction
    default_direction = "prefer_right",

    -- Enum: edge, group, window
    --   edge   - open aerial at the far right/left of the editor
    --   group  - open aerial to the right/left of the group of windows containing the current buffer
    --   window - open aerial to the right/left of the current window
    placement = "window",
  },

  -- Enum: persist, close, auto, global
  --   persist - aerial window will stay open until closed
  --   close   - aerial window will close when original file is no longer visible
  --   auto    - aerial window will stay open as long as there is a visible
  --             buffer to attach to
  --   global  - same as 'persist', and will always show symbols for the current buffer
  close_behavior = "auto",

  -- Set to false to remove the default keybindings for the aerial buffer
  default_bindings = true,

  -- Disable aerial on files with this many lines
  disable_max_lines = 10000,

  -- Disable aerial on files this size or larger (in bytes)
  disable_max_size = 2000000, -- Default 2MB

  -- A list of all symbols to display. Set to false to display all symbols.
  -- This can be a filetype map (see :help aerial-filetype-map)
  -- To see all available values, see :help SymbolKind
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Module",
    "Method",
    "Struct",
  },

  -- Enum: split_width, full_width, last, none
  -- Determines line highlighting mode when multiple splits are visible.
  -- split_width   Each open window will have its cursor location marked in the
  --               aerial buffer. Each line will only be partially highlighted
  --               to indicate which window is at that location.
  -- full_width    Each open window will have its cursor location marked as a
  --               full-width highlight in the aerial buffer.
  -- last          Only the most-recently focused window will have its location
  --               marked in the aerial buffer.
  -- none          Do not show the cursor locations in the aerial window.
  highlight_mode = "split_width",

  -- Highlight the closest symbol if the cursor is not exactly on one.
  highlight_closest = true,

  -- Highlight the symbol in the source buffer when cursor is in the aerial win
  highlight_on_hover = false,

  -- When jumping to a symbol, highlight the line for this many ms.
  -- Set to false to disable
  highlight_on_jump = 300,

  -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
  -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
  -- default collapsed icon. The default icon set is determined by the
  -- "nerd_font" option below.
  -- If you have lspkind-nvim installed, it will be the default icon set.
  -- This can be a filetype map (see :help aerial-filetype-map)
  icons = {},

  -- Control which windows and buffers aerial should ignore.
  -- If close_behavior is "global", focusing an ignored window/buffer will
  -- not cause the aerial window to update.
  -- If open_automatic is true, focusing an ignored window/buffer will not
  -- cause an aerial window to open.
  -- If open_automatic is a function, ignore rules have no effect on aerial
  -- window opening behavior; it's entirely handled by the open_automatic
  -- function.
  ignore = {
    -- Ignore unlisted buffers. See :help buflisted
    unlisted_buffers = true,

    -- List of filetypes to ignore.
    filetypes = {},

    -- Ignored buftypes.
    -- Can be one of the following:
    -- false or nil - No buftypes are ignored.
    -- "special"    - All buffers other than normal buffers are ignored.
    -- table        - A list of buftypes to ignore. See :help buftype for the
    --                possible values.
    -- function     - A function that returns true if the buffer should be
    --                ignored or false if it should not be ignored.
    --                Takes two arguments, `bufnr` and `buftype`.
    buftypes = "special",

    -- Ignored wintypes.
    -- Can be one of the following:
    -- false or nil - No wintypes are ignored.
    -- "special"    - All windows other than normal windows are ignored.
    -- table        - A list of wintypes to ignore. See :help win_gettype() for the
    --                possible values.
    -- function     - A function that returns true if the window should be
    --                ignored or false if it should not be ignored.
    --                Takes two arguments, `winid` and `wintype`.
    wintypes = "special",
  },

  -- When you fold code with za, zo, or zc, update the aerial tree as well.
  -- Only works when manage_folds = true
  link_folds_to_tree = false,

  -- Fold code when you open/collapse symbols in the tree.
  -- Only works when manage_folds = true
  link_tree_to_folds = true,

  -- Use symbol tree for folding. Set to true or false to enable/disable
  -- 'auto' will manage folds if your previous foldmethod was 'manual'
  manage_folds = false,

  -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
  -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
  nerd_font = "auto",

  -- Call this function when aerial attaches to a buffer.
  -- Useful for setting keymaps. Takes a single `bufnr` argument.
  on_attach = nil,

  -- Call this function when aerial first sets symbols on a buffer.
  -- Takes a single `bufnr` argument.
  on_first_symbols = nil,

  -- Automatically open aerial when entering supported buffers.
  -- This can be a function (see :help aerial-open-automatic)
  open_automatic = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

  -- When true, aerial will automatically close after jumping to a symbol
  close_on_select = false,

  -- Show box drawing characters for the tree hierarchy
  show_guides = false,

  -- The autocmds that trigger symbols update (not used for LSP backend)
  update_events = "TextChanged,InsertLeave",

  -- Customize the characters used when show_guides = true
  guides = {
    -- When the child item has a sibling below it
    mid_item = "├─",
    -- When the child item is the last in the list
    last_item = "└─",
    -- When there are nested child guides to the right
    nested_top = "│ ",
    -- Raw indentation
    whitespace = "  ",
  },

  -- Options for opening aerial in a floating win
  float = {
    -- Controls border appearance. Passed to nvim_open_win
    border = "rounded",

    -- Enum: cursor, editor, win
    --   cursor - Opens float on top of the cursor
    --   editor - Opens float centered in the editor
    --   win    - Opens float centered in the window
    relative = "cursor",

    -- These control the height of the floating window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a list of mixed types.
    -- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
    max_height = 0.9,
    height = nil,
    min_height = { 8, 0.1 },

    override = function(conf)
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      return conf
    end,
  },

  lsp = {
    -- Fetch document symbols when LSP diagnostics update.
    -- If false, will update on buffer changes.
    diagnostics_trigger_update = true,

    -- Set to false to not update the symbols when there are LSP errors
    update_when_errors = true,

    -- How long to wait (in ms) after a buffer change before updating
    -- Only used when diagnostics_trigger_update = false
    update_delay = 300,
  },

  treesitter = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },

  markdown = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },
})

```

All possible SymbolKind values can be found [in the LSP
spec](https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#symbolKind).
These are the values used for configuring icons, highlight groups, and
filtering.

## Default Keybindings

The default keybindings in the aerial window. You can add your own in
`ftplugin/aerial.vim`, and remove these by setting `default_bindings = false`.
The default bindings are set in
[bindings.lua](https://github.com/stevearc/aerial.nvim/blob/master/lua/aerial/bindings.lua#L4),
which you can use as a reference if you want to set your own bindings.

| Key             | Command                                                        |
| --------------- | -------------------------------------------------------------- |
| `?`/`g?`        | Show default keymaps                                           |
| `<CR>`          | Jump to the symbol under the cursor                            |
| `<C-v>`         | Jump to the symbol in a vertical split                         |
| `<C-s>`         | Jump to the symbol in a horizontal split                       |
| `p`             | Scroll to the symbol (stay in aerial buffer)                   |
| `<C-j>`         | Go down one line and scroll to that symbol                     |
| `<C-k>`         | Go up one line and scroll to that symbol                       |
| `{`             | Jump to the previous symbol                                    |
| `}`             | Jump to the next symbol                                        |
| `[[`            | Jump up the tree, moving backwards                             |
| `]]`            | Jump up the tree, moving forwards                              |
| `q`             | Close the aerial window                                        |
| `o`/`za`        | Toggle the symbol under the cursor open/closed                 |
| `O`/`zA`        | Recursive toggle the symbol under the cursor open/closed       |
| `l`/`zo`        | Expand the symbol under the cursor                             |
| `L`/`zO`        | Recursive expand the symbol under the cursor                   |
| `h`/`zc`        | Collapse the symbol under the cursor                           |
| `H`/`zC`        | Recursive collapse the symbol under the cursor                 |
| `zR`            | Expand all nodes in the tree                                   |
| `zM`            | Collapse all nodes in the tree                                 |
| `zx`/`zX`       | Sync code folding to the tree (useful if they get out of sync) |
| `<2-LeftMouse>` | Jump to the symbol under the cursor                            |

## Third-party integrations

### Telescope

If you have [telescope](https://github.com/nvim-telescope/telescope.nvim)
installed, there is an extension for fuzzy finding and jumping to symbols. It
functions similarly to the builtin `lsp_document_symbols` picker, the main
difference being that it uses the aerial backend for the source (e.g. LSP,
treesitter, etc) and that it filters out some symbols (see the `filter_kind`
option).

You can activate the picker with `:Telescope aerial`

If you want the command to autocomplete, you can load the extension first:

```lua
require('telescope').load_extension('aerial')
```

The extension can be customized with the following options:

```lua
require('telescope').setup({
  extensions = {
    aerial = {
      -- Display symbols as <root>.<parent>.<symbol>
      show_nesting = true
    }
  }
})
```

### fzf

If you have [fzf](https://github.com/junegunn/fzf.vim) installed you can trigger
fuzzy finding with `:call aerial#fzf()`. To create a mapping:

```vim
nmap <silent> <leader>ds <cmd>call aerial#fzf()<cr>
```

### Lualine

There is a lualine component to display the symbols for your current cursor
position

```lua
require("lualine").setup({
  sections = {
    lualine_x = { "aerial" },

    -- Or you can customize it
    lualine_y = { "aerial",
      -- The separator to be used to separate symbols in status line.
      sep = ' ) ',

      -- The number of symbols to render top-down. In order to render only 'N' last
      -- symbols, negative numbers may be supplied. For instance, 'depth = -1' can
      -- be used in order to render only current symbol.
      depth = nil,

      -- When 'dense' mode is on, icons are not rendered near their symbols. Only
      -- a single icon that represents the kind of current symbol is rendered at
      -- the beginning of status line.
      dense = false,

      -- The separator to be used to separate symbols in dense mode.
      dense_sep = '.',
    },
  },
})
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
" If highlight_mode="split_width", you can set a separate color for the
" non-current location highlight
hi AerialLineNC guibg=Gray

" You can customize the guides (if show_guide=true)
hi link AerialGuide Comment
" You can set a different guide color for each level
hi AerialGuide1 guifg=Red
hi AerialGuide2 guifg=Blue
```

## FAQ

**Q: I accidentally opened a file into the aerial window and it looks bad. How can I prevent this from happening?**

Try installing [stickybuf](https://github.com/stevearc/stickybuf.nvim). It was designed to prevent exactly this problem.
