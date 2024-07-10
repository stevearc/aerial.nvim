local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope = require("telescope")

local ext_config = {
  only_lines = false,
  show_lines = true,
  show_nesting = {
    ["_"] = false,
    json = true,
    yaml = true,
  },
}

local function aerial_picker(opts)
  opts = opts or {}
  require("aerial").sync_load()
  local backends = require("aerial.backends")
  local config = require("aerial.config")
  local data = require("aerial.data")
  local highlight = require("aerial.highlight")
  local util = require("aerial.util")

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo[bufnr].filetype
  local show_nesting = ext_config.show_nesting[filetype]
  if show_nesting == nil then
    show_nesting = ext_config.show_nesting["_"]
  end
  local backend = backends.get()

  if not backend then
    backends.log_support_err()
    return
  elseif not data.has_symbols(0) then
    backend.fetch_symbols_sync(0, opts)
  end

  local layout
  if ext_config.show_lines then
    layout = {
      { width = 4 },
      { width = 30 },
      { remaining = true },
    }
  else
    layout = {
      { width = 4 },
      { remaining = true },
    }
  end
  local displayer = opts.displayer
    or entry_display.create({
      separator = " ",
      items = layout,
    })

  local function collect_buf_highlights()
    local ts_parsers = require("nvim-treesitter.parsers")
    local ts_query = require("nvim-treesitter.query")

    local lang = vim.bo[bufnr].filetype
    local parser = ts_parsers.get_parser(bufnr, lang)
    local tree = parser:trees()[1] -- get already parsed cached tree
    local root = tree:root()

    local highlights = {}
    local query = ts_query.get_query(lang, 'highlights')
    if query then
      for _, captures, _ in query:iter_matches(root, bufnr, 0, -1) do
        for id, node in pairs(captures) do
          table.insert(highlights, { capture = query.captures[id], range = { node:range() } })
        end
      end
    end
    return highlights
  end
  local buf_highlights = collect_buf_highlights()

  local function highlights_for_row(row, offset)
    offset = offset or 0
    local highlights = {}
    for _, value in ipairs(buf_highlights) do
      local start_row, start_col, end_row, end_col = unpack(value.range)

      if start_row == row then
        local type = value.capture:gsub("%..*", "") -- strip subtypes after dot
        table.insert(highlights, { { start_col + offset, end_col + offset }, type })
      end
    end
    return highlights
  end

  local function make_display(entry)
    local item = entry.value
    local row = item.lnum - 1

    if opts.only_lines or ext_config.only_lines then
      local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
      return text, highlights_for_row(row)
    end

    local icon = config.get_icon(bufnr, item.kind)
    local icon_hl = highlight.get_highlight(item, true, false) or "NONE"
    local name_hl = highlight.get_highlight(item, false, false) or "NONE"
    local columns = {
      { icon, icon_hl },
      { entry.name, name_hl },
    }

    local highlights = {}
    if opts.show_lines or ext_config.show_lines then
      local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
      table.insert(columns, vim.trim(text))

      local leading_spaces = text:match("^%s*")
      local offset = layout[1].width + layout[2].width - #leading_spaces + 5
      if #entry.name > layout[2].width then
        offset = offset + 2
      end
      highlights = highlights_for_row(row, offset)
    end

    return displayer(columns), highlights
  end

  local function make_entry(item)
    local name = item.name
    if opts.get_entry_text ~= nil then
      name = opts.get_entry_text(item)
    else
      if show_nesting then
        local cur = item.parent
        while cur do
          name = string.format("%s.%s", cur.name, name)
          cur = cur.parent
        end
      end
    end
    local lnum = item.selection_range and item.selection_range.lnum or item.lnum
    local col = item.selection_range and item.selection_range.col or item.col
    return {
      value = item,
      display = make_display,
      name = name,
      ordinal = name .. " " .. string.lower(item.kind),
      lnum = lnum,
      col = col + 1,
      filename = filename,
    }
  end

  local results = {}
  local default_selection_index = 1
  if data.has_symbols(0) then
    local bufdata = data.get_or_create(0)
    local position = bufdata.positions[bufdata.last_win]
    for _, item in bufdata:iter({ skip_hidden = false }) do
      table.insert(results, item)
      if item == position.closest_symbol then
        default_selection_index = #results
      end
    end
  end

  -- Reverse the symbols so they have the same top-to-bottom order as in the file
  local sorting_strategy = opts.sorting_strategy or conf.sorting_strategy
  if sorting_strategy == "descending" then
    util.tbl_reverse(results)
    default_selection_index = #results - (default_selection_index - 1)
  end
  pickers
    .new(opts, {
      prompt_title = "Document Symbols",
      finder = finders.new_table({
        results = results,
        entry_maker = make_entry,
      }),
      default_selection_index = default_selection_index,
      sorter = conf.generic_sorter(opts),
      previewer = conf.qflist_previewer(opts),
      push_cursor_on_edit = true,
    })
    :find()
end

return telescope.register_extension({
  setup = function(user_config)
    ext_config = vim.tbl_extend("force", ext_config, user_config or {})
    if type(ext_config.show_nesting) ~= "table" then
      ext_config.show_nesting = {
        ["_"] = ext_config.show_nesting,
      }
    end
  end,
  exports = {
    aerial = aerial_picker,
  },
})
