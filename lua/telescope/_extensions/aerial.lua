local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope = require("telescope")

local ext_config = {
  col1_width = 4,
  col2_width = 30,
  -- show_lines = true, -- deprecated in favor of show_columns
  show_columns = "both", -- { "symbols", "lines", "both" }
  format_symbol = function(symbol_path, filetype)
    if filetype == "json" or filetype == "yaml" then
      return table.concat(symbol_path, ".")
    else
      return symbol_path[#symbol_path]
    end
  end,
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

  local show_columns = opts.show_columns or conf.show_columns
  local show_lines = opts.show_lines or conf.show_lines -- show_lines is deprecated
  if show_columns == nil then
    if show_lines == true then
      show_columns = "both"
    elseif show_lines == false then
      show_columns = "symbols"
    else
      show_columns = ext_config.show_columns
    end
  end

  local backend = backends.get()

  if not backend then
    backends.log_support_err()
    return
  elseif not data.has_symbols(0) then
    backend.fetch_symbols_sync(0, opts)
  end

  local layout
  if show_columns == "both" then
    layout = {
      { width = ext_config.col1_width },
      { width = ext_config.col2_width },
      { remaining = true },
    }
  else
    layout = {
      { width = ext_config.col1_width },
      { remaining = true },
    }
  end
  local displayer = opts.displayer
    or entry_display.create({
      separator = " ",
      items = layout,
    })

  local function collect_buf_highlights()
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
      return {}
    end

    local lang = parser:lang()
    local root = parser:trees()[1]:root() -- get root of already parsed cached tree

    local highlights = {}
    local query = vim.treesitter.query.get(lang, "highlights")
    if query then
      for _, captures, _ in query:iter_matches(root, bufnr, 0, -1, { all = false }) do
        for id, node in pairs(captures) do
          local start_row, start_col, _, end_col = node:range()
          highlights[start_row] = highlights[start_row] or {}
          table.insert(highlights[start_row], { start_col, end_col, query.captures[id] })
        end
      end
    end
    return highlights
  end

  local buf_highlights = {}
  if show_columns == "lines" or show_columns == "both" then
    buf_highlights = collect_buf_highlights() -- collect buffer highlights only if needed
  end

  local function highlights_for_row(row, offset)
    offset = offset or 0
    local row_highlights = buf_highlights[row] or {}
    local highlights = {}
    for _, value in ipairs(row_highlights) do
      local start_col, end_col, hl_type = unpack(value)
      hl_type = hl_type:match("^[^.]+") -- strip subtypes after dot
      table.insert(highlights, { { start_col + offset, end_col + offset }, hl_type })
    end
    return highlights
  end

  local function make_display(entry)
    local item = entry.value
    local row = item.lnum - 1

    if show_columns == "lines" then
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
    if show_columns == "both" then
      local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
      table.insert(columns, vim.trim(text))

      local leading_spaces = text:match("^%s*")
      local offset = layout[1].width + layout[2].width - #leading_spaces + #icon
      if #entry.name > layout[2].width then
        offset = offset + 2 -- '...' symbol
      end
      local col1_len = ext_config.col1_width + icon:len() - vim.api.nvim_strwidth(icon)
      local col2_len = ext_config.col2_width + entry.name:len() - vim.api.nvim_strwidth(entry.name)
      highlights = {
        { { 0, col1_len }, icon_hl },
        { { col1_len + 1, col1_len + 1 + col2_len + 1 }, name_hl },
      }
      vim.list_extend(highlights, highlights_for_row(row, offset))
    end

    return displayer(columns), highlights
  end

  local function make_entry(item)
    local name
    if opts.get_entry_text ~= nil then
      name = opts.get_entry_text(item)
    else
      local symbol_path = {}
      local cur = item
      while cur do
        table.insert(symbol_path, 1, cur.name)
        cur = cur.parent
      end
      name = ext_config.format_symbol(symbol_path, filetype)
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

    -- Backwards compatibility shim
    if user_config.show_nesting and not user_config.format_symbol then
      if type(ext_config.show_nesting) ~= "table" then
        ext_config.show_nesting = {
          ["_"] = ext_config.show_nesting,
        }
      end
      ext_config.show_nesting = vim.tbl_deep_extend("keep", ext_config.show_nesting, {
        json = true,
        yaml = true,
      })
      user_config.format_symbol = function(symbol_path, filetype)
        local show_nesting = ext_config.show_nesting[filetype]
        if show_nesting == nil then
          show_nesting = ext_config.show_nesting["_"]
        end
        if show_nesting then
          return table.concat(symbol_path, ".")
        else
          return symbol_path[#symbol_path]
        end
      end
    end
  end,
  exports = {
    aerial = aerial_picker,
  },
})
