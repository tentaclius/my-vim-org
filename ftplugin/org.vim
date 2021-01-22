lua require'org'

let g:org_index = '~/Org/w.org'

" Folding
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

command! Org :execute ':e ' . g:org_index
command! -nargs=1 OrgAck :execute 'Ack ' . <q-args> . ' ' . expand("%")
command! OrgTodo :execute "Ack '(^[ \\t]*- \\[ ]|^\\*\+ TODO )' " . expand("%")
command! OrgAgendaWeek :lua myOrgAgenda('7 days')
command! OrgAgendaToday :lua myOrgAgenda('today')
