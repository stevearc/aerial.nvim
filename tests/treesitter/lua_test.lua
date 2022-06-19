local function fn_1()
  return
end

function fn_2()
  return
end

local fn_3 = function()
  return
end

fn_4 = function()
  fn_3(function()
    return
  end)
  return
end

local obj = {
  meth_1 = function()
    return
  end,
}

M.fn_5 = function() end
function M.fn_6() end

describe("UnitTest", function()
  before_each(function() end)
  after_each(function() end)
  it("describes the test", function() end)
end)

a.describe("UnitTest", function()
  a.before_each(function() end)
  a.after_each(function() end)
  a.it("describes the test", function() end)
end)

function M:fn_7() end

M["fn_8"] = function() end
