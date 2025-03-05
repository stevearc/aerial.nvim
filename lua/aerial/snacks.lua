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

  local bufdata = data.get_or_create(bufnr)
  ---@type snacks.picker.finder.Item[]
  local items = {}
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
      snack_item.parent = items[item.parent.idx]
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
  }))
end

return M
