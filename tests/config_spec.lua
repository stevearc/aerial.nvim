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
    assert.equals(config["float.col"], 0)
  end)

  it("merges nested options with g:aerial_<name> vars", function()
    vim.g.aerial_float_row = 10
    assert.equals(config["float.row"], 10)
    vim.api.nvim_del_var("aerial_float_row")
  end)

  -- This is for backwards compatibility with lsp options that used to be in the
  -- global namespace
  it("reads lsp_ options from g:aerial dict var", function()
    assert.equals(config["lsp.update_when_errors"], true)
    vim.g.aerial = {
      update_when_errors = false,
    }
    assert.equals(config["lsp.update_when_errors"], false)
  end)
  it("reads lsp_ options from g:aerial_<name> vars", function()
    assert.equals(config["lsp.update_when_errors"], true)
    vim.g.aerial_update_when_errors = false
    assert.equals(config["lsp.update_when_errors"], false)
    vim.api.nvim_del_var("aerial_update_when_errors")
  end)
end)
