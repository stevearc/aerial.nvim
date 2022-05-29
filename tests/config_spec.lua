local config = require("aerial.config")

local function reset()
  package.loaded["aerial.config"] = nil
  config = require("aerial.config")
end

describe("config", function()
  before_each(function()
    pcall(vim.api.nvim_del_var, "aerial")
    reset()
  end)

  it("falls back to default options", function()
    assert.equals(config.close_behavior, "auto")
  end)

  it("reads options from g:aerial dict var", function()
    vim.g.aerial = {
      close_behavior = "persist",
    }
    assert.equals(config.close_behavior, "persist")
  end)

  it("reads options from g:aerial_<name> vars", function()
    vim.g.aerial_close_behavior = "persist"
    assert.equals(config.close_behavior, "persist")
    vim.api.nvim_del_var("aerial_close_behavior")
  end)

  it("merges nested options with g:aerial dict", function()
    vim.g.aerial = {
      float = {
        border = "single",
      },
    }
    assert.equals(config.float.border, "single")
    assert.equals(config.float.max_height, 0.9)
  end)

  it("merges nested options with g:aerial_<name> vars", function()
    vim.g.aerial_float_border = "single"
    assert.equals(config.float.border, "single")
    vim.api.nvim_del_var("aerial_float_border")
  end)

  -- Filetype maps
  it("reads the default value for filetype map option", function()
    assert.equals(config.open_automatic(0), false)
  end)
  it("reads the filetype default value for filetype map option", function()
    vim.g.aerial = {
      open_automatic = {
        ["_"] = true,
      },
    }
    assert.equals(config.open_automatic(0), true)
  end)
  it("reads the filetype value for filetype map option", function()
    vim.g.aerial = {
      open_automatic = {
        fake_ft = true,
      },
    }
    vim.api.nvim_buf_set_option(0, "filetype", "fake_ft")
    assert.equals(config.open_automatic(0), true)
  end)
  it("reads the filetype value when using a compound filetype", function()
    vim.g.aerial = {
      open_automatic = {
        fake_ft = true,
      },
    }
    vim.api.nvim_buf_set_option(0, "filetype", "fake_ft.extension")
    assert.equals(config.open_automatic(0), true)
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
    vim.g.aerial = {
      filter_kind = { "Function" },
    }
    local fk = config.get_filter_kind_map()
    assert.equals(nil, fk.Class)
    assert.equals(true, fk.Function)
  end)
  it("reads the filter_kind option from filetype map", function()
    vim.g.aerial = {
      filter_kind = { foo = { "Function" } },
    }
    vim.api.nvim_buf_set_option(0, "filetype", "foo")
    local fk = config.get_filter_kind_map()
    assert.equals(nil, fk.Class)
    assert.equals(true, fk.Function)
  end)
  it("recognizes when filter_kind is false", function()
    vim.g.aerial = {
      filter_kind = { foo = 0 },
    }
    vim.api.nvim_buf_set_option(0, "filetype", "foo")
    local fk = config.get_filter_kind_map()
    assert.equals(true, fk.Class)
    assert.equals(true, fk.Function)
  end)

  -- Icons
  it("reads icons from the default table", function()
    config.setup({ nerd_font = true, use_lspkind = false })
    assert.equals(" ", config.get_icon(0, "Function", false))
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
    assert.equals(" ", config.get_icon(0, "Method", false))
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

  -- This is for backwards compatibility with lsp options that used to be in the
  -- global namespace
  it("reads lsp_ options from g:aerial dict var", function()
    assert.equals(config.lsp.update_when_errors, true)
    vim.g.aerial = {
      update_when_errors = false,
    }
    reset()
    assert.equals(config.lsp.update_when_errors, false)
  end)
  it("reads lsp_ options from g:aerial_<name> vars", function()
    assert.equals(config.lsp.update_when_errors, true)
    vim.g.aerial_update_when_errors = false
    reset()
    assert.equals(config.lsp.update_when_errors, false)
    vim.api.nvim_del_var("aerial_update_when_errors")
  end)
end)
