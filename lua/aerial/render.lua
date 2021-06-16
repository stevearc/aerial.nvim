local data = require 'aerial.data'
local util = require 'aerial.util'
local config = require 'aerial.config'
local M = {}

-- Update the aerial buffer from cached symbols
M.update_aerial_buffer = function(bufnr)
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return
  end
  if not data:has_symbols(bufnr) then
    return
  end
  local row = 1
  local max_len = 1
  local lines = {}
  local highlights = {}
  data[bufnr]:visit(function(item)
    local kind = config.get_kind_abbr(item.kind)
    local spacing = string.rep('  ', item.level)
    local text = string.format("%s%s %s", spacing, kind, item.name)
    local strlen = string.len(text)
    table.insert(highlights, {
      group = 'Aerial' .. item.kind .. 'Icon',
      row = row,
      col_start = string.len(spacing),
      col_end = string.len(spacing) + string.len(kind),
    })
    table.insert(highlights, {
      group = 'Aerial' .. item.kind,
      row = row,
      col_start = strlen - string.len(item.name),
      col_end = strlen,
    })
    max_len = math.max(max_len, strlen)
    table.insert(lines, text)
    row = row + 1
  end)

  local width = math.min(config.get_max_width(), math.max(config.get_min_width(), max_len))
  util.set_width(aer_bufnr, width)

  -- Insert lines into buffer
  for i,line in ipairs(lines) do
    lines[i] = util.rpad(line, width)
  end
  vim.api.nvim_buf_set_option(aer_bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_lines(aer_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(aer_bufnr, 'modifiable', false)

  local ns = vim.api.nvim_create_namespace('aerial')
  vim.api.nvim_buf_clear_namespace(aer_bufnr, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(
      aer_bufnr,
      ns,
      hl.group,
      hl.row - 1,
      hl.col_start,
      hl.col_end
    )
  end
end

-- Update the highlighted lines in the aerial buffer
M.update_highlights = function(bufnr)
  if not data:has_symbols(bufnr) then
    return
  end
  local winids = {}
  local win_count = 0
  local bufdata = data[bufnr]
  for k in pairs(bufdata.positions) do
    local winnr = vim.fn.win_id2win(k)
    if winnr ~= 0 and vim.fn.winbufnr(k) == bufnr then
      win_count = win_count + 1
      table.insert(winids, k)
    end
  end
  table.sort(winids, function(a, b)
    return vim.fn.win_id2win(a) < vim.fn.win_id2win(b)
  end)
  local ns = vim.api.nvim_create_namespace('aerial-line')
  local aer_bufnr = util.get_aerial_buffer(bufnr)
  if aer_bufnr == -1 then
    return
  end
  vim.api.nvim_buf_clear_namespace(aer_bufnr, ns, 0, -1)
  local hl_width = math.floor(util.get_width(aer_bufnr) / win_count)
  local hl_mode = config.get_highlight_mode()

  if hl_mode == 'last' then
    local row = data[bufnr].last_position
    vim.api.nvim_buf_add_highlight(
      aer_bufnr,
      ns,
      'AerialLine',
      row - 1,
      0,
      -1)
    return
  end

  local start_hl = 0
  local end_hl = hl_mode == 'full_width' and -1 or hl_width
  for i,winid in ipairs(winids) do
    -- To fix rounding errors when #windows doesn't divide evenly into the
    -- width, make sure the last highlight goes to the end
    if i == #winids then
      end_hl = -1
    end
    vim.api.nvim_buf_add_highlight(
      aer_bufnr,
      ns,
      'AerialLine',
      bufdata.positions[winid] - 1,
      start_hl,
      end_hl)
    if hl_mode ~= 'full_width' then
      start_hl = end_hl
      end_hl = end_hl + hl_width
    end
  end
end

return M
