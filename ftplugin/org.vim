" TODO
" - [ ] promote/demote an item

lua require'org'

let g:org_index = '~/Org/w.org'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! MyOrgNextHeader()
   /^\*\+ /
   :noh
endfunction

function! MyOrgPrevHeader()
   ?^\*\+ ?
   :noh
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! MyOrgFoldtext(lnum)
   return luaeval('myOrgFoldtext(' . a:lnum . ')')
endfunction

function! MyOrgFold(lnum)
   return luaeval('myOrgFold(' . a:lnum . ')')
endfunction

setlocal foldtext=MyOrgFoldtext(v:foldstart)
highlight Folded guibg=bg

setlocal foldmethod=expr
setlocal foldexpr=MyOrgFold(v:lnum)

setlocal conceallevel=2 concealcursor=nc                                                                                                                                              

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=1 OrgAck :execute 'Ack ' . <q-args> . ' ' . expand("%")
command! OrgTodo :execute "Ack '(^[ \\t]*- \\[ ]|^\\*\+ TODO )' " . expand("%")
command! OrgAgendaWeek :lua myOrgAgenda('7 days')
command! OrgAgendaToday :lua myOrgAgenda('today')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <buffer> <C-j> :lua myOrgMkNextHeader()<CR>
inoremap <buffer> <C-j> :lua myOrgMkNextHeader()<CR>
nnoremap <buffer> >> :call luaeval('myOrgPromoteLine(' . line(".") . ',1)')<CR>
nnoremap <buffer> << :call luaeval('myOrgPromoteLine(' . line(".") . ',-1)')<CR>
nnoremap <buffer> == :call luaeval('myOrgIndentLine(' . line(".") . ')')<CR>
nnoremap <buffer> <leader>> :lua myOrgPromoteBranch(1)<CR>
nnoremap <buffer> <leader>< :lua myOrgPromoteBranch(-1)<CR>
nnoremap <buffer> ]] :call MyOrgNextHeader()<CR>
nnoremap <buffer> [[ :call MyOrgPrevHeader()<CR>
nnoremap <buffer> <leader>t :lua myOrgToggleTodo()<CR>
nnoremap <buffer> <leader>r :lua myOrgPostponeTodo()<CR>
nnoremap <buffer> <BS> :lua myOrgGoToParent()<CR>
nnoremap <buffer> gl :lua myOrgFollowLink()<CR>
