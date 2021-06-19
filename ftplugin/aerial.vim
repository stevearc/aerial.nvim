if !get(g:, 'aerial_default_bindings', 1) || !get(get(g:, 'aerial', {}), 'default_bindings', 1)
  finish
endif
" Use <CR> to jump to the location, just like with the quickfix
nnoremap <buffer> <CR> <cmd>lua require'aerial'.select()<CR>
" Jump to location in a vertical split
nnoremap <buffer> <C-v> <cmd>lua require'aerial'.select({split='v'})<CR>
" Jump to location in a horizontal split
nnoremap <buffer> <C-s> <cmd>lua require'aerial'.select({split='h'})<CR>
" Use p to scroll to the location under cursor but stay in the aerial window
nnoremap <buffer> p <cmd>lua require'aerial'.select({jump=false})<CR>
" Hold ctrl + j/k to go up and down while scrolling to the location under cursor
nnoremap <buffer> <C-j> j<cmd>lua require'aerial'.select({jump=false})<CR>
nnoremap <buffer> <C-k> k<cmd>lua require'aerial'.select({jump=false})<CR>
" Use {} to jump to the prev/next item
nnoremap <buffer> } <cmd>AerialNext<CR>
nnoremap <buffer> { <cmd>AerialPrev<CR>
" Use [[]] to jump up the tree
nnoremap <buffer> ]] <cmd>AerialNextUp<CR>
nnoremap <buffer> [[ <cmd>AerialPrevUp<CR>
" q closes
nnoremap <buffer> q <cmd>AerialClose<CR>

"""" Tree commands
" o toggles the tree
nnoremap <buffer> o <cmd>lua require"aerial".tree_cmd('toggle')<CR>
" O toggles the tree recursively
nnoremap <buffer> O <cmd>lua require"aerial".tree_cmd('toggle', {recurse=true})<CR>
" l opens the tree and moves the cursor
nnoremap <buffer> l l<cmd>lua require"aerial".tree_cmd('open', {bubble=false})<CR>
" zx will sync the folds for all open windows
nnoremap <buffer> zx <cmd>lua require"aerial".sync_folds()<CR>
" make za/o/c function the same as for code folds
nnoremap <buffer> za <cmd>lua require"aerial".tree_cmd('toggle')<CR>
nnoremap <buffer> zA <cmd>lua require"aerial".tree_cmd('toggle', {recurse=true})<CR>
nnoremap <buffer> zo <cmd>lua require"aerial".tree_cmd('open')<CR>
nnoremap <buffer> zO <cmd>lua require"aerial".tree_cmd('open', {recurse=true})<CR>
nnoremap <buffer> zc <cmd>lua require"aerial".tree_cmd('close')<CR>
nnoremap <buffer> zC <cmd>lua require"aerial".tree_cmd('close', {recurse=true})<CR>
