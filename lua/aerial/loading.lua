local util = require("aerial.util")
local M = {}

local timers = {}
local SLOW_TIMEOUT = 5

M.is_loading = function(aer_bufnr)
  return timers[aer_bufnr] ~= nil
end

M.set_loading = function(aer_bufnr, is_loading)
  if is_loading then
    if timers[aer_bufnr] == nil then
      timers[aer_bufnr] = vim.loop.new_timer()
      local i = 0
      local start = vim.fn.localtime()
      timers[aer_bufnr]:start(
        0,
        80,
        vim.schedule_wrap(function()
          local lines = { M.spinner_frames[i + 1] .. " Loading" }
          if vim.fn.localtime() - start >= SLOW_TIMEOUT then
            table.insert(lines, "stuck?")
            table.insert(lines, ":help aerial-loading")
          end
          util.render_centered_text(aer_bufnr, lines)
          i = (i + 1) % #M.spinner_frames
        end)
      )
    end
  else
    if timers[aer_bufnr] then
      timers[aer_bufnr]:close()
      timers[aer_bufnr] = nil
    end
  end
end

-- Dots spinner is from https://github.com/sindresorhus/cli-spinners
-- MIT License

-- Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (https://sindresorhus.com)

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- stylua: ignore
M.spinner_frames = {
	"⢀⠀", "⡀⠀", "⠄⠀", "⢂⠀", "⡂⠀", "⠅⠀", "⢃⠀", "⡃⠀", "⠍⠀",
	"⢋⠀", "⡋⠀", "⠍⠁", "⢋⠁", "⡋⠁", "⠍⠉", "⠋⠉", "⠋⠉", "⠉⠙",
	"⠉⠙", "⠉⠩", "⠈⢙", "⠈⡙", "⢈⠩", "⡀⢙", "⠄⡙", "⢂⠩", "⡂⢘",
	"⠅⡘", "⢃⠨", "⡃⢐", "⠍⡐", "⢋⠠", "⡋⢀", "⠍⡁", "⢋⠁", "⡋⠁",
	"⠍⠉", "⠋⠉", "⠋⠉", "⠉⠙", "⠉⠙", "⠉⠩", "⠈⢙", "⠈⡙", "⠈⠩",
	"⠀⢙", "⠀⡙", "⠀⠩", "⠀⢘", "⠀⡘", "⠀⠨", "⠀⢐", "⠀⡐", "⠀⠠",
	"⠀⢀", "⠀⡀",
}

return M
