local function fn_1(bar: string, baz: number)
   return bar, baz
end

local fn_2 = function()
    return
end

local M = {}

M.fn_3 = function() end

function M.launch(f: function, ...)
    return
end

function M.wrap(f: function): function
    return function(...)
        M.launch(f, ...)
    end
end

local record Point
   x: number
   y: number
end

function Point.new(x: number, y: number): Point
   local self = setmetatable({} as Point, { __index = Point })
   self.x = x or 0
   self.y = y or 0
   return self
end

function Point:move(dx: number, dy: number)
   self.x = self.x + dx
   self.y = self.y + dy
end
