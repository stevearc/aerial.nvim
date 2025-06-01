local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local highlight = require("aerial.highlight")
local M = {}
---@module 'snacks.picker'

---@param opts? snacks.picker.Config
M.pick_symbol = function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local backend = backends.get()

  if not backend then
    backends.log_support_err()
    return
  elseif not data.has_symbols(bufnr) then
    backend.fetch_symbols_sync(bufnr, {})
  end

  if not data.has_symbols(bufnr) then
    vim.notify("No symbols found in buffer", vim.log.levels.WARN)
    return
  end

  local default_selection_index = 1
  ---@type aerial.BufData
  local bufdata = data.get_or_create(bufnr)
  local position = bufdata.positions[bufdata.last_win]
  ---@type snacks.picker.finder.Item[]
  local items = {}
  ---@type table<snacks.picker.finder.Item, snacks.picker.finder.Item>
  local last = {}
  for i, item in bufdata:iter({ skip_hidden = false }) do
    local snack_item = {
      idx = i,
      file = filename,
      item = item,
      text = item.name,
      pos = { item.lnum, item.col },
      end_pos = { item.end_lnum, item.end_col },
    }
    if item.parent then
      local parent = items[item.parent.idx]
      snack_item.parent = parent
      if last[parent] then
        last[parent].last = nil
      end
      last[parent] = snack_item
      snack_item.last = true
    end
    if item == position.closest_symbol then
      default_selection_index = (#items + 1)
    end
    table.insert(items, snack_item)
  end

  return Snacks.picker(vim.tbl_extend("keep", opts or {}, {
    title = "Symbols",
    items = items,
    sort = {
      fields = { "idx" },
    },
    format = function(item, picker)
      ---@type aerial.Symbol
      local symbol = item.item
      local icon = config.get_icon(bufnr, symbol.kind)
      local icon_hl = highlight.get_highlight(symbol, true, false) or "NONE"

      local ret = {} ---@type snacks.picker.Highlight[]
      vim.list_extend(ret, Snacks.picker.format.tree(item, picker))
      table.insert(ret, { icon .. " ", icon_hl })
      Snacks.picker.highlight.format(item, item.text, ret)

      return ret
    end,
    on_show = function(picker)
      picker.list.cursor = default_selection_index
    end,
  }))
end

return M
