-- Functions that are called in response to autocommands
local config = require 'aerial.config'
local data = require 'aerial.data'
local fold = require 'aerial.fold'
local util = require 'aerial.util'
local render = require 'aerial.render'
local window = require 'aerial.window'

local M = {}

local function close_orphans()
  local orphans = util.get_aerial_orphans()
  for _,winid in ipairs(orphans) do
    if config.close_behavior == 'persist' then
      render.clear_buffer(vim.api.nvim_win_get_buf(winid))
    else
      vim.api.nvim_win_close(winid, true)
    end
  end
end

M.on_enter_buffer = function()
  local mybuf = vim.api.nvim_get_current_buf()

  -- If the user tried to open a non-aerial buffer inside the aerial window,
  -- close the window and re-open the buffer.
  -- The defer is to let the other autocmds and potential window switching settle.
  vim.defer_fn(function()
    mybuf = vim.api.nvim_get_current_buf()
    if vim.w.is_aerial_win and not util.is_aerial_buffer(mybuf) then
      vim.api.nvim_win_close(0, false)
      vim.api.nvim_set_current_buf(mybuf)
    end
  end, 1)

  if config.close_behavior == 'close' and not util.is_aerial_buffer(mybuf) then
    close_orphans()
  end

  -- We only care if we enter an LSP-enabled buffer or an aerial buffer
  if vim.tbl_isempty(vim.lsp.buf_get_clients()) and not util.is_aerial_buffer(mybuf) then
    fold.restore_foldmethod()
    close_orphans()
    return
  end

  fold.maybe_set_foldmethod()
  if util.is_aerial_buffer(mybuf) then
    if (config.close_behavior ~= 'persist' and util.is_aerial_buffer_orphaned(mybuf))
      or vim.tbl_count(vim.api.nvim_list_wins()) == 1 then
      vim.cmd('quit')
    else
      -- Hack to ignore winwidth
      vim.api.nvim_win_set_width(0, util.get_width())
    end
  elseif window.is_open() then
    close_orphans()
    render.update_aerial_buffer()
  else
    local orphans = util.get_aerial_orphans()
    if not vim.tbl_isempty(orphans) then
      -- open our symbols in that window
      vim.defer_fn(function()
        window.open(false, nil, {winid = orphans[1]})
      end, 5)
    else
      vim.defer_fn(function()
        window.maybe_open_automatic()
      end, 5)
    end
  end
end

M.on_buf_delete = function(bufnr)
  data[bufnr] = nil
end

M.on_diagnostics_changed = function()
  local errors = vim.lsp.diagnostic.get_count(0, 'Error')
  -- if no errors, refresh symbols
  if config.update_when_errors
    or errors == 0
    or not data:has_symbols() then
    vim.lsp.buf.document_symbol()
  end
end

M.on_cursor_move = function()
  window.update_position(0, true)
end

return M
