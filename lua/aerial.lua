local callbacks = require 'aerial.callbacks'
local config = require 'aerial.config'
local data = require 'aerial.data'
local fold = require 'aerial.fold'
local nav = require 'aerial.navigation'
local render = require 'aerial.render'
local tree = require 'aerial.tree'
local util = require 'aerial.util'
local window = require 'aerial.window'

local M = {}

M.is_open = function(bufnr)
  return window.is_open(bufnr)
end

M.close = function()
  window.close()
end

M.open = function(focus, direction)
  -- We get empty strings from the vim command
  if focus == '' then
    focus = true
  elseif focus == '!' then
    focus = false
  end
  if direction == '' then
    direction = nil
  end
  window.open(focus, direction)
end

M.focus = function()
  window.focus()
end

M.toggle = function(focus, direction)
  -- We get empty strings from the vim command
  if focus == '' then
    focus = true
  elseif focus == '!' then
    focus = false
  end
  if direction == '' then
    direction = nil
  end
  return window.toggle(focus, direction)
end

M.select = function(opts)
  nav.select(opts)
end

M.next = function(step)
  nav.next(step)
end

M.up = function(direction, count)
  nav.up(direction, count)
end

M.on_attach = function(client, opts)
  opts = opts or {}

  local old_callback = vim.lsp.handlers['textDocument/documentSymbol']
  local new_callback = callbacks.symbol_callback
  if opts.preserve_callback then
    new_callback = function(idk1, idk2, result, idk3, bufnr)
      callbacks.symbol_callback(idk1, idk2, result, idk3, bufnr)
      old_callback(idk1, idk2, result, idk3, bufnr)
    end
  end
  vim.lsp.handlers['textDocument/documentSymbol'] = new_callback

  if config.link_folds_to_tree then
    local function map(key, cmd)
      vim.api.nvim_buf_set_keymap(0, 'n', key, cmd, {silent=true, noremap=true})
    end

    map('za', [[<cmd>AerialTreeToggle<CR>]])
    map('zA', [[<cmd>AerialTreeToggle!<CR>]])
    map('zo', [[<cmd>AerialTreeOpen<CR>]])
    map('zO', [[<cmd>AerialTreeOpen!<CR>]])
    map('zc', [[<cmd>AerialTreeClose<CR>]])
    map('zC', [[<cmd>AerialTreeClose!<CR>]])
    map('zM', [[<cmd>AerialTreeCloseAll<CR>]])
    map('zR', [[<cmd>AerialTreeOpenAll<CR>]])
    map('zx', [[<cmd>AerialTreeSyncFolds<CR>]])
    map('zX', [[<cmd>AerialTreeSyncFolds<CR>]])
  end


  if config.diagnostics_trigger_update then
    vim.cmd("autocmd User LspDiagnosticsChanged lua require'aerial.autocommands'.on_diagnostics_changed()")
  end
  vim.cmd([[augroup aerial
    au!
    au BufEnter * lua require'aerial.autocommands'.on_enter_buffer()
  augroup END]])

  vim.cmd("autocmd CursorMoved <buffer> lua require'aerial.autocommands'.on_cursor_move()")
  vim.cmd([[autocmd BufDelete <buffer> call luaeval("require'aerial.autocommands'.on_buf_delete(_A)", expand('<abuf>'))]])
  if config.open_automatic() then
    if not config.diagnostics_trigger_update then
      vim.lsp.buf.document_symbol()
    end
  end
end

local function _post_tree_mutate(new_cursor_pos)
  render.update_aerial_buffer()
  window.update_all_positions()
  if util.is_aerial_buffer() then
    if new_cursor_pos then
      vim.api.nvim_win_set_cursor(0, {new_cursor_pos, 0})
    end
  else
    window.update_position(0, true)
  end
end

M.tree_close_all = function()
  local new_cursor_pos
  local bufdata = data[0]
  if util.is_aerial_buffer() then
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local root = bufdata:get_root_of(bufdata:item(lnum))
    tree.close_all(bufdata)
    new_cursor_pos = bufdata:indexof(root)
  else
    tree.close_all(bufdata)
  end
  if config.link_tree_to_folds then
    M.sync_folds()
  end
  _post_tree_mutate(new_cursor_pos)
end

M.tree_open_all = function()
  tree.open_all(data[0])
  if config.link_tree_to_folds then
    M.sync_folds()
  end
  _post_tree_mutate()
end

M.tree_cmd = function(action, opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    index = nil,
    fold = true,
  })
  local index
  if opts.index then
    index = opts.index
  elseif util.is_aerial_buffer() then
    index = vim.api.nvim_win_get_cursor(0)[1]
  else
    index = window.get_position_in_win().lnum
  end
  local lnum = data[0]:item(index).lnum
  local did_update, new_cursor_pos = tree.edit_tree_node(data[0], action, index, opts)
  if did_update then
    if config.link_tree_to_folds and opts.fold then
      fold.fold_action(action, lnum, {
        recurse = opts.recurse,
      })
    end
    _post_tree_mutate(new_cursor_pos)
  end
end

M.sync_folds = function()
  local mywin = vim.api.nvim_get_current_win()
  if util.is_aerial_buffer() then
    local bufnr = util.get_source_buffer()
    for _,winid in ipairs(util.get_fixed_wins(bufnr)) do
      fold.sync_tree_folds(winid)
    end
  else
    local bufnr = vim.api.nvim_get_current_buf()
    for _,winid in ipairs(util.get_fixed_wins(bufnr)) do
      fold.sync_tree_folds(winid)
    end
  end
  util.go_win_no_au(mywin)
end

-- @deprecated
M.set_open_automatic = function(ft_or_mapping, bool)
  local opts = vim.g.aerial or {}
  if type(ft_or_mapping) == 'table' then
    opts.open_automatic = ft_or_mapping
  else
    opts.open_automatic[ft_or_mapping] = bool
  end
  vim.g.aerial = opts
end

-- @deprecated.
M.set_filter_kind = function(list)
  local opts = vim.g.aerial or {}
  opts.filter_kind = list
  vim.g.aerial = opts
end

-- @deprecated.
M.set_kind_abbr = function(kind_or_mapping, abbr)
  local opts = vim.g.aerial or {}
  if type(kind_or_mapping) == 'table' then
    opts.icons = kind_or_mapping
  else
    if not opts.icons then
      opts.icons = {}
    end
    opts.icons[kind_or_mapping] = abbr
  end
  vim.g.aerial = opts
end

-- @deprecated. Use select()
M.jump_to_loc = function(virt_winnr, split_cmd)
  nav.select{
    split = virt_winnr > 1 and split_cmd or nil,
  }
end

-- @deprecated. Use select()
M.scroll_to_loc = function(virt_winnr, split_cmd)
  nav.select{
    split = virt_winnr > 1 and split_cmd or nil,
    jump = false,
  }
end

-- @deprecated. Use next()
M.next_item = function()
  nav.next(1)
end

-- @deprecated. Use next()
M.prev_item = function()
  nav.next(-1)
end

-- @deprecated. Use next()
M.skip_item = function(delta)
  nav.next(delta)
end

return M
