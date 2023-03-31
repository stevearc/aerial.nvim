local aerial = require("aerial")

local M = {}

M.jump = {
  desc = "Jump to the symbol under the cursor",
  callback = function(nav)
    local symbol = nav:get_current_symbol()
    nav:close()
    if symbol then
      require("aerial.navigation").select_symbol(symbol, nav.winid, nav.bufnr, { jump = true })
    end
  end,
}

M.jump_vsplit = {
  desc = "Jump to the symbol in a vertical split",
  callback = function(nav)
    local symbol = nav:get_current_symbol()
    nav:close()
    if symbol then
      require("aerial.navigation").select_symbol(
        symbol,
        nav.winid,
        nav.bufnr,
        { jump = true, split = "vertical" }
      )
    end
  end,
}

M.jump_split = {
  desc = "Jump to the symbol in a horizontal split",
  callback = function(nav)
    local symbol = nav:get_current_symbol()
    nav:close()
    if symbol then
      require("aerial.navigation").select_symbol(
        symbol,
        nav.winid,
        nav.bufnr,
        { jump = true, split = "horizontal" }
      )
    end
  end,
}

M.left = {
  desc = "Navigate to parent symbol",
  callback = function(nav)
    local symbol = nav:get_current_symbol()
    if symbol and symbol.parent then
      nav:focus_symbol(symbol.parent)
    end
  end,
}

M.right = {
  desc = "Navigate to child symbol",
  callback = function(nav)
    local symbol = nav:get_current_symbol()
    if symbol and symbol.children and not vim.tbl_isempty(symbol.children) then
      nav:focus_symbol(symbol.children[1])
    end
  end,
}

M.close = {
  desc = "Close the nav windows",
  callback = function()
    aerial.nav_close()
  end,
}

return M
