if !get(g:, 'aerial_default_bindings', 1)
  finish
endif
" Use <CR> to jump to the location, just like with the quickfix
nnoremap <buffer> <CR> <cmd>lua require'aerial'.jump_to_loc()<CR>zvzz
" Jump to location in a vertical split
nnoremap <buffer> <C-v> <cmd>lua require'aerial'.jump_to_loc(2)<CR>zvzz
" Jump to location in a horizontal split
nnoremap <buffer> <C-s> <cmd>lua require'aerial'.jump_to_loc(2, 'belowright split')<CR>zvzz
" Use p to scroll to the location under cursor but stay in the aerial window
nnoremap <buffer> p <cmd>lua require'aerial'.scroll_to_loc()<CR>
" Hold ctrl + j/k to go up and down while scrolling to the location under cursor
nnoremap <buffer> <C-j> j<cmd>lua require'aerial'.scroll_to_loc()<CR>
nnoremap <buffer> <C-k> k<cmd>lua require'aerial'.scroll_to_loc()<CR>
" Use [[]] to jump to the prev/next item
nnoremap <buffer> [[ <cmd>lua require'aerial'.prev_item()<CR>
nnoremap <buffer> ]] <cmd>lua require'aerial'.next_item()<CR>
" q closes
nnoremap <buffer> q <cmd>lua require"aerial".close()<CR>

"""" Tree commands
" o toggles the tree
nnoremap <buffer> o <cmd>lua require"aerial".tree_cmd('toggle')<CR>
" O toggles the tree recursively
nnoremap <buffer> O <cmd>lua require"aerial".tree_cmd('toggle', {recurse=true})<CR>

" l opens the tree and moves the cursor
nnoremap <buffer> l l<cmd>lua require"aerial".tree_cmd('open', {bubble=false})<CR>
