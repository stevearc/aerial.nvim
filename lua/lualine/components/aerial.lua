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
-- ﴯ MyClassName ⟩  my_method_name
--
-- { "aerial", dense = true }
--  MyClassName.my_method_name
--
-- { "aerial", depth = -1 }
--  my_method_name

local M = require("lualine.component"):extend()
local aerial = require("aerial")
local utils = require("lualine.utils.utils")
local identifiers = require("aerial.highlight").identifiers

local default_options = {
  sep = " ⟩ ",
  depth = nil,
  dense = false,
  dense_sep = ".",
  exact = true,
}

function M:get_highlight(name)
  if vim.fn.hlexists(name) ~= 1 then
    return {}
  end
  local hl_test = vim.api.nvim_get_hl_by_name(name, true)
  -- Linked to NONE
  if hl_test[true] == 6 then
    return {}
  end
  for _, key in pairs({ "foreground", "background", "special" }) do
    if hl_test[key] then
      hl_test[key] = string.format("%06x", hl_test[key])
    end
  end
  return hl_test
end

function M:color_for_lualine()
  self.highlight_groups = {}
  for _, symbol_kind in ipairs(identifiers) do
    hl = "Aerial" .. symbol_kind
    hl_icon = "Aerial" .. symbol_kind .. "Icon"
    local color = { fg = self:get_highlight(hl).foreground }
    local color_icon = { fg = self:get_highlight(hl_icon).foreground }
    self.highlight_groups[symbol_kind] = {
      icon = self:create_hl(color_icon, symbol_kind .. "Icon"),
      text = self:create_hl(color, symbol_kind),
    }
  end
end

function M:color_icon(symbol_kind, icon, colored)
  if colored then
    local hl = self:format_hl(self.highlight_groups[symbol_kind].icon)
    return string.format("%s%s", hl, icon)
  else
    return icon
  end
end

function M:color(symbol_kind, text, colored)
  if colored then
    local hl = self:format_hl(self.highlight_groups[symbol_kind].text)
    return string.format("%s%s", hl, text)
  else
    return text
  end
end

function M:format_status(symbols, depth, separator, icons_enabled, colored)
  local parts = {}
  depth = depth or #symbols

  if depth > 0 then
    symbols = { unpack(symbols, 1, depth) }
  else
    symbols = { unpack(symbols, #symbols + 1 + depth) }
  end

  for _, symbol in ipairs(symbols) do
    local name = self:color(symbol.kind, symbol.name, colored)
    if icons_enabled then
      local icon = self:color_icon(symbol.kind, symbol.icon, colored)
      table.insert(parts, string.format("%s %s", icon, name))
    else
      table.insert(parts, name)
    end
  end
  return table.concat(parts, separator)
end

function M:init(options)
  M.super.init(self, options)

  self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
  if self.options.colored == nil then
    self.options.colored = true
  end
  if self.options.colored then
    require("aerial.highlight").create_highlight_groups()
    self:color_for_lualine()
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Update lualine aerial component colors",
      pattern = "*",
      callback = function()
        require("aerial.highlight").create_highlight_groups()
        self:color_for_lualine()
      end,
    })
  end
  self.get_status = self.get_status_normal

  if self.options.dense then
    self.get_status = self.get_status_dense
  end
end

function M:update_status()
  return self:get_status()
end

function M:get_status_normal()
  local symbols = aerial.get_location(self.options.exact)
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
  local symbols = aerial.get_location(self.options.exact)
  local status = self:format_status(
    symbols,
    self.options.depth,
    self.options.dense_sep,
    -- In dense mode icons aren't rendered togeter with symbols. A single icon
    -- at the beginning of status line is rendered instead. See below.
    false
  )

  if self.options.icons_enabled and not vim.tbl_isempty(symbols) then
    local symbol = symbols[#symbols]
    local icon = color_icon(symbol.kind, symbol.icon, self.options.colored)
    status = string.format("%s %s", icon, status)
  end
  return status
end

return M
