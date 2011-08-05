export EDITOR='/usr/bin/vim'
alias ls='ls --color=always'
function title {
    export PROMPT_COMMAND='echo -ne "\033]0;'$1'\007"'
}
alias ll='ls -l --color=always'
alias rm='rm -i'
