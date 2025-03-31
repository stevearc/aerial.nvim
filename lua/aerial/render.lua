local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local highlight = require("aerial.highlight")
local layout = require("aerial.layout")
local loading = require("aerial.loading")
local util = require("aerial.util")
local M = {}

M.clear_buffer = function(bufnr)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.bo[bufnr].modifiable = false
end

-- Resize all windows displaying this aerial buffer
local function resize_all_wins(aer_bufnr, preferred_width, preferred_height)
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
      if not vim.w[winid].aerial_set_width or config.layout.resize_to_content then
        vim.api.nvim_win_set_width(winid, width)
        vim.w[winid].aerial_set_width = true
      end
      vim.b[aer_bufnr].aerial_width = width

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
          local source_winid = util.get_source_win(winid)
          local new_conf = config.float.override(win_conf, source_winid)
          vim.api.nvim_win_set_config(winid, new_conf or win_conf)
        end
      end
    end
  end
  if config.layout.preserve_equality then
    vim.cmd.wincmd({ args = { "=" } })
  end
end

-- Update the aerial buffer from cached symbols
M.update_aerial_buffer = function(buf)
  buf = buf or 0
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end
  local bufnr, aer_bufnr = util.get_buffers(buf)
  if not bufnr or not aer_bufnr or loading.is_loading(aer_bufnr) then
    resize_all_wins(aer_bufnr)
    return
  end
  if not data.has_symbols(bufnr) then
    local lines = { "No symbols" }
    if backends.get(bufnr) then
      if config.lsp.filter_kind ~= false then
        table.insert(lines, ":help aerial-filter")
      end
    else
      table.insert(lines, "")
      for _, status in ipairs(backends.get_status(bufnr)) do
        if not status.supported then
          table.insert(lines, status.name .. " (not supported) [" .. status.error .. "]")
        end
      end
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
  local bufdata = data.get_or_create(bufnr)
  local last_by_level = {}
  for _, item in bufdata:iter({ skip_hidden = true }) do
    last_by_level[item.level] = item.next_sibling == nil
    local collapsed = bufdata:is_collapsed(item)
    local kind = config.get_icon(bufnr, item.kind, collapsed)
    local spacing
    if config.show_guides then
      local last_spacing = 0
      local guides = {}
      for i = 1, item.level do
        local is_last = last_by_level[i]
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
    local icon_hl = highlight.get_highlight(item, true, collapsed)
    if icon_hl then
      table.insert(highlights, {
        group = icon_hl,
        row = row,
        col_start = string_len[spacing],
        col_end = string_len[spacing] + string_len[kind],
      })
    end
    local name_hl = highlight.get_highlight(item, false, collapsed)
    if name_hl then
      table.insert(highlights, {
        group = name_hl,
        row = row,
        col_start = string_len[spacing] + string_len[kind],
        col_end = text:len(),
      })
    end
    max_len = math.max(max_len, text_cols)
    table.insert(lines, text)
    row = row + 1
  end

  resize_all_wins(aer_bufnr, max_len, #lines)

  -- Insert lines into buffer
  vim.bo[aer_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(aer_bufnr, 0, -1, false, lines)
  vim.bo[aer_bufnr].modifiable = false

  local ns = vim.api.nvim_create_namespace("aerial")
  vim.api.nvim_buf_clear_namespace(aer_bufnr, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(aer_bufnr, ns, hl.row - 1, hl.col_start, {
      end_col = hl.col_end,
      hl_group = hl.group,
    })
  end
  M.update_highlights(bufnr)
  vim.b[aer_bufnr].rendered = true
end

M.highlight_line = function(buf, ns, hl_group, row, col, end_col)
  vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
    end_col = end_col ~= -1 and end_col or nil,
    end_row = end_col == -1 and (row + 1) or nil,
    hl_eol = end_col == -1,
    hl_group = hl_group or "AerialLine",
    priority = 4097,
    strict = false,
  })
end

---Update the highlighted lines in the aerial buffer
---@param buf integer
M.update_highlights = function(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end
  local hl_mode = config.highlight_mode
  if not hl_mode or hl_mode == "none" then
    return
  end
  local bufnr, aer_bufnr = util.get_buffers(buf)
  if not bufnr or not data.has_symbols(bufnr) or not aer_bufnr then
    return
  end
  local bufdata = data.get_or_create(bufnr)
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
      M.highlight_line(aer_bufnr, ns, "AerialLine", pos.lnum - 1, 0, -1)
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
      M.highlight_line(aer_bufnr, ns, hl_group, pos.lnum - 1, start_hl, end_hl)
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
    local item = data.get_or_create(0):item(cursor[1])
    if item then
      M.highlight_line(bufnr, ns, "AerialLine", item.lnum - 1, 0, -1)
    end
  end
end

---@param bufnr integer
---@return integer
M.clear_highlights = function(bufnr)
  local ns = vim.api.nvim_create_namespace("aerial-line")
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
  return ns
end

return M
