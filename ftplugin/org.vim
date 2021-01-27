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
nnoremap <C-j> :lua myOrgMkNextHeader()<CR>
inoremap <C-j> :lua myOrgMkNextHeader()<CR>
nnoremap >> :call luaeval('myOrgPromoteLine(' . line(".") . ',1)')<CR>
nnoremap << :call luaeval('myOrgPromoteLine(' . line(".") . ',-1)')<CR>
nnoremap == :call luaeval('myOrgIndentLine(' . line(".") . ')')<CR>
nnoremap <leader>> :lua myOrgPromoteBranch(1)<CR>
nnoremap <leader>< :lua myOrgPromoteBranch(-1)<CR>
nnoremap ]] :call MyOrgNextHeader()<CR>
nnoremap [[ :call MyOrgPrevHeader()<CR>
nnoremap <leader>t :lua myOrgToggleTodo()<CR>
nnoremap <BS> :lua myOrgGoToParent()<CR>
nnoremap <CR> :lua myOrgFollowLink()<CR>
