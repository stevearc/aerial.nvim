local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")
local highlight = require("aerial.highlight")

local fzf_lua = require("fzf-lua")
local make_entry = require("fzf-lua.make_entry")
local utils = require("fzf-lua.utils")

local M = {}

---@param opts? table
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
  ---@type table[]
  local items = {}
  ---@type table<table, table>
  local last = {}
  for i, symbol in bufdata:iter({ skip_hidden = false }) do
    local item = {
      idx = i,
      filename = filename,
      path = filename,
      symbol = symbol,
      lnum = symbol.lnum,
      col = symbol.col,
    }
    if symbol.parent then
      local parent = items[symbol.parent.idx]
      item.parent = parent
      if last[parent] then
        last[parent].last = nil
      end
      last[parent] = item
      item.last = true
    end
    if symbol == position.closest_symbol then
      default_selection_index = (#items + 1)
    end

    table.insert(items, item)
  end

  -- generate formatted entries with icons for the tree structure
  -- adapted from `Snacks.picker.format.tree()`
  local entries = {}
  for _, item in ipairs(items) do
    local indent = {}
    local node = item
    while node and node.parent do
      local icon
      if node ~= item then
        icon = node.last and "  " or "│ "
      else
        icon = node.last and "└╴" or "├╴"
      end
      table.insert(indent, 1, icon)
      node = node.parent
    end

    item.text = string.format(
      "%s%s%s%s%s",
      utils.nbsp,
      utils.ansi_from_hl("FzfLuaBufLineNr", table.concat(indent, "")),
      utils.ansi_from_hl(
        highlight.get_highlight(item.symbol, true, false),
        config.get_icon(bufnr, item.symbol.kind)
      ),
      utils.nbsp,
      item.symbol.name
    )

    table.insert(entries, make_entry.lcol(item, {}))
  end

  fzf_lua.fzf_exec(
    entries,
    vim.tbl_deep_extend("force", {
      actions = fzf_lua.defaults.actions.files,
      previewer = "builtin",
      winopts = {
        title = " Symbols ",
      },
      fzf_opts = {
        ["--multi"] = true,
        ["--layout"] = "reverse-list",
        ["--delimiter"] = string.format("[%s]", utils.nbsp),
        ["--with-nth"] = "2..",
      },
      keymap = {
        fzf = {
          load = string.format("pos(%d)", default_selection_index),
        },
      },
      _fmt = {
        from = function(text)
          -- replace invisible spaces so fzf-lua can correctly detect the file location
          return text:gsub(utils.nbsp, " ")
        end,
      },
    }, opts or {})
  )
end

return M
