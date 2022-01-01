local config = require("aerial.config")
local data = require("aerial.data")
local loading = require("aerial.loading")
local util = require("aerial.util")
local M = {}

local INDENT = 2

M.clear_buffer = function(bufnr)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- Update the aerial buffer from cached symbols
M.update_aerial_buffer = function(buf)
  local bufnr, aer_bufnr = util.get_buffers(buf)
  if aer_bufnr == -1 or loading.is_loading(aer_bufnr) then
    return
  end
  if not data:has_symbols(bufnr) then
    local lines = { "No symbols" }
    if config.lsp.filter_kind ~= false then
      table.insert(lines, ":help aerial-filter")
    end
    util.render_centered_text(aer_bufnr, lines)
    return
  end
  local row = 1
  local max_len = 1
  local lines = {}
  local highlights = {}
  data[bufnr]:visit(function(item, conf)
    local kind = config.get_icon(item.kind, conf.collapsed)
    local spacing = string.rep(" ", INDENT * item.level)
    local text = string.format("%s%s %s", spacing, kind, item.name)
    local text_cols = vim.api.nvim_strwidth(text)
    local kindlen = vim.fn.strlen(kind)
    table.insert(highlights, {
      group = "Aerial" .. item.kind .. "Icon",
      row = row,
      col_start = INDENT * item.level,
      col_end = INDENT * item.level + kindlen,
    })
    table.insert(highlights, {
      group = "Aerial" .. item.kind,
      row = row,
      col_start = INDENT * item.level + kindlen,
      col_end = -1,
    })
    max_len = math.max(max_len, text_cols)
    table.insert(lines, text)
    row = row + 1
  end)

  local width = util.set_width(aer_bufnr, max_len)
  util.set_height(aer_bufnr, #lines)

  -- Insert lines into buffer
  for i, line in ipairs(lines) do
    lines[i] = util.rpad(line, width)
  end
  vim.api.nvim_buf_set_option(aer_bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(aer_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(aer_bufnr, "modifiable", false)

  local ns = vim.api.nvim_create_namespace("aerial")
  vim.api.nvim_buf_clear_namespace(aer_bufnr, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(aer_bufnr, ns, hl.group, hl.row - 1, hl.col_start, hl.col_end)
  end
end

-- Update the highlighted lines in the aerial buffer
M.update_highlights = function(buf)
  local hl_mode = config.highlight_mode
  if not hl_mode or hl_mode == "none" then
    return
  end
  local bufnr, aer_bufnr = util.get_buffers(buf)
  if not data:has_symbols(bufnr) or aer_bufnr == -1 then
    return
  end
  local bufdata = data[bufnr]
  local winids = util.get_fixed_wins(bufnr)
  local ns = vim.api.nvim_create_namespace("aerial-line")
  vim.api.nvim_buf_clear_namespace(aer_bufnr, ns, 0, -1)
  if vim.tbl_isempty(winids) then
    return
  end
  local hl_width = math.floor(util.get_width(aer_bufnr) / #winids)

  if hl_mode == "last" then
    local row = data[bufnr].last_position
    vim.api.nvim_buf_add_highlight(aer_bufnr, ns, "AerialLine", row - 1, 0, -1)
    return
  end

  local start_hl = 0
  local end_hl = hl_mode == "full_width" and -1 or hl_width
  for i, winid in ipairs(winids) do
    -- To fix rounding errors when #windows doesn't divide evenly into the
    -- width, make sure the last highlight goes to the end
    if i == #winids then
      end_hl = -1
    end
    vim.api.nvim_buf_add_highlight(
      aer_bufnr,
      ns,
      "AerialLine",
      bufdata.positions[winid].lnum - 1,
      start_hl,
      end_hl
    )
    if hl_mode ~= "full_width" then
      start_hl = end_hl
      end_hl = end_hl + hl_width
    end
  end
end

return M
