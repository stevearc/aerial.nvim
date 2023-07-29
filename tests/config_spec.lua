local config = require("aerial.config")

local function reset()
  package.loaded["aerial.config"] = nil
  config = require("aerial.config")
end

describe("config", function()
  before_each(function()
    reset()
  end)

  it("falls back to default options", function()
    config.setup()
    assert.equals(config.attach_mode, "window")
  end)

  -- Filetype maps
  it("reads the default value for filetype map option", function()
    config.setup()
    assert.equals(config.open_automatic(0), false)
  end)
  it("reads the filetype default value for filetype map option", function()
    config.setup({
      manage_folds = {
        ["_"] = true,
      },
    })
    assert.equals(config.manage_folds(0), true)
  end)
  it("reads the filetype value for filetype map option", function()
    config.setup({
      manage_folds = {
        fake_ft = true,
      },
    })
    vim.api.nvim_buf_set_option(0, "filetype", "fake_ft")
    assert.equals(config.manage_folds(0), true)
  end)
  it("reads the filetype value when using a compound filetype", function()
    config.setup({
      manage_folds = {
        fake_ft = true,
      },
    })
    vim.api.nvim_buf_set_option(0, "filetype", "fake_ft.extension")
    assert.equals(config.manage_folds(0), true)
  end)

  it("Calls the open_automatic function", function()
    config.setup({
      open_automatic = function()
        return true
      end,
    })
    assert.equals(config.open_automatic(), true)
  end)

  -- Filter kind
  it("reads the filter_kind option", function()
    config.setup({
      filter_kind = { "Function" },
    })
    local fk = config.get_filter_kind_map(0)
    assert.equals(nil, fk.Class)
    assert.equals(true, fk.Function)
  end)
  it("reads the filter_kind option from filetype map", function()
    config.setup({
      filter_kind = { foo = { "Function" } },
    })
    vim.api.nvim_buf_set_option(0, "filetype", "foo")
    local fk = config.get_filter_kind_map(0)
    assert.equals(nil, fk.Class)
    assert.equals(true, fk.Function)
  end)
  it("recognizes when filter_kind is false", function()
    config.setup({
      filter_kind = { foo = false },
    })
    vim.api.nvim_buf_set_option(0, "filetype", "foo")
    local fk = config.get_filter_kind_map(0)
    assert.equals(true, fk.Class)
    assert.equals(true, fk.Function)
  end)

  -- Icons
  it("reads icons from the default table", function()
    config.setup({ nerd_font = true, use_lspkind = false })
    assert.equals("󰊕 ", config.get_icon(0, "Function", false))
  end)
  it("reads icons from setup var", function()
    config.setup({
      nerd_font = true,
      icons = {
        Function = "*",
      },
      use_lspkind = false,
    })
    assert.equals("*", config.get_icon(0, "Function", false))
    assert.equals("󰊕 ", config.get_icon(0, "Method", false))
  end)
  it("fetches the collapsed version of icon", function()
    config.setup({
      icons = {
        FunctionCollapsed = "a",
      },
    })
    assert.equals("a", config.get_icon(0, "Function", true))
  end)
  it("defaults to 'Collapsed' for collapsed icons", function()
    config.setup({
      icons = {
        Collapsed = "a",
      },
    })
    assert.equals("a", config.get_icon(0, "Function", true))
  end)
  it("uses filetype overrides for icons", function()
    config.setup({
      icons = {
        foo = {
          Function = "a",
        },
      },
    })
    vim.api.nvim_buf_set_option(0, "filetype", "foo")
    assert.equals("a", config.get_icon(0, "Function", false))
  end)
  it("falls back to '_' filetype if no match", function()
    config.setup({
      icons = {
        ["_"] = {
          Function = "a",
        },
      },
    })
    vim.api.nvim_buf_set_option(0, "filetype", "foo")
    assert.equals("a", config.get_icon(0, "Function", false))
  end)
end)
