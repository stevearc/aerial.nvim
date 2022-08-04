local config = require("aerial.config")
local data = require("aerial.data")
local layout = require("aerial.layout")
local loading = require("aerial.loading")
local util = require("aerial.util")
local M = {}

M.clear_buffer = function(bufnr)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- Resize all windows displaying this aerial buffer
local function resize_all_wins(aer_bufnr, preferred_width, preferred_height)
  local max_width = 0
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(winid) == aer_bufnr then
      local relative = "editor"
      local parent_win = 0
      if util.is_floating_win(winid) then
        local win_conf = vim.api.nvim_win_get_config(winid)
        local ok, v = pcall(vim.api.nvim_win_get_var, winid, "relative")
        if ok then
          relative = v
        else
          relative = win_conf.relative
        end
        parent_win = win_conf.win
      end

      -- preferred width can be nil if symbols are loading
      local pw = preferred_width
      local gutter = util.win_get_gutter_width(winid)
      if pw then
        pw = pw + gutter
      end
      local width = layout.calculate_width(relative, pw, config.layout, parent_win)
      -- Subtract the gutter here because it is passed back to be used for
      -- padding out whitespace. The gutter needs to adjust the total window
      -- size, but it doesn't take space away from the content.
      max_width = math.max(max_width, width - gutter)
      vim.api.nvim_win_set_width(winid, width)
      util.save_width(winid, width)

      -- Reposition floating windows
      if util.is_floating_win(winid) then
        local height = layout.calculate_height(relative, preferred_height, config.float, parent_win)
        vim.api.nvim_win_set_height(winid, height)
        if relative ~= "cursor" then
          local row = layout.calculate_row(relative, height, parent_win)
          local col = layout.calculate_col(relative, width, parent_win)
          local win_conf = {
            row = row,
            col = col,
            relative = relative,
            win = parent_win,
          }
          local new_conf = config.float.override(win_conf)
          vim.api.nvim_win_set_config(winid, new_conf or win_conf)
        end
      end
    end
  end
  return max_width
end

-- Update the aerial buffer from cached symbols
M.update_aerial_buffer = function(buf)
  local bufnr, aer_bufnr = util.get_buffers(buf)
  if aer_bufnr == -1 or loading.is_loading(aer_bufnr) then
    resize_all_wins(aer_bufnr)
    return
  end
  if not data:has_symbols(bufnr) then
    local lines = { "No symbols" }
    if config.lsp.filter_kind ~= false then
      table.insert(lines, ":help aerial-filter")
    end
    resize_all_wins(aer_bufnr)
    util.render_centered_text(aer_bufnr, lines)
    return
  end
  local row = 1
  local max_len = 1
  local lines = {}
  local highlights = {}
  local string_len = setmetatable({}, {
    __index = function(t, kind)
      local len = vim.fn.strlen(kind)
      t[kind] = len
      return len
    end,
  })
  data[bufnr]:visit(function(item, conf)
    local kind = config.get_icon(bufnr, item.kind, conf.collapsed)
    local spacing
    if config.show_guides then
      local last_spacing = 0
      local guides = {}
      for i = 1, item.level do
        local is_last = conf.is_last_by_level[i]
        if i == item.level then
          if is_last then
            table.insert(guides, config.guides.last_item)
          else
            table.insert(guides, config.guides.mid_item)
          end
        else
          if is_last then
            table.insert(guides, config.guides.whitespace)
          else
            table.insert(guides, config.guides.nested_top)
          end
        end
        local hl_end = last_spacing + string_len[guides[i]]
        table.insert(highlights, {
          group = string.format("AerialGuide%d", i),
          row = row,
          col_start = last_spacing,
          col_end = hl_end,
        })
        last_spacing = hl_end
      end
      spacing = table.concat(guides, "")
    else
      spacing = string.rep("  ", item.level)
    end
    local text = util.remove_newlines(string.format("%s%s %s", spacing, kind, item.name))
    local text_cols = vim.api.nvim_strwidth(text)
    table.insert(highlights, {
      group = "Aerial" .. item.kind .. "Icon",
      row = row,
      col_start = string_len[spacing],
      col_end = string_len[spacing] + string_len[kind],
    })
    table.insert(highlights, {
      group = "Aerial" .. item.kind,
      row = row,
      col_start = string_len[spacing] + string_len[kind],
      col_end = -1,
    })
    max_len = math.max(max_len, text_cols)
    table.insert(lines, text)
    row = row + 1
  end)

  local width = resize_all_wins(aer_bufnr, max_len, #lines)

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
  M.update_highlights(bufnr)
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
  -- Take out any winids that don't have position data
  winids = vim.tbl_filter(function(wid)
    return bufdata.positions[wid]
  end, winids)
  local ns = M.clear_highlights(aer_bufnr)
  if vim.tbl_isempty(winids) then
    return
  end
  local line = vim.api.nvim_buf_get_lines(aer_bufnr, 0, 1, true)[1]
  local hl_width = math.floor(vim.api.nvim_strwidth(line) / #winids)

  if hl_mode == "last" then
    local pos = bufdata.positions[bufdata.last_win]
    if pos and (config.highlight_closest or pos.exact_symbol) then
      vim.api.nvim_buf_add_highlight(aer_bufnr, ns, "AerialLine", pos.lnum - 1, 0, -1)
    end
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
    local pos = bufdata.positions[winid]
    if config.highlight_closest or pos.exact_symbol then
      local hl_group = winid == bufdata.last_win and "AerialLine" or "AerialLineNC"
      vim.api.nvim_buf_add_highlight(aer_bufnr, ns, hl_group, pos.lnum - 1, start_hl, end_hl)
    end
    if hl_mode ~= "full_width" then
      start_hl = end_hl
      end_hl = end_hl + hl_width
    end
  end

  -- If we're in the aerial buffer, update highlight line in the source buffer
  if config.highlight_on_hover and aer_bufnr == vim.api.nvim_get_current_buf() then
    M.clear_highlights(bufnr)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local item = data[0]:item(cursor[1])
    vim.api.nvim_buf_add_highlight(bufnr, ns, "AerialLine", item.lnum - 1, 0, -1)
  end
end

M.clear_highlights = function(buf)
  local ns = vim.api.nvim_create_namespace("aerial-line")
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  return ns
end

return M
