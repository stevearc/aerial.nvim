
function! aerial#foldexpr() abort
	return luaeval('require"aerial.fold".foldexpr(_A)', v:lnum)
endfunction
