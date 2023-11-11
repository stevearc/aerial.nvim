# aerial.nvim

A code outline window for skimming and quick navigation

<!-- TOC -->

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
- [Commands](#commands)
- [Options](#options)
- [Third-party integrations](#third-party-integrations)
  - [Telescope](#telescope)
  - [fzf](#fzf)
  - [Lualine](#lualine)
- [Highlight](#highlight)
- [API](#api)
- [TreeSitter queries](#treesitter-queries)
- [FAQ](#faq)

<!-- /TOC -->

https://user-images.githubusercontent.com/506791/122652728-18688500-d0f5-11eb-80aa-910f7e6a5f46.mp4

## Requirements

- Neovim 0.8+ (for older versions, use the [nvim-0.5 branch](https://github.com/stevearc/aerial.nvim/tree/nvim-0.5))
- One or more of the following:
  - A working LSP setup (see [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig))
  - [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with languages installed

## Installation

aerial supports all the usual plugin managers

<details>
  <summary>lazy.nvim</summary>

```lua
{
  'stevearc/aerial.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = {
     "nvim-treesitter/nvim-treesitter",
     "nvim-tree/nvim-web-devicons"
  },
}
```

</details>

<details>
  <summary>Packer</summary>

```lua
require("packer").startup(function()
  use({
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup()
    end,
  })
end)
```

</details>

<details>
  <summary>Paq</summary>

```lua
require("paq")({
  { "stevearc/aerial.nvim" },
})
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
require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
```

In addition, you will need to have either Treesitter or a working LSP client. You can configure your preferred source(s) with the `backends` option (see [Options](#options)). The default is to prefer Treesitter when it's available and fall back to LSP.

<details>
  <summary>Supported treesitter languages</summary>

- bash
- c
- c_sharp
- cpp
- dart
- elixir
- go
- help
- html
- java
- javascript
- json
- julia
- latex
- lua
- make
- markdown
- norg
- objdump
- org
- php
- proto
- python
- rst
- ruby
- rust
- scala
- snakemake
- solidity
- teal
- tsx
- typescript
- usd
- vim
- vimdoc
- yaml

Don't see your language here? [Request support for
it](https://github.com/stevearc/aerial.nvim/issues/new?assignees=stevearc&labels=enhancement&template=feature-request--treesitter-language-.md&title=)

</details>

## Commands


| Command              | Args               | Description                                                              |
| -------------------- | ------------------ | ------------------------------------------------------------------------ |
| `AerialToggle[!]`    | `left/right/float` | Open or close the aerial window. With `!` cursor stays in current window |
| `AerialOpen[!]`      | `left/right/float` | Open the aerial window. With `!` cursor stays in current window          |
| `AerialOpenAll`      |                    | Open an aerial window for each visible window.                           |
| `AerialClose`        |                    | Close the aerial window.                                                 |
| `AerialCloseAll`     |                    | Close all visible aerial windows.                                        |
| `[count]AerialNext`  |                    | Jump forwards {count} symbols (default 1).                               |
| `[count]AerialPrev`  |                    | Jump backwards [count] symbols (default 1).                              |
| `[count]AerialGo[!]` |                    | Jump to the [count] symbol (default 1).                                  |
| `AerialInfo`         |                    | Print out debug info related to aerial.                                  |
| `AerialNavToggle`    |                    | Open or close the aerial nav window.                                     |
| `AerialNavOpen`      |                    | Open the aerial nav window.                                              |
| `AerialNavClose`     |                    | Close the aerial nav window.                                             |


## Options

```lua
-- Call the setup function to change the default behavior
require("aerial").setup({
  -- Priority list of preferred backends for aerial.
  -- This can be a filetype map (see :help aerial-filetype-map)
  backends = { "treesitter", "lsp", "markdown", "man" },

  layout = {
    -- These control the width of the aerial window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a list of mixed types.
    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
    max_width = { 40, 0.2 },
    width = nil,
    min_width = 10,

    -- key-value pairs of window-local options for aerial window (e.g. winhl)
    win_opts = {},

    -- Determines the default direction to open the aerial window. The 'prefer'
    -- options will open the window in the other direction *if* there is a
    -- different buffer in the way of the preferred direction
    -- Enum: prefer_right, prefer_left, right, left, float
    default_direction = "prefer_right",

    -- Determines where the aerial window will be opened
    --   edge   - open aerial at the far right/left of the editor
    --   window - open aerial to the right/left of the current window
    placement = "window",

    -- When the symbols change, resize the aerial window (within min/max constraints) to fit
    resize_to_content = true,

    -- Preserve window size equality with (:help CTRL-W_=)
    preserve_equality = false,
  },

  -- Determines how the aerial window decides which buffer to display symbols for
  --   window - aerial window will display symbols for the buffer in the window from which it was opened
  --   global - aerial window will display symbols for the current window
  attach_mode = "window",

  -- List of enum values that configure when to auto-close the aerial window
  --   unfocus       - close aerial when you leave the original source window
  --   switch_buffer - close aerial when you change buffers in the source window
  --   unsupported   - close aerial when attaching to a buffer that has no symbol source
  close_automatic_events = {},

  -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
  -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
  -- Additionally, if it is a string that matches "actions.<name>",
  -- it will use the mapping at require("aerial.actions").<name>
  -- Set to `false` to remove a keymap
  keymaps = {
    ["?"] = "actions.show_help",
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.jump",
    ["<2-LeftMouse>"] = "actions.jump",
    ["<C-v>"] = "actions.jump_vsplit",
    ["<C-s>"] = "actions.jump_split",
    ["p"] = "actions.scroll",
    ["<C-j>"] = "actions.down_and_scroll",
    ["<C-k>"] = "actions.up_and_scroll",
    ["{"] = "actions.prev",
    ["}"] = "actions.next",
    ["[["] = "actions.prev_up",
    ["]]"] = "actions.next_up",
    ["q"] = "actions.close",
    ["o"] = "actions.tree_toggle",
    ["za"] = "actions.tree_toggle",
    ["O"] = "actions.tree_toggle_recursive",
    ["zA"] = "actions.tree_toggle_recursive",
    ["l"] = "actions.tree_open",
    ["zo"] = "actions.tree_open",
    ["L"] = "actions.tree_open_recursive",
    ["zO"] = "actions.tree_open_recursive",
    ["h"] = "actions.tree_close",
    ["zc"] = "actions.tree_close",
    ["H"] = "actions.tree_close_recursive",
    ["zC"] = "actions.tree_close_recursive",
    ["zr"] = "actions.tree_increase_fold_level",
    ["zR"] = "actions.tree_open_all",
    ["zm"] = "actions.tree_decrease_fold_level",
    ["zM"] = "actions.tree_close_all",
    ["zx"] = "actions.tree_sync_folds",
    ["zX"] = "actions.tree_sync_folds",
  },

  -- When true, don't load aerial until a command or function is called
  -- Defaults to true, unless `on_attach` is provided, then it defaults to false
  lazy_load = true,

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

  -- Jump to symbol in source window when the cursor moves
  autojump = false,

  -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
  -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
  -- default collapsed icon. The default icon set is determined by the
  -- "nerd_font" option below.
  -- If you have lspkind-nvim installed, it will be the default icon set.
  -- This can be a filetype map (see :help aerial-filetype-map)
  icons = {},

  -- Control which windows and buffers aerial should ignore.
  -- Aerial will not open when these are focused, and existing aerial windows will not be updated
  ignore = {
    -- Ignore unlisted buffers. See :help buflisted
    unlisted_buffers = false,

    -- List of filetypes to ignore.
    filetypes = {},

    -- Ignored buftypes.
    -- Can be one of the following:
    -- false or nil - No buftypes are ignored.
    -- "special"    - All buffers other than normal, help and man page buffers are ignored.
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

  -- Use symbol tree for folding. Set to true or false to enable/disable
  -- Set to "auto" to manage folds if your previous foldmethod was 'manual'
  -- This can be a filetype map (see :help aerial-filetype-map)
  manage_folds = false,

  -- When you fold code with za, zo, or zc, update the aerial tree as well.
  -- Only works when manage_folds = true
  link_folds_to_tree = false,

  -- Fold code when you open/collapse symbols in the tree.
  -- Only works when manage_folds = true
  link_tree_to_folds = true,

  -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
  -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
  nerd_font = "auto",

  -- Call this function when aerial attaches to a buffer.
  on_attach = function(bufnr) end,

  -- Call this function when aerial first sets symbols on a buffer.
  on_first_symbols = function(bufnr) end,

  -- Automatically open aerial when entering supported buffers.
  -- This can be a function (see :help aerial-open-automatic)
  open_automatic = false,

  -- Run this command after jumping to a symbol (false will disable)
  post_jump_cmd = "normal! zz",

  -- Invoked after each symbol is parsed, can be used to modify the parsed item,
  -- or to filter it by returning false.
  --
  -- bufnr: a neovim buffer number
  -- item: of type aerial.Symbol
  -- ctx: a record containing the following fields:
  --   * backend_name: treesitter, lsp, man...
  --   * lang: info about the language
  --   * symbols?: specific to the lsp backend
  --   * symbol?: specific to the lsp backend
  --   * syntax_tree?: specific to the treesitter backend
  --   * match?: specific to the treesitter backend, TS query match
  post_parse_symbol = function(bufnr, item, ctx)
    return true
  end,

  -- Invoked after all symbols have been parsed and post-processed,
  -- allows to modify the symbol structure before final display
  --
  -- bufnr: a neovim buffer number
  -- items: a collection of aerial.Symbol items, organized in a tree,
  --        with 'parent' and 'children' fields
  -- ctx: a record containing the following fields:
  --   * backend_name: treesitter, lsp, man...
  --   * lang: info about the language
  --   * symbols?: specific to the lsp backend
  --   * syntax_tree?: specific to the treesitter backend
  post_add_all_symbols = function(bufnr, items, ctx)
    return items
  end,

  -- When true, aerial will automatically close after jumping to a symbol
  close_on_select = false,

  -- The autocmds that trigger symbols update (not used for LSP backend)
  update_events = "TextChanged,InsertLeave",

  -- Show box drawing characters for the tree hierarchy
  show_guides = false,

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

  -- Set this function to override the highlight groups for certain symbols
  get_highlight = function(symbol, is_icon, is_collapsed)
    -- return "MyHighlight" .. symbol.kind
  end,

  -- Options for opening aerial in a floating win
  float = {
    -- Controls border appearance. Passed to nvim_open_win
    border = "rounded",

    -- Determines location of floating window
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

    override = function(conf, source_winid)
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      return conf
    end,
  },

  -- Options for the floating nav windows
  nav = {
    border = "rounded",
    max_height = 0.9,
    min_height = { 10, 0.1 },
    max_width = 0.5,
    min_width = { 0.2, 20 },
    win_opts = {
      cursorline = true,
      winblend = 10,
    },
    -- Jump to symbol in source window when the cursor moves
    autojump = false,
    -- Show a preview of the code in the right column, when there are no child symbols
    preview = false,
    -- Keymaps in the nav window
    keymaps = {
      ["<CR>"] = "actions.jump",
      ["<2-LeftMouse>"] = "actions.jump",
      ["<C-v>"] = "actions.jump_vsplit",
      ["<C-s>"] = "actions.jump_split",
      ["h"] = "actions.left",
      ["l"] = "actions.right",
      ["<C-c>"] = "actions.close",
    },
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

    -- Map of LSP client name to priority. Default value is 10.
    -- Clients with higher (larger) priority will be used before those with lower priority.
    -- Set to -1 to never use the client.
    priority = {
      -- pyright = 10,
    },
  },

  treesitter = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },

  markdown = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },

  man = {
    -- How long to wait (in ms) after a buffer change before updating
    update_delay = 300,
  },
})
```

All possible SymbolKind values can be found [in the LSP
spec](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind).
These are the values used for configuring icons, highlight groups, and
filtering.

The `aerial.Symbol` type used in some optional callbacks is:

```typescript
{
kind: SymbolKind,
name: string,
level: number,
parent: aerial.Symbol,
lnum: number,
end_lnum: number,
col: number,
end_col: number
}
```

## Third-party integrations

### Telescope

If you have [telescope](https://github.com/nvim-telescope/telescope.nvim)
installed, there is an extension for fuzzy finding and jumping to symbols. It
functions similarly to the builtin `lsp_document_symbols` picker, the main
difference being that it uses the aerial backend for the source (e.g. LSP,
treesitter, etc) and that it filters out some symbols (see the `filter_kind`
option).

You can activate the picker with `:Telescope aerial` or `:lua require("telescope").extensions.aerial.aerial()`

If you want the command to autocomplete, you can load the extension first:

```lua
require("telescope").load_extension("aerial")
```

The extension can be customized with the following options:

```lua
require("telescope").setup({
  extensions = {
    aerial = {
      -- Display symbols as <root>.<parent>.<symbol>
      show_nesting = {
        ["_"] = false, -- This key will be the default
        json = true, -- You can set the option for specific filetypes
        yaml = true,
      },
    },
  },
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
    lualine_y = {
      {
        "aerial",
        -- The separator to be used to separate symbols in status line.
        sep = " ) ",

        -- The number of symbols to render top-down. In order to render only 'N' last
        -- symbols, negative numbers may be supplied. For instance, 'depth = -1' can
        -- be used in order to render only current symbol.
        depth = nil,

        -- When 'dense' mode is on, icons are not rendered near their symbols. Only
        -- a single icon that represents the kind of current symbol is rendered at
        -- the beginning of status line.
        dense = false,

        -- The separator to be used to separate symbols in dense mode.
        dense_sep = ".",

        -- Color the symbol icons.
        colored = true,
      },
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

" There's also this group for the fallback of the text if a specific
" class highlight isn't defined
hi link AerialNormal Normal
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

## API

<!-- API -->

- [setup(opts)](doc/api.md#setupopts)
- [sync_load()](doc/api.md#sync_load)
- [is_open(opts)](doc/api.md#is_openopts)
- [close()](doc/api.md#close)
- [close_all()](doc/api.md#close_all)
- [close_all_but_current()](doc/api.md#close_all_but_current)
- [open(opts)](doc/api.md#openopts)
- [open_in_win(target_win, source_win)](doc/api.md#open_in_wintarget_win-source_win)
- [open_all()](doc/api.md#open_all)
- [focus()](doc/api.md#focus)
- [toggle(opts)](doc/api.md#toggleopts)
- [refetch_symbols(bufnr)](doc/api.md#refetch_symbolsbufnr)
- [select(opts)](doc/api.md#selectopts)
- [next(step)](doc/api.md#nextstep)
- [prev(step)](doc/api.md#prevstep)
- [next_up(count)](doc/api.md#next_upcount)
- [prev_up(count)](doc/api.md#prev_upcount)
- [get_location(exact)](doc/api.md#get_locationexact)
- [tree_close_all(bufnr)](doc/api.md#tree_close_allbufnr)
- [tree_open_all(bufnr)](doc/api.md#tree_open_allbufnr)
- [tree_set_collapse_level(bufnr, level)](doc/api.md#tree_set_collapse_levelbufnr-level)
- [tree_increase_fold_level(bufnr, count)](doc/api.md#tree_increase_fold_levelbufnr-count)
- [tree_decrease_fold_level(bufnr, count)](doc/api.md#tree_decrease_fold_levelbufnr-count)
- [tree_open(opts)](doc/api.md#tree_openopts)
- [tree_close(opts)](doc/api.md#tree_closeopts)
- [tree_toggle(opts)](doc/api.md#tree_toggleopts)
- [nav_is_open()](doc/api.md#nav_is_open)
- [nav_open()](doc/api.md#nav_open)
- [nav_close()](doc/api.md#nav_close)
- [nav_toggle()](doc/api.md#nav_toggle)
- [treesitter_clear_query_cache()](doc/api.md#treesitter_clear_query_cache)
- [sync_folds(bufnr)](doc/api.md#sync_foldsbufnr)
- [info()](doc/api.md#info)
- [num_symbols(bufnr)](doc/api.md#num_symbolsbufnr)
- [was_closed(default)](doc/api.md#was_closeddefault)

<!-- /API -->

## TreeSitter queries

When writing queries, the following captures and metadata are used by Aerial:

- `@symbol` - **required** capture for the logical region being captured
- `kind` - **required** metadata, a string value matching one of `vim.lsp.protocol.SymbolKind`
- `@name` - capture to extract a name from its text
- `@start` - a start of the match, influences matching of cursor position to aerial tree, defaults to `@symbol`
- `@end` - an end of the match, influences matching of cursor position to aerial tree, defaults to `@start`
- `@selection` - position to jump to when using Aerial for navigation, falls back to `@name` and `@symbol`
- `@scope` - a node naming a scope for the match, its text is used to generate a custom "Comment" linked highlight for the entry, with exception of "public"

    A `@scope` node with text "developers" will result in its entry in the tree having an "AerialDevelopers" highlight applied to it.

- `scope` - a metadata value serving the same role as `@scope` capture, overriding aforementioned capture

Note: a capture's text can be set or modified with `#set!` and `#gsub!` respectively.

## FAQ

**Q: I accidentally opened a file into the aerial window and it looks bad. How can I prevent this from happening?**

Try installing [stickybuf](https://github.com/stevearc/stickybuf.nvim). It was designed to prevent exactly this problem.
