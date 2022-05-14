local M = {}

M.create_commands = function()
  function _G.aerial_complete_open_direction(arg_lead, _cmd_line, _cursor_pos)
    local opts = { "right", "left", "float" }
    return vim.tbl_filter(function(opt)
      return string.sub(opt, 1, string.len(arg_lead)) == arg_lead
    end, opts)
  end

  vim.cmd([[
command! -bang -complete=customlist,v:lua.aerial_complete_open_direction -nargs=? AerialToggle call luaeval("require'aerial'.toggle(_A[1], _A[2])", [expand('<bang>'), expand('<args>')])
command! -bang -complete=customlist,v:lua.aerial_complete_open_direction -nargs=? AerialOpen call luaeval("require'aerial'.open(_A[1], _A[2])", [expand('<bang>'), expand('<args>')])
command! -bang AerialOpenAll lua require('aerial').open_all()
command! AerialClose lua require'aerial'.close()
command! AerialCloseAll lua require'aerial'.close_all()
command! AerialCloseAllButCurrent lua require'aerial'.close_all_but_current()
command! -count=1 AerialNext call luaeval("require'aerial'.next(tonumber(_A))", expand('<count>'))
command! -count=1 AerialPrev call luaeval("require'aerial'.next(-1*tonumber(_A))", expand('<count>'))
command! -count=1 AerialNextUp call luaeval("require'aerial'.up(1, tonumber(_A))", expand('<count>'))
command! -count=1 AerialPrevUp call luaeval("require'aerial'.up(-1, tonumber(_A))", expand('<count>'))
command! -bang -count=1 -nargs=? AerialGo call luaeval('require("aerial.command")._go(_A[1], _A[2], _A[3])', [<q-bang>, <count>, <q-args>])
command! -bang AerialTreeOpen call luaeval('require("aerial.command")._tree_cmd("open", _A)', <q-bang>)
command! -bang AerialTreeClose call luaeval('require("aerial.command")._tree_cmd("close", _A)', <q-bang>)
command! -bang AerialTreeToggle call luaeval('require("aerial.command")._tree_cmd("toggle", _A)', <q-bang>)
command! AerialTreeOpenAll lua require'aerial'.tree_open_all()
command! AerialTreeCloseAll lua require'aerial'.tree_close_all()
command! AerialTreeSyncFolds lua require'aerial'.sync_folds()
command! -nargs=1 AerialTreeSetCollapseLevel call luaeval('require("aerial").tree_set_collapse_level(0, tonumber(_A))', <q-args>)
command! AerialInfo lua require'aerial'.info()
  ]])
end

M._go = function(bang, count, split)
  local opts = {
    jump = bang == "",
    index = count,
    split = split,
  }
  require("aerial").select(opts)
end

M._tree_cmd = function(cmd, bang)
  local opts = {
    recurse = bang == "!",
  }
  require("aerial").tree_cmd(cmd, opts)
end

return M
