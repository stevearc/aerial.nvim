local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope = require("telescope")

local ext_config = {
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
  local util = require("aerial.util")

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(0)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
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

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 4 },
      { width = 30 },
      { remaining = true },
    },
  })

  local function make_display(entry)
    local item = entry.value
    local icon = config.get_icon(bufnr, item.kind)
    local text = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1] or ""
    text = vim.trim(text)
    local columns = {
      { icon, "Aerial" .. item.kind .. "Icon" },
      { entry.name, "Aerial" .. item.kind },
      text,
    }
    return displayer(columns)
  end

  local function make_entry(item)
    local name = item.name
    if show_nesting then
      local cur = item.parent
      while cur do
        name = string.format("%s.%s", cur.name, name)
        cur = cur.parent
      end
    end
    return {
      value = item,
      display = make_display,
      name = name,
      ordinal = name .. " " .. string.lower(item.kind),
      lnum = item.lnum,
      col = item.col + 1,
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
  util.tbl_reverse(results)
  default_selection_index = #results - (default_selection_index - 1)
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
