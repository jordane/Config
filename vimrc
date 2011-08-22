set shiftwidth=4
set title
set nocompatible
set tabstop=4
set expandtab
set autoindent
syn on
colorscheme elflord
set number
set spell
set incsearch
set hlsearch

au BufRead,BufNewFile *.rb,*.rhtml set tabstop=2
au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2
autocmd BufWritePost *.py !python -t -c  "compile(open('<afile>').read(), '<afile>', 'exec')"

:highlight ExtraWhitespace  ctermbg=yellow guibg=red
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ containedin=ALL

:highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/


:highlight clear SpellBad
:highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
:highlight clear SpellCap
:highlight SpellCap term=underline cterm=underline
:highlight clear SpellRare
:highlight SpellRare term=underline cterm=underline
:highlight clear SpellLocal
:highlight SpellLocal term=underline cterm=underline

"winmanager settings
:map <c-w><c-t> :WMToggle<cr>
:map <c-w><c-f> :FirstExplorerWindow<cr>
:map <c-w><c-b> :BottomExplorerWindow<cr>
