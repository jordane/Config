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

au BufRead,BufNewFile *.rb,*.rhtml set tabstop=2
au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2
au BufRead,BufNewFile *.c, *.cpp, *.java, *.js, *.html noremap % v%
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
