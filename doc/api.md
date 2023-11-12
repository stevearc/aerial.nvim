# API

<!-- TOC -->

- [setup(opts)](#setupopts)
- [sync_load()](#sync_load)
- [is_open(opts)](#is_openopts)
- [close()](#close)
- [close_all()](#close_all)
- [close_all_but_current()](#close_all_but_current)
- [open(opts)](#openopts)
- [open_in_win(target_win, source_win)](#open_in_wintarget_win-source_win)
- [open_all()](#open_all)
- [focus()](#focus)
- [toggle(opts)](#toggleopts)
- [refetch_symbols(bufnr)](#refetch_symbolsbufnr)
- [select(opts)](#selectopts)
- [next(step)](#nextstep)
- [prev(step)](#prevstep)
- [next_up(count)](#next_upcount)
- [prev_up(count)](#prev_upcount)
- [get_location(exact)](#get_locationexact)
- [tree_close_all(bufnr)](#tree_close_allbufnr)
- [tree_open_all(bufnr)](#tree_open_allbufnr)
- [tree_set_collapse_level(bufnr, level)](#tree_set_collapse_levelbufnr-level)
- [tree_increase_fold_level(bufnr, count)](#tree_increase_fold_levelbufnr-count)
- [tree_decrease_fold_level(bufnr, count)](#tree_decrease_fold_levelbufnr-count)
- [tree_open(opts)](#tree_openopts)
- [tree_close(opts)](#tree_closeopts)
- [tree_toggle(opts)](#tree_toggleopts)
- [nav_is_open()](#nav_is_open)
- [nav_open()](#nav_open)
- [nav_close()](#nav_close)
- [nav_toggle()](#nav_toggle)
- [treesitter_clear_query_cache()](#treesitter_clear_query_cache)
- [sync_folds(bufnr)](#sync_foldsbufnr)
- [info()](#info)
- [num_symbols(bufnr)](#num_symbolsbufnr)
- [was_closed(default)](#was_closeddefault)

<!-- /TOC -->

<!-- API -->

## setup(opts)

`setup(opts)` \
Initialize aerial

| Param | Type         | Desc |
| ----- | ------------ | ---- |
| opts  | `nil\|table` |      |

## sync_load()

`sync_load()` \
Synchronously complete setup (if lazy-loaded)


## is_open(opts)

`is_open(opts): boolean` \
Returns true if aerial is open for the current window or buffer (returns false inside an aerial buffer)

| Param | Type         | Desc           |     |
| ----- | ------------ | -------------- | --- |
| opts  | `nil\|table` |                |     |
|       | bufnr        | `nil\|integer` |     |
|       | winid        | `nil\|integer` |     |

## close()

`close()` \
Close the aerial window.


## close_all()

`close_all()` \
Close all visible aerial windows.


## close_all_but_current()

`close_all_but_current()` \
Close all visible aerial windows except for the one currently focused or for the currently focused window.


## open(opts)

`open(opts)` \
Open the aerial window for the current buffer.

| Param | Type         | Desc                       |                                                               |
| ----- | ------------ | -------------------------- | ------------------------------------------------------------- |
| opts  | `nil\|table` |                            |                                                               |
|       | focus        | `boolean`                  | If true, jump to aerial window if it is opened (default true) |
|       | direction    | `"left"\|"right"\|"float"` | Direction to open aerial window                               |

## open_in_win(target_win, source_win)

`open_in_win(target_win, source_win)` \
Open aerial in an existing window

| Param      | Type      | Desc                                      |
| ---------- | --------- | ----------------------------------------- |
| target_win | `integer` | The winid to open the aerial buffer       |
| source_win | `integer` | The winid that contains the source buffer |

**Note:**
<pre>
This can be used to create custom layouts, since you can create and position the window yourself
</pre>

## open_all()

`open_all()` \
Open an aerial window for each visible window.


## focus()

`focus()` \
Jump to the aerial window for the current buffer, if it is open


## toggle(opts)

`toggle(opts)` \
Open or close the aerial window for the current buffer.

| Param | Type         | Desc                       |                                                               |
| ----- | ------------ | -------------------------- | ------------------------------------------------------------- |
| opts  | `nil\|table` |                            |                                                               |
|       | focus        | `boolean`                  | If true, jump to aerial window if it is opened (default true) |
|       | direction    | `"left"\|"right"\|"float"` | Direction to open aerial window                               |

## refetch_symbols(bufnr)

`refetch_symbols(bufnr)` \
Refresh the symbols for a buffer

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

**Note:**
<pre>
Symbols will usually get refreshed automatically when needed. You should only need to
call this if you change something in the config (e.g. by setting vim.b.aerial_backends)
</pre>

## select(opts)

`select(opts)` \
Jump to a specific symbol.

| Param | Type         | Desc           |                                                                                                                                                  |
| ----- | ------------ | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| opts  | `nil\|table` |                |                                                                                                                                                  |
|       | index        | `nil\|integer` | The symbol to jump to. If nil, will jump to the symbol under the cursor (in the aerial buffer)                                                   |
|       | split        | `nil\|string`  | Jump to the symbol in a new split. Can be "v" for vertical or "h" for horizontal. Can also be a raw command to execute (e.g. "belowright split") |
|       | jump         | `nil\|boolean` | If false and in the aerial window, do not leave the aerial window. (Default true)                                                                |

## next(step)

`next(step)` \
Jump forwards in the symbol list.

| Param | Type           | Desc                                     |
| ----- | -------------- | ---------------------------------------- |
| step  | `nil\|integer` | Number of symbols to jump by (default 1) |

## prev(step)

`prev(step)` \
Jump backwards in the symbol list.

| Param | Type           | Desc                                     |
| ----- | -------------- | ---------------------------------------- |
| step  | `nil\|integer` | Number of symbols to jump by (default 1) |

## next_up(count)

`next_up(count)` \
Jump to a symbol higher in the tree, moving forwards

| Param | Type           | Desc                                   |
| ----- | -------------- | -------------------------------------- |
| count | `nil\|integer` | How many levels to jump up (default 1) |

## prev_up(count)

`prev_up(count)` \
Jump to a symbol higher in the tree, moving backwards

| Param | Type           | Desc                                   |
| ----- | -------------- | -------------------------------------- |
| count | `nil\|integer` | How many levels to jump up (default 1) |

## get_location(exact)

`get_location(exact): table[]` \
Get a list representing the symbol path to the current location.

| Param | Type           | Desc                                                                                                             |
| ----- | -------------- | ---------------------------------------------------------------------------------------------------------------- |
| exact | `nil\|boolean` | If true, only return symbols if we are exactly inside the hierarchy. When false, will return the closest symbol. |

**Note:**
<pre>
Returns empty list if none found or in an invalid buffer.
Items have the following keys:
    name   The name of the symbol
    kind   The SymbolKind of the symbol
    icon   The icon that represents the symbol
</pre>

## tree_close_all(bufnr)

`tree_close_all(bufnr)` \
Collapse all nodes in the symbol tree

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

## tree_open_all(bufnr)

`tree_open_all(bufnr)` \
Expand all nodes in the symbol tree

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

## tree_set_collapse_level(bufnr, level)

`tree_set_collapse_level(bufnr, level)` \
Set the collapse level of the symbol tree

| Param | Type      | Desc                                |
| ----- | --------- | ----------------------------------- |
| bufnr | `integer` |                                     |
| level | `integer` | 0 is all closed, use 99 to open all |

## tree_increase_fold_level(bufnr, count)

`tree_increase_fold_level(bufnr, count)` \
Increase the fold level of the symbol tree

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `integer`      |      |
| count | `nil\|integer` |      |

## tree_decrease_fold_level(bufnr, count)

`tree_decrease_fold_level(bufnr, count)` \
Decrease the fold level of the symbol tree

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `integer`      |      |
| count | `nil\|integer` |      |

## tree_open(opts)

`tree_open(opts)` \
Open the tree at the selected location

| Param | Type         | Desc           |                                                                                                     |
| ----- | ------------ | -------------- | --------------------------------------------------------------------------------------------------- |
| opts  | `nil\|table` |                |                                                                                                     |
|       | index        | `nil\|integer` | The index of the symbol to perform the action on. Defaults to cursor location.                      |
|       | fold         | `nil\|boolean` | If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)            |
|       | recurse      | `nil\|boolean` | If true, perform the action recursively on all children (default false)                             |
|       | bubble       | `nil\|boolean` | If true and current symbol has no children, perform the action on the nearest parent (default true) |

## tree_close(opts)

`tree_close(opts)` \
Collapse the tree at the selected location

| Param | Type         | Desc           |                                                                                                     |
| ----- | ------------ | -------------- | --------------------------------------------------------------------------------------------------- |
| opts  | `nil\|table` |                |                                                                                                     |
|       | index        | `nil\|integer` | The index of the symbol to perform the action on. Defaults to cursor location.                      |
|       | fold         | `nil\|boolean` | If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)            |
|       | recurse      | `nil\|boolean` | If true, perform the action recursively on all children (default false)                             |
|       | bubble       | `nil\|boolean` | If true and current symbol has no children, perform the action on the nearest parent (default true) |

## tree_toggle(opts)

`tree_toggle(opts)` \
Toggle the collapsed state at the selected location

| Param | Type         | Desc           |                                                                                                     |
| ----- | ------------ | -------------- | --------------------------------------------------------------------------------------------------- |
| opts  | `nil\|table` |                |                                                                                                     |
|       | index        | `nil\|integer` | The index of the symbol to perform the action on. Defaults to cursor location.                      |
|       | fold         | `nil\|boolean` | If false, do not modify folds regardless of 'link_tree_to_folds' setting. (default true)            |
|       | recurse      | `nil\|boolean` | If true, perform the action recursively on all children (default false)                             |
|       | bubble       | `nil\|boolean` | If true and current symbol has no children, perform the action on the nearest parent (default true) |

## nav_is_open()

`nav_is_open(): boolean` \
Check if the nav windows are open


## nav_open()

`nav_open()` \
Open the nav windows


## nav_close()

`nav_close()` \
Close the nav windows


## nav_toggle()

`nav_toggle()` \
Toggle the nav windows open/closed


## treesitter_clear_query_cache()

`treesitter_clear_query_cache()` \
Clear aerial's tree-sitter query cache


## sync_folds(bufnr)

`sync_folds(bufnr)` \
Sync code folding with the current tree state.

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

**Note:**
<pre>
Ignores the 'link_tree_to_folds' config option.
</pre>

## info()

`info(): table` \
Get debug info for aerial


## num_symbols(bufnr)

`num_symbols(bufnr): integer` \
Returns the number of symbols for the buffer

| Param | Type      | Desc |
| ----- | --------- | ---- |
| bufnr | `integer` |      |

## was_closed(default)

`was_closed(default): nil|boolean` \
Returns true if the user has manually closed aerial. Will become false if the user opens aerial again.

| Param   | Type           | Desc |
| ------- | -------------- | ---- |
| default | `nil\|boolean` |      |


<!-- /API -->
