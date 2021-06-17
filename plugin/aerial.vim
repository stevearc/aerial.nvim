
command! -bang -complete=customlist,<sid>OpenDirection -nargs=? AerialToggle
  \ call luaeval("require'aerial'.toggle(_A[1], _A[2])", [expand('<bang>'), expand('<args>')])
command! -bang -complete=customlist,<sid>OpenDirection -nargs=? AerialOpen
  \ call luaeval("require'aerial'.open(_A[1], _A[2])", [expand('<bang>'), expand('<args>')])
command! AerialClose lua require'aerial'.close()
command! -count=1 AerialNext call luaeval("require'aerial'.next(tonumber(_A))", expand('<count>'))
command! -count=1 AerialPrev call luaeval("require'aerial'.next(-1*tonumber(_A))", expand('<count>'))
command! -bang -count=1 -nargs=? AerialGo call <sid>AerialGo(<q-bang>, <count>, <q-args>)

function! s:OpenDirection(ArgLead, CmdLine, CursorPos)
  let l:opts = ['right', 'left']
  return filter(l:opts, 'v:val =~ "^'. a:ArgLead .'"')
endfunction

function! s:AerialGo(bang, count, split) abort
  let l:args = {
        \ 'jump': a:bang == '' ? v:true : v:false,
        \ 'index': a:count,
        \ 'split': a:split,
        \}
  call luaeval("require'aerial'.select(_A)", args)
endfunction

" The line that shows where your cursor(s) are
highlight default link AerialLine QuickFixLine

" The icon displayed to the left of the symbol
highlight default link AerialArrayIcon         Identifier
highlight default link AerialBooleanIcon       Identifier
highlight default link AerialClassIcon         Type
highlight default link AerialConstantIcon      Constant
highlight default link AerialConstructorIcon   Special
highlight default link AerialEnumIcon          Type
highlight default link AerialEnumMemberIcon    Identifier
highlight default link AerialEventIcon         Identifier
highlight default link AerialFieldIcon         Identifier
highlight default link AerialFileIcon          Identifier
highlight default link AerialFunctionIcon      Function
highlight default link AerialInterfaceIcon     Type
highlight default link AerialKeyIcon           Identifier
highlight default link AerialMethodIcon        Function
highlight default link AerialModuleIcon        Include
highlight default link AerialNamespaceIcon     Include
highlight default link AerialNullIcon          Identifier
highlight default link AerialNumberIcon        Identifier
highlight default link AerialObjectIcon        Identifier
highlight default link AerialOperatorIcon      Identifier
highlight default link AerialPackageIcon       Include
highlight default link AerialPropertyIcon      Identifier
highlight default link AerialStringIcon        Identifier
highlight default link AerialStructIcon        Type
highlight default link AerialTypeParameterIcon Identifier
highlight default link AerialVariableIcon      Identifier

" The name of the symbol
highlight default link AerialArray         NONE
highlight default link AerialBoolean       NONE
highlight default link AerialClass         NONE
highlight default link AerialConstant      NONE
highlight default link AerialConstructor   NONE
highlight default link AerialEnum          NONE
highlight default link AerialEnumMember    NONE
highlight default link AerialEvent         NONE
highlight default link AerialField         NONE
highlight default link AerialFile          NONE
highlight default link AerialFunction      NONE
highlight default link AerialInterface     NONE
highlight default link AerialKey           NONE
highlight default link AerialMethod        NONE
highlight default link AerialModule        NONE
highlight default link AerialNamespace     NONE
highlight default link AerialNull          NONE
highlight default link AerialNumber        NONE
highlight default link AerialObject        NONE
highlight default link AerialOperator      NONE
highlight default link AerialPackage       NONE
highlight default link AerialProperty      NONE
highlight default link AerialString        NONE
highlight default link AerialStruct        NONE
highlight default link AerialTypeParameter NONE
highlight default link AerialVariable      NONE
