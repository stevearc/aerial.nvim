local callbacks = require 'aerial.callbacks'
local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local pane = require 'aerial.pane'
local util = require 'aerial.util'
local window = require 'aerial.window'

local M = {}

M.is_open = function(bufnr)
  return pane.is_open(bufnr)
end

M.close = function()
  pane.close()
end

M.open = function(focus, direction)
  pane.open(focus, direction)
end

M.focus = function()
  pane.focus()
end

M.toggle = function(focus, direction)
  return pane.toggle(focus, direction)
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
  local opts = opts or {}

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
  if config.get_open_automatic() then
    vim.lsp.buf.document_symbol()
    vim.cmd("autocmd BufWinEnter <buffer> lua require'aerial.autocommands'.on_buf_win_enter()")
  end
end

M.set_open_automatic = function(ft_or_mapping, bool)
  if type(ft_or_mapping) == 'table' then
    config.open_automatic = ft_or_mapping
  else
    config.open_automatic[ft_or_mapping] = bool
  end
end

M.set_kind_abbr = function(kind_or_mapping, abbr)
  if type(kind_or_mapping) == 'table' then
    config.kind_abbr = kind_or_mapping
  else
    config.kind_abbr[kind_or_mapping] = abbr
  end
end

M.set_filter_kind = function(list)
  config.filter_kind = {}
  for _,kind in pairs(list) do
    config.filter_kind[kind] = true
  end
end

return M
