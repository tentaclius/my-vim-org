" Headers
syntax match org_hx /^\*\+ [^:]*/ contains=org_shadow_star,org_todo
highlight org_hx guifg=#ffffff gui=bold
syntax match org_h1 /^\* [^:]*/ contains=org_shadow_star,org_todo
highlight org_h1 guifg=#60ed13 gui=bold
syntax match org_h2 /^\*\{2} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h2 guifg=#13ed86 gui=bold
syntax match org_h3 /^\*\{3} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h3 guifg=#13edd0 gui=bold
syntax match org_h4 /^\*\{4} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h4 guifg=#13c0ed gui=bold
syntax match org_h5 /^\*\{5} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h5 guifg=#1378ed gui=bold
syntax match org_h6 /^\*\{6} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h6 guifg=#9f13ed gui=bold
syntax match org_h7 /^\*\{7} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h7 guifg=#e00cf1 gui=bold
syntax match org_h8 /^\*\{8} [^:]*/ contains=org_shadow_star,org_todo
highlight org_h8 guifg=#f10cb4 gui=bold
syntax match org_shadow_star /^\*\+\* /me=e-2 contained
highlight org_shadow_star guifg=bg gui=bold
syntax keyword org_todo TODO DONE CANCELLED contained
highlight org_todo guifg=#ffffff

" Tags
syntax match org_tag /:[A-Za-z0-9_:]*:\s*$/
highlight def link org_tag Label

" Text effects (bold)
syn match org_bold /\_W\*\S.*\S\*\_W/hs=s+1,he=e-1 contains=org_bold_star1,org_bold_star2
syn match org_bold_star1 /\_W\*\w/hs=s+1,he=e-1 contained conceal
syn match org_bold_star2 /\w\*\_W/hs=s+1,he=e-1 contained conceal
highlight org_bold guibg=#ffffff guifg=#000000

" Code block (MD-style)
syn region org_code start=/```/ end=/```/
highlight def link org_code String

" Timestamps
syntax match org_timestamp /<\d\{4}-\d\{2}-\d\{2}>/
syntax match org_timestamp /<\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}>/
syntax match org_timestamp /<\d\{4}-\d\{2}-\d\{2} [A-Za-z]\{3}>/
syntax match org_timestamp /<\d\{4}-\d\{2}-\d\{2} [A-Za-z]\{3} \d\{2}:\d\{2}>/
highlight org_timestamp guifg=#ffffff

" Links
syntax match org_link	"\[\{2}[^][]*\(\]\[[^][]*\)\?\]\{2}" contains=org_linkBracketsLeft,org_linkURL,org_linkBracketsRight containedin=ALL
syntax match org_linkBracketsLeft	contained "\[\{2}"     conceal
syntax match org_linkURL				    contained "[^][]*\]\[" conceal
syntax match org_linkBracketsRight	contained "\]\{2}"     conceal
syntax match org_link /https\?:\/\/\S\+/
hi def link org_link Underlined
