local config = require("aerial.config")
local data = require("aerial.data")
local window = require("aerial.window")

describe("symbol positions", function()
  before_each(function()
    config.setup()
  end)
  it("cursor above first symbol", function()
    local sym = {
      kind = "Function",
      name = "my_func",
      level = 1,
      lnum = 8,
      end_lnum = 10,
      col = 0,
      end_col = 3,
    }
    data.set_symbols(0, { sym })
    local bufdata = data.get_or_create(0)
    local ret = window.get_symbol_position(bufdata, 1, 0)
    assert.are.same({ lnum = 1, closest_symbol = sym, relative = "above" }, ret)
  end)
  it("cursor below last symbol", function()
    local sym = {
      kind = "Function",
      name = "my_func",
      level = 1,
      lnum = 8,
      end_lnum = 10,
      col = 0,
      end_col = 3,
    }
    data.set_symbols(0, { sym })
    local bufdata = data.get_or_create(0)
    local ret = window.get_symbol_position(bufdata, 12, 0)
    assert.are.same({ lnum = 1, closest_symbol = sym, relative = "below" }, ret)
  end)
  it("cursor between symbols", function()
    local sym = {
      kind = "Function",
      name = "my_func",
      level = 1,
      lnum = 8,
      end_lnum = 10,
      col = 0,
      end_col = 3,
    }
    local sym2 = {
      kind = "Function",
      name = "other_func",
      level = 1,
      lnum = 14,
      end_lnum = 15,
      col = 0,
      end_col = 3,
    }
    data.set_symbols(0, { sym, sym2 })
    local bufdata = data.get_or_create(0)
    local ret = window.get_symbol_position(bufdata, 12, 0)
    assert.are.same({ lnum = 1, closest_symbol = sym, relative = "below" }, ret)
  end)
  it("cursor exactly on symbol", function()
    local sym = {
      kind = "Function",
      name = "my_func",
      level = 1,
      lnum = 8,
      end_lnum = 10,
      col = 0,
      end_col = 3,
    }
    data.set_symbols(0, { sym })
    local bufdata = data.get_or_create(0)
    local ret = window.get_symbol_position(bufdata, 8, 0)
    assert.are.same({ lnum = 1, closest_symbol = sym, exact_symbol = sym, relative = "exact" }, ret)
  end)
  it("cursor on parent symbol", function()
    local sym = {
      kind = "Function",
      name = "my_func",
      level = 2,
      lnum = 8,
      end_lnum = 10,
      col = 0,
      end_col = 3,
    }
    local parent = {
      kind = "Class",
      name = "my_class",
      level = 1,
      lnum = 6,
      end_lnum = 12,
      col = 0,
      end_col = 3,
      children = { sym },
    }
    sym.parent = parent
    data.set_symbols(0, { parent })
    local bufdata = data.get_or_create(0)
    local ret = window.get_symbol_position(bufdata, 11, 0)
    assert.are.same(
      { lnum = 2, closest_symbol = sym, exact_symbol = parent, relative = "below" },
      ret
    )
  end)
  it("uses selection_range to detect position", function()
    local var1 = {
      kind = "Variable",
      name = "var1",
      level = 1,
      lnum = 8,
      end_lnum = 11,
      col = 0,
      end_col = 3,
      selection_range = {
        lnum = 9,
        col = 0,
        end_lnum = 9,
        end_col = 12,
      },
    }
    local var2 = {
      kind = "Variable",
      name = "var2",
      level = 1,
      lnum = 8,
      end_lnum = 11,
      col = 0,
      end_col = 3,
      selection_range = {
        lnum = 10,
        col = 0,
        end_lnum = 10,
        end_col = 12,
      },
    }
    data.set_symbols(0, { var1, var2 })
    local bufdata = data.get_or_create(0)
    local ret = window.get_symbol_position(bufdata, 10, 6)
    assert.are.same(
      { lnum = 2, closest_symbol = var2, exact_symbol = var2, relative = "below" },
      ret
    )
  end)
end)
