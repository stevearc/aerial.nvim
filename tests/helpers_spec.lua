local helpers = require("aerial.backends.treesitter.helpers")

describe("treesitter helpers", function()
  describe("get_query", function()
    local orig_query_get

    before_each(function()
      orig_query_get = vim.treesitter.query.get
      helpers.clear_query_cache()
    end)

    after_each(function()
      vim.treesitter.query.get = orig_query_get
      helpers.clear_query_cache()
    end)

    it("returns nil and an err when the query fails to parse", function()
      -- Mirrors the #506 SQL/create_policy case.
      vim.treesitter.query.get = function()
        error('Query error at 37:2. Invalid node type "create_policy"')
      end

      local query, err = helpers.get_query("sql")
      assert.is_nil(query)
      assert.is_truthy(err)
      assert.is_truthy(err:find("create_policy", 1, true))
    end)

    it("caches the parse failure", function()
      local calls = 0
      vim.treesitter.query.get = function()
        calls = calls + 1
        error("boom")
      end

      helpers.get_query("madeuplang")
      helpers.get_query("madeuplang")
      helpers.get_query("madeuplang")

      assert.equals(1, calls)
    end)
  end)
end)
