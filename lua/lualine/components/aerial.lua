-- ## Usage
--
-- Just specify "aerial" component in one of your lualine sections.
-- For example:
--
--   require("lualine").setup({
--     sections = {
--       lualine_x = { "aerial" },
--     },
--   })
--
-- ## Options
--
-- *sep* (default: " ⟩ ")
--   The separator to be used to separate symbols in status line.
--
-- *sep_prefix* (default: false)
--   Prefix the separator before the first symbol. Useful if you have another
--   component before aerial that shows the file path.
--
-- *sep_highlight* (default: "NonText")
--   The separator highlight group.
--
-- *sep_icon* (default: " ")
--   The separator between the icon and the symbol name (when icons are enabled).
--
-- *depth* (default: nil)
--   The number of symbols to render top-down. In order to render only 'N' last
--   symbols, negative numbers may be supplied. For instance, 'depth = -1' can
--   be used in order to render only current symbol.
--
-- *dense* (default: false)
--   When 'dense' mode is on, icons are not rendered near their symbols. Only
--   a single icon that represents the kind of current symbol is rendered at
--   the beginning of status line.
--
-- *dense_sep* (default: ".")
--   The separator to be used to separate symbols in dense mode. Normally does
--   not contain spaces to increase density.
--
-- *colored* (default: true)
--   Color the symbol icons.
--
-- ## Examples
--
-- { "aerial" }
-- 󰠱 MyClassName ⟩ 󰆧 my_method_name
--
-- { "aerial", dense = true }
-- 󰆧 MyClassName.my_method_name
--
-- { "aerial", depth = -1 }
-- 󰆧 my_method_name

local M = require("lualine.component"):extend()
local utils = require("lualine.utils.utils")

local default_options = {
  sep = " ⟩ ",
  sep_prefix = false,
  sep_highlight = "NonText",
  sep_icon = " ",
  depth = nil,
  dense = false,
  dense_sep = ".",
  exact = true,
}

function M:format_status(symbols, depth, separator, icons_enabled, colored)
  local parts = {}
  depth = depth or #symbols

  if depth > 0 then
    symbols = { unpack(symbols, 1, depth) }
  else
    symbols = { unpack(symbols, #symbols + 1 + depth) }
  end

  for _, symbol in ipairs(symbols) do
    local hl_group = self:get_hl_group(symbol, false)
    local name = self:color_text(utils.stl_escape(symbol.name), hl_group)
    if icons_enabled then
      hl_group = self:get_hl_group(symbol, true)
      local icon = self:color_text(symbol.icon, hl_group)
      table.insert(parts, string.format("%s%s%s", icon, self.options.sep_icon, name))
    else
      table.insert(parts, name)
    end
  end

  local prefix = ""
  if #parts > 0 and self.options.sep_prefix then
    -- Trim leading whitespace
    prefix = self:color_text(separator:match("^%s*(.*)"), self.options.sep_highlight)
  end
  return prefix .. table.concat(parts, self:color_text(separator, self.options.sep_highlight))
end

function M:init(options)
  M.super.init(self, options)

  self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
  if self.options.colored == nil then
    self.options.colored = true
  end
  self.highlight_groups = {}
  self.get_status = self.get_status_normal

  if self.options.dense then
    self.get_status = self.get_status_dense
  end
end

---@param symbol aerial.Symbol
---@param is_icon boolean
---@return string|nil
function M:get_hl_group(symbol, is_icon)
  return require("aerial.highlight").get_highlight(symbol, is_icon, false)
end

---@param text string
---@param hl_group string|nil
---@return string
function M:color_text(text, hl_group)
  if not self.options.colored or hl_group == nil or hl_group == "" then
    return text
  end
  local lualine_hl_group = self.highlight_groups[hl_group]
  if not lualine_hl_group then
    lualine_hl_group =
      self:create_hl({ fg = utils.extract_highlight_colors(hl_group, "fg") }, "LL" .. hl_group)
    self.highlight_groups[hl_group] = lualine_hl_group
  end
  return self:format_hl(lualine_hl_group) .. text .. self:get_default_hl()
end

function M:update_status()
  return self:get_status()
end

function M:get_status_normal()
  local symbols = require("aerial").get_location(self.options.exact)
  local status = self:format_status(
    symbols,
    self.options.depth,
    self.options.sep,
    self.options.icons_enabled,
    self.options.colored
  )
  return status
end

function M:get_status_dense()
  local symbols = require("aerial").get_location(self.options.exact)
  local status = self:format_status(
    symbols,
    self.options.depth,
    self.options.dense_sep,
    -- In dense mode icons aren't rendered together with symbols. A single icon
    -- at the beginning of status line is rendered instead. See below.
    false,
    self.options.colored
  )

  if self.options.icons_enabled and not vim.tbl_isempty(symbols) then
    local symbol = symbols[#symbols]
    local hl_group = self:get_hl_group(symbol, true)
    local icon = self:color_text(symbol.icon, hl_group)
    status = string.format("%s %s", icon, status)
  end
  return status
end

return M
