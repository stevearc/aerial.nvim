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
