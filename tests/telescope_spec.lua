local config = require("aerial.config")
local data = require("aerial.data")

describe("telescope extension", function()
  local original_picker_new
  local original_backend_get
  local captured_picker

  before_each(function()
    config.setup({ nerd_font = false, use_icon_provider = false })
    original_picker_new = require("telescope.pickers").new
    require("telescope.pickers").new = function(_, picker)
      captured_picker = picker
      return { find = function() end }
    end
    original_backend_get = require("aerial.backends").get
    require("aerial.backends").get = function()
      return {}
    end
    package.loaded["telescope._extensions.aerial"] = nil
    require("telescope").setup({ extensions = { aerial = {} } })
    require("telescope").load_extension("aerial")

    local parent = {
      name = "MyStruct",
      kind = "Struct",
      level = 0,
      lnum = 1,
      col = 0,
      end_lnum = 3,
      end_col = 0,
      children = {},
    }
    local child = {
      name = "target_method",
      kind = "Method",
      level = 1,
      lnum = 2,
      col = 0,
      end_lnum = 2,
      end_col = 13,
      parent = parent,
    }
    parent.children = { child }
    data.set_symbols(0, { parent })
  end)

  after_each(function()
    require("telescope.pickers").new = original_picker_new
    require("aerial.backends").get = original_backend_get
  end)

  it("indents nested symbols and keeps parents of search matches", function()
    require("telescope").extensions.aerial.aerial({
      show_columns = "symbols",
      displayer = function(columns)
        return columns[1][1] .. " " .. columns[2][1]
      end,
    })

    local entries = captured_picker.finder.results
    local parent_entry = entries[2]
    local child_entry = entries[1]
    local parent_display = parent_entry:display({})
    local child_display = child_entry:display({})
    assert.equals(5, parent_display:find("MyStruct", 1, true))
    assert.equals(7, child_display:find("target_method", 1, true))

    local sorter = captured_picker.sorter
    sorter:_init()
    sorter:_start("target_method")
    local added = {}
    local add = function(score, entry)
      table.insert(added, { entry = entry, score = score })
    end
    sorter:score("target_method", child_entry, add, function() end)
    sorter:score("target_method", parent_entry, add, function() end)
    assert.equals(child_entry, added[1].entry)
    assert.equals(parent_entry, added[2].entry)
    assert.is_true(added[1].score < added[2].score)
  end)

  it("supports disabling hierarchy", function()
    require("telescope").extensions.aerial.aerial({
      show_columns = "symbols",
      show_hierarchy = false,
      displayer = function(columns)
        return columns[1][1] .. " " .. columns[2][1]
      end,
    })

    local entries = captured_picker.finder.results
    local child_display = entries[1]:display({})
    assert.equals(5, child_display:find("target_method", 1, true))
  end)

end)
