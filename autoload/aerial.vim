function! aerial#fzf() abort
	let l:labels = luaeval("require('aerial.fzf').get_labels()")
	if type(l:labels) == type(v:null) && l:labels == v:null
		return
	endif
	call fzf#run(fzf#wrap({
				\ 'source': l:labels,
				\ 'sink': funcref('aerial#goto_symbol'),
				\ 'options': ['--prompt=Document symbols: ', '--layout=reverse-list'],
				\ }))
endfunction

function! aerial#goto_symbol(symbol) abort
	call luaeval("require('aerial.fzf').goto_symbol(_A)", a:symbol)
endfunction
