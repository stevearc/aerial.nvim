local config = require("aerial.config")

describe("config", function()
  before_each(function()
    pcall(vim.api.nvim_del_var, "aerial")
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
        row = 10,
      },
    }
    assert.equals(config["float.row"], 10)
    assert.equals(config.float.row, 10)
    assert.equals(config["float.col"], 0)
    assert.equals(config.float.col, 0)
  end)

  it("merges nested options with g:aerial_<name> vars", function()
    vim.g.aerial_float_row = 10
    assert.equals(config["float.row"], 10)
    assert.equals(config.float.row, 10)
    vim.api.nvim_del_var("aerial_float_row")
  end)

  it("reads the default value for filetype map option", function()
    assert.equals(config.open_automatic(), false)
  end)
  it("reads the filetype default value for filetype map option", function()
    vim.g.aerial = {
      open_automatic = {
        ["_"] = 1,
      },
    }
    assert.equals(config.open_automatic(), true)
  end)
  it("reads the filetype value for filetype map option", function()
    vim.g.aerial = {
      open_automatic = {
        fake_ft = 1,
      },
    }
    vim.api.nvim_buf_set_option(0, "filetype", "fake_ft")
    assert.equals(config.open_automatic(), true)
  end)

  it("reads the filter_kind option", function()
    vim.g.aerial = {
      filter_kind = { "Function" },
    }
    local fk = config.get_filter_kind_map("foo")
    assert.equals(nil, fk.Class)
    assert.equals(true, fk.Function)
  end)
  it("reads the filter_kind option from filetype map", function()
    vim.g.aerial = {
      filter_kind = { foo = { "Function" } },
    }
    local fk = config.get_filter_kind_map("foo")
    assert.equals(nil, fk.Class)
    assert.equals(true, fk.Function)
  end)
  it("recognizes when filter_kind is false", function()
    vim.g.aerial = {
      filter_kind = { foo = 0 },
    }
    local fk = config.get_filter_kind_map("foo")
    assert.equals(true, fk.Class)
    assert.equals(true, fk.Function)
  end)

  -- This is for backwards compatibility with lsp options that used to be in the
  -- global namespace
  it("reads lsp_ options from g:aerial dict var", function()
    assert.equals(config["lsp.update_when_errors"], true)
    vim.g.aerial = {
      update_when_errors = false,
    }
    assert.equals(config["lsp.update_when_errors"], false)
    assert.equals(config.lsp.update_when_errors, false)
  end)
  it("reads lsp_ options from g:aerial_<name> vars", function()
    assert.equals(config["lsp.update_when_errors"], true)
    vim.g.aerial_update_when_errors = false
    assert.equals(config["lsp.update_when_errors"], false)
    assert.equals(config.lsp.update_when_errors, false)
    vim.api.nvim_del_var("aerial_update_when_errors")
  end)
end)
