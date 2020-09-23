local callbacks = require 'aerial.callbacks'
local config = require 'aerial.config'
local data = require 'aerial.data'
local nav = require 'aerial.navigation'
local util = require 'aerial.util'
local window = require 'aerial.window'

local M = {}

M.is_open = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer()
  if aer_bufnr == -1 then
    return false
  else
    local winid = vim.fn.bufwinid(aer_bufnr)
    return winid ~= -1
  end
end

M.close = function()
  if util.is_aerial_buffer() then
    vim.cmd('close')
    return
  end
  local aer_bufnr = util.get_aerial_buffer()
  local winnr = vim.fn.bufwinnr(aer_bufnr)
  if winnr ~= -1 then
    vim.cmd(winnr .. "close")
  end
end

M._maybe_open_automatic = function()
  if vim.fn.line('$') < config.get_open_automatic_min_lines() then
    return
  end
  M.open(false, config.get_automatic_direction())
end

M.open = function(focus, direction)
  if vim.lsp.buf_get_clients() == 0 then
    error("Cannot open aerial. No LSP clients")
    return
  end
  bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if M.is_open() then
    if focus then
      local winid = vim.fn.bufwinid(aer_bufnr)
      vim.api.nvim_set_current_win(winid)
    end
    return
  end
  local direction = direction or util.detect_split_direction()
  local start_winid = vim.fn.win_getid()
  window.create_aerial_window(bufnr, aer_bufnr, direction)
  if aer_bufnr == -1 then
    aer_bufnr = vim.api.nvim_get_current_buf()
  end
  if data.items_by_buf[bufnr] == nil then
    vim.lsp.buf.document_symbol()
  end
  vim.api.nvim_set_current_win(start_winid)
  nav._update_position()
  if focus then
    vim.api.nvim_set_current_win(vim.fn.bufwinid(aer_bufnr))
  end
end

M.focus = function()
  if not M.is_open() then
    return
  end
  bufnr = vim.api.nvim_get_current_buf()
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  local winid = vim.fn.bufwinid(aer_bufnr)
  vim.api.nvim_set_current_win(winid)
end

M.toggle = function(focus, direction)
  if util.is_aerial_buffer() then
    vim.cmd('close')
    return
  end

  if M.is_open() then
    M.close()
  else
    M.open(focus, direction)
  end
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

  local old_callback = vim.lsp.callbacks['textDocument/documentSymbol']
  local new_callback = callbacks.symbol_callback
  if opts.preserve_callback then
    new_callback = function(idk1, idk2, result, idk3, bufnr)
      callbacks.symbol_callback(idk1, idk2, result, idk3, bufnr)
      old_callback(idk1, idk2, result, idk3, bufnr)
    end
  end
  vim.lsp.callbacks['textDocument/documentSymbol'] = new_callback

  if config.get_diagnostics_trigger_update() then
    vim.cmd("autocmd User LspDiagnosticsChanged lua require'aerial.autocommands'.request_symbols_if_diagnostics_changed()")
  end

  vim.cmd("autocmd InsertLeave <buffer> lua vim.lsp.buf.document_symbol()")
  vim.cmd("autocmd BufWritePost <buffer> lua vim.lsp.buf.document_symbol()")
  vim.cmd("autocmd CursorMoved <buffer> lua require'aerial.navigation'._update_position()")
  vim.cmd("autocmd BufLeave <buffer> lua require'aerial.autocommands'.on_buf_leave()")
  if config.get_open_automatic() then
    M._maybe_open_automatic()
    vim.cmd("autocmd BufWinEnter <buffer> lua require'aerial'._maybe_open_automatic()")
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
