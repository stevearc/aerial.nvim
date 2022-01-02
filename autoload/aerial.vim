function! aerial#fzf() abort
	let l:labels = luaeval("require('aerial.fzf').get_labels()")
	if type(l:labels) == type(v:null) && l:labels == v:null
		return
	endif
	call fzf#run({
				\ 'source': l:labels,
				\ 'sink': funcref('aerial#goto_symbol'),
				\ 'options': '--prompt="Document symbols: "',
				\ 'window': {'width': 0.5, 'height': 0.4},
				\ })
endfunction

function! aerial#goto_symbol(symbol) abort
	call luaeval("require('aerial.fzf').goto_symbol(_A)", a:symbol)
endfunction
