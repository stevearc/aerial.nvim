local helpers = require("aerial.backends.treesitter.helpers")

describe("treesitter helpers", function()
  describe("get_query", function()
    local orig_query_get
    local orig_notify
    local notifications

    before_each(function()
      orig_query_get = vim.treesitter.query.get
      orig_notify = vim.notify
      notifications = {}
      vim.notify = function(msg, level, opts)
        table.insert(notifications, { msg = msg, level = level, opts = opts })
      end
      helpers.clear_query_cache()
    end)

    after_each(function()
      vim.treesitter.query.get = orig_query_get
      vim.notify = orig_notify
      helpers.clear_query_cache()
    end)

    it("returns nil instead of crashing when the query fails to parse (#506)", function()
      -- Mirror what happens when `queries/<lang>/aerial.scm` references a node
      -- type the installed grammar doesn't have (the SQL `create_policy` case
      -- in #506). `vim.treesitter.query.get` raises a `Query error at L:C.
      -- Invalid node type "..."` — get_query should swallow it and report nil.
      vim.treesitter.query.get = function()
        error('Query error at 37:2. Invalid node type "create_policy"')
      end

      local result = helpers.get_query("sql")
      assert.is_nil(result)
      assert.equals(1, #notifications, "expected one warning notification")
      assert.equals(vim.log.levels.WARN, notifications[1].level)
      assert.is_truthy(
        notifications[1].msg:find("sql", 1, true),
        "warning should mention the language: " .. notifications[1].msg
      )
      assert.is_truthy(
        notifications[1].msg:find("create_policy", 1, true),
        "warning should include the underlying parse error: " .. notifications[1].msg
      )
    end)

    it("caches the parse failure so the warning only fires once", function()
      local call_count = 0
      vim.treesitter.query.get = function()
        call_count = call_count + 1
        error("query parse error")
      end

      assert.is_nil(helpers.get_query("madeuplang"))
      assert.is_nil(helpers.get_query("madeuplang"))
      assert.is_nil(helpers.get_query("madeuplang"))

      assert.equals(1, call_count, "query.get should only be called once")
      assert.equals(1, #notifications, "warning should only fire once")
    end)

    it("still returns the query when parsing succeeds", function()
      local sentinel = { match = function() end }
      vim.treesitter.query.get = function()
        return sentinel
      end

      assert.equals(sentinel, helpers.get_query("lua"))
      assert.equals(0, #notifications)
    end)
  end)
end)
