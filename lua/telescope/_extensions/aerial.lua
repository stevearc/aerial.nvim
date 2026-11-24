local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local telescope = require("telescope")

local ext_config = {
  col1_width = 4,
  col2_width = 30,
  show_hierarchy = true,
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

local function get_symbol_path(item)
  local path = {}
  while item do
    table.insert(path, 1, item)
    item = item.parent
  end
  return path
end

local function get_nesting_prefix(item)
  return string.rep("  ", item.level)
end

local function resolve_filetype_flag(value, filetype)
  if type(value) ~= "table" then
    return value
  end
  if value[filetype] ~= nil then
    return value[filetype]
  end
  return value["_"]
end

local function get_root(item)
  while item.parent do
    item = item.parent
  end
  return item
end

-- Results are reversed for Telescope's default descending layout, so children
-- are scored before their parents. Delay matching children until their root is
-- processed, then emit the filtered subtree as a single score group. Telescope
-- reverses the scored results for display, leaving every context parent directly
-- above its matching descendants.
local function with_parent_matches(sorter)
  return sorters.Sorter:new({
    init = function(self)
      self.state.groups = {}
      if sorter._init then
        sorter:_init()
      end
    end,
    start = function(self, prompt)
      if sorter._start then
        sorter:_start(prompt)
      end
      self.state.groups = {}
    end,
    finish = function(self, prompt)
      if sorter._finish then
        sorter:_finish(prompt)
      end
    end,
    destroy = function()
      if sorter._destroy then
        sorter:_destroy()
      end
    end,
    scoring_function = function(self, prompt, ordinal, entry, cb_add)
      local score = sorter:scoring_function(prompt, ordinal, entry, cb_add)
      if prompt == "" then
        return score
      end

      local item = entry.value
      local root = get_root(item)
      local group = self.state.groups[root]
      if not group then
        group = { entries = {}, needed = {} }
        self.state.groups[root] = group
      end

      if score ~= nil and score >= 0 then
        group.needed[item] = true
        if group.score == nil or score < group.score then
          group.score = score
        end
        local parent = item.parent
        while parent do
          group.needed[parent] = true
          parent = parent.parent
        end
      end

      if item.parent then
        if group.needed[item] then
          table.insert(group.entries, entry)
        end
        return -1
      end

      if group.needed[item] and cb_add then
        local group_score = group.score - (item.idx * 1e-9)
        for i, child_entry in ipairs(group.entries) do
          cb_add(group_score + ((i - 1) * 1e-12), child_entry)
        end
        cb_add(group_score + (#group.entries * 1e-12), entry)
      end
      self.state.groups[root] = nil
      if group.needed[item] then
        return -1
      else
        return score
      end
    end,
    highlighter = function(_, ...)
      if sorter.highlighter then
        return sorter:highlighter(...)
      end
    end,
  })
end

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

  local show_hierarchy = opts.show_hierarchy
  if show_hierarchy == nil then
    show_hierarchy = ext_config.show_hierarchy
  end
  show_hierarchy = resolve_filetype_flag(show_hierarchy, filetype)
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
      for _, captures, _ in query:iter_matches(root, bufnr, 0, -1) do
        for id, nodes in pairs(captures) do
          for _, node in ipairs(nodes) do
            local start_row, start_col, _, end_col = node:range()
            highlights[start_row] = highlights[start_row] or {}
            table.insert(highlights[start_row], { start_col, end_col, query.captures[id] })
          end
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

    local nesting_prefix = show_hierarchy and get_nesting_prefix(item) or ""
    local icon = nesting_prefix .. config.get_icon(bufnr, item.kind)
    local icon_hl = highlight.get_highlight(item, true, false) or "NONE"
    local name_hl = highlight.get_highlight(item, false, false) or "NONE"
    local columns = {
      { icon, icon_hl },
      { entry.name, name_hl },
    }

    if show_columns == "symbols" then
      return displayer(columns)
    end

    -- default: show_columns == "both"
    local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local trimmed_text = vim.trim(text)
    table.insert(columns, trimmed_text)

    local display_columns, highlights = displayer(columns)

    local text_start = display_columns:find(trimmed_text, 1, true) or 1
    local leading_spaces = text:match("^%s*") or ""
    local offset = text_start - 1 - #leading_spaces
    vim.list_extend(highlights, highlights_for_row(row, offset))

    return display_columns, highlights
  end

  local function make_entry(item)
    local name
    if opts.get_entry_text ~= nil then
      name = opts.get_entry_text(item)
    else
      local symbol_path = vim.tbl_map(function(symbol)
        return symbol.name
      end, get_symbol_path(item))
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
      if position and item == position.closest_symbol then
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
  local sorter = opts.sorter or conf.generic_sorter(opts)
  if show_hierarchy and sorting_strategy == "descending" then
    sorter = with_parent_matches(sorter)
  end
  opts = vim.tbl_extend("force", {}, opts, { sorter = sorter })
  pickers
    .new(opts, {
      prompt_title = "Document Symbols",
      finder = finders.new_table({
        results = results,
        entry_maker = make_entry,
      }),
      default_selection_index = default_selection_index,
      sorter = sorter,
      previewer = conf.qflist_previewer(opts),
      push_cursor_on_edit = true,
    })
    :find()
end

return telescope.register_extension({
  setup = function(user_config)
    user_config = user_config or {}
    ext_config = vim.tbl_extend("force", ext_config, user_config or {})

    -- Backwards compatibility shim
    if user_config.show_nesting and not user_config.format_symbol then
      local legacy_show_nesting = user_config.show_nesting
      if type(legacy_show_nesting) ~= "table" then
        legacy_show_nesting = {
          ["_"] = legacy_show_nesting,
        }
      end
      legacy_show_nesting = vim.tbl_deep_extend("keep", legacy_show_nesting, {
        json = true,
        yaml = true,
      })
      ext_config.format_symbol = function(symbol_path, filetype)
        local show_nesting = legacy_show_nesting[filetype]
        if show_nesting == nil then
          show_nesting = legacy_show_nesting["_"]
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
