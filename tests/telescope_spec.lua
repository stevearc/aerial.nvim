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
    local sibling = {
      name = "another_method",
      kind = "Method",
      level = 1,
      lnum = 3,
      col = 0,
      end_lnum = 3,
      end_col = 14,
      parent = parent,
    }
    parent.children = { child, sibling }
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
    local parent_entry = entries[3]
    local child_entry = entries[2]
    local parent_display = parent_entry:display({})
    local child_display = child_entry:display({})
    assert.equals(5, parent_display:find("MyStruct", 1, true))
    assert.equals(7, child_display:find("target_method", 1, true))
    assert.equals("MyStruct", parent_entry.name)
    assert.equals("target_method", child_entry.name)

    assert.equals("MyStruct struct target_method another_method", parent_entry.ordinal)

    local sorter = captured_picker.sorter
    sorter:_init()
    sorter:_start("target_method")
    local added = {}
    for _, entry in ipairs(entries) do
      sorter:score("target_method", entry, function(_, result)
        table.insert(added, result)
      end, function() end)
    end
    assert.same({ child_entry, parent_entry }, added)
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
    local child_display = entries[2]:display({})
    assert.equals(5, child_display:find("target_method", 1, true))
    assert.equals("MyStruct struct", entries[3].ordinal)
  end)

  it("preserves a custom sorter", function()
    local calls = 0
    local sorter = require("telescope.sorters").Sorter:new({
      scoring_function = function(_, prompt, ordinal)
        calls = calls + 1
        return ordinal:find(prompt, 1, true) and 0 or -1
      end,
    })
    require("telescope").extensions.aerial.aerial({
      show_columns = "symbols",
      sorter = sorter,
    })

    local entries = captured_picker.finder.results
    local added = {}
    captured_picker.sorter:_init()
    captured_picker.sorter:_start("target_method")
    for _, entry in ipairs(entries) do
      captured_picker.sorter:score("target_method", entry, function(_, result)
        table.insert(added, result)
      end, function() end)
    end
    assert.equals(3, calls)
    assert.equals(entries[2], added[1])
    assert.equals(entries[3], added[2])
  end)
end)
