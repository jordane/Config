export EDITOR='/usr/bin/vim'
alias ls='ls --color=always'
function title {
    export PROMPT_COMMAND='echo -ne "\033]0;'$1'\007"'
}
alias ll='ls -l --color=always'
alias rm='rm -i'
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

#exec /bin/zsh
