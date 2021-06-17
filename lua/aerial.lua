local callbacks = require 'aerial.callbacks'
local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local render = require 'aerial.render'
local window = require 'aerial.window'

local M = {}

M.is_open = function(bufnr)
  return window.is_open(bufnr)
end

M.close = function()
  window.close()
end

M.open = function(focus, direction)
  window.open(focus, direction)
end

M.focus = function()
  window.focus()
end

M.toggle = function(focus, direction)
  return window.toggle(focus, direction)
end

M.jump_to_loc = function(virt_winnr, split_cmd)
  nav.jump_to_loc(virt_winnr, split_cmd)
end

M.scroll_to_loc = function(virt_winnr, split_cmd)
  nav.scroll_to_loc(virt_winnr, split_cmd)
end

M.next_item = function()
  nav.skip_item(1)
end

M.prev_item = function()
  nav.skip_item(-1)
end

M.skip_item = function(delta)
  nav.skip_item(delta)
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

  if config.get_diagnostics_trigger_update() then
    vim.cmd("autocmd User LspDiagnosticsChanged lua require'aerial.autocommands'.request_symbols_if_diagnostics_changed()")
  end

  vim.cmd("autocmd InsertLeave <buffer> lua vim.lsp.buf.document_symbol()")
  vim.cmd("autocmd BufWritePost <buffer> lua vim.lsp.buf.document_symbol()")
  vim.cmd("autocmd CursorMoved <buffer> lua require'aerial.navigation'._update_position()")
  vim.cmd("autocmd BufLeave <buffer> lua require'aerial.autocommands'.on_buf_leave()")
  vim.cmd([[autocmd BufDelete <buffer> call luaeval("require'aerial.autocommands'.on_buf_delete(_A)", expand('<abuf>'))]])
  if config.get_open_automatic() then
    vim.lsp.buf.document_symbol()
    vim.cmd("autocmd BufWinEnter <buffer> lua require'aerial.autocommands'.on_buf_win_enter()")
  end
end

M.tree_cmd = function(action, opts)
  local did_update, row = data[0]:action(action, opts)
  if did_update then
    render.update_aerial_buffer()
    nav.update_all_positions()
    print(row)
    if row then
      vim.api.nvim_win_set_cursor(0, {row, 0})
    end
  end
end

M.set_open_automatic = function(ft_or_mapping, bool)
  config.set_open_automatic(ft_or_mapping, bool)
end

-- @deprecated. use set_icon() instead
M.set_kind_abbr = function(kind_or_mapping, abbr)
  config.set_icon(kind_or_mapping, abbr)
end

M.set_icon = function(kind_or_mapping, icon)
  config.set_icon(kind_or_mapping, icon)
end

M.set_filter_kind = function(list)
  config.filter_kind = {}
  for _,kind in pairs(list) do
    config.filter_kind[kind] = true
  end
end

return M
