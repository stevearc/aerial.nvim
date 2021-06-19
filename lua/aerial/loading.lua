local util = require 'aerial.util'
local M = {}

M.add_loading_animation = function(bufnr)
  local timer = vim.loop.new_timer()
  local i = 0
  timer:start(0, 80, vim.schedule_wrap(function()
    local ok, loading = pcall(vim.api.nvim_buf_get_var, bufnr, 'loading')
    if not ok or not loading then
      timer:close()
      return
    end
    local winid = vim.fn.bufwinid(bufnr)
    local height = 40
    local width = util.get_width(bufnr)
    if winid ~= -1 then
      height = vim.api.nvim_win_get_height(winid)
      width = vim.api.nvim_win_get_width(winid)
    end
    local lines = {}
    for _=1,(height/2)-1 do
      table.insert(lines, '')
    end
    local line = M.spinner_frames[i+1] .. ' Loading'
    line = string.rep(' ', (width - vim.fn.strdisplaywidth(line)) / 2) .. line
    table.insert(lines, line)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    i = (i + 1) % #M.spinner_frames
  end))
end

-- Dots spinner is from https://github.com/sindresorhus/cli-spinners
-- MIT License

-- Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (https://sindresorhus.com)

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
