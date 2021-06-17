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

M.select = function(opts)
  nav.select(opts)
end

M.next = function(step, opts)
  nav.next(step, opts)
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

  if config.diagnostics_trigger_update then
    vim.cmd("autocmd User LspDiagnosticsChanged lua require'aerial.autocommands'.on_diagnostics_changed()")
  end

  vim.cmd("autocmd CursorMoved <buffer> lua require'aerial.autocommands'.on_cursor_move()")
  vim.cmd("autocmd BufLeave <buffer> lua require'aerial.autocommands'.on_buf_leave()")
  vim.cmd([[autocmd BufDelete <buffer> call luaeval("require'aerial.autocommands'.on_buf_delete(_A)", expand('<abuf>'))]])
  if config.open_automatic() then
    if not config.diagnostics_trigger_update then
      vim.lsp.buf.document_symbol()
    end
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
    vwin = virt_winnr,
    split = split_cmd,
  }
end

-- @deprecated. Use select()
M.scroll_to_loc = function(virt_winnr, split_cmd)
  nav.select{
    vwin = virt_winnr,
    split = split_cmd,
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
