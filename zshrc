# .zshrc
HISTFILE=$HOME/.zsh/history
HISTSIZE=10000
SAVEHIST=10000
PERIOD=1
setopt append_history           # Append instead of overwrite
setopt notify                   # Notify on bad completion
setopt extended_history         # Save times and runtimes in the history
setopt hist_ignore_dups         # Ignore same command run twice+
setopt hist_reduce_blanks       # " cd  ..  " -> "cd .."
setopt hist_no_functions        # Don't remember functions
setopt nobeep                   # Death to the beep!

zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit promptinit
compinit
promptinit
prompt walters

setopt extendedglob
bindkey -e emacs

# ---- This section is not right when viewed on github.com ----
# ---- As of Nov 9, 2010, there are symbols that get eaten ----
# ---- git clone the file and it will be correct.          ----

# key bindings
# Home/End
bindkey	"[H"		beginning-of-line
bindkey "[7~"   beginning-of-line
bindkey	"[F"		end-of-line
bindkey "[8~"   end-of-line
# Delete
bindkey	"[3~"		delete-char
# Up will search with whatever is on the line so far
bindkey	"\e[A" 		up-line-or-search
bindkey	"\e[B"		down-line-or-search
# Left/Right
bindkey	"\e[D"		backward-char
bindkey	"\e[C"		forward-char
# Alt-Left/Right
bindkey	"^[[D"	emacs-backward-word
bindkey	"^[[C"	emacs-forward-word

# Make alt-backspace / ctrl-arrows have saner "words" (ie: path pieces instead of full paths)
WORDCHARS=${WORDCHARS//[&=\/;!#%\{]}

rationalise-dot() {
if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/../
elif [[ $LBUFFER = *../ ]]; then
    LBUFFER+=../
else
    LBUFFER+=.
fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

# preexec hook shows command in title as it's running, and precmd sets it to
# something else when it's done. this should work with screen and
# gnome-terminal2/multi-gnome-terminal

case $TERM in
    xterm*|screen*)
        preexec () {
            export CURRENTCMD="$1"
            if [ x$WINDOW != x ]; then
                print -Pn "\ek$1\e\\"
            else
                print -Pn "\e]0;$1\a"
            fi
        }
        precmd () {
            if [[ ! -z $CURRENTCMD ]]; then
                if [ x$WINDOW != x ]; then
                    print -Pn "\ek($CURRENTCMD)\e\\"
                else
                    print -Pn "\e]0;($CURRENTCMD)\a"
                fi
            fi
        }
    ;;
esac

export PATH="$HOME/.rvm/bin:/usr/local/bin:$HOME/.rbenv/shims:$HOME/bin:/opt/local/bin:/usr/local/sbin:$PATH"
export EDITOR="vim"

#alias ls='ls --color=if-tty --group-directories-first -hF'
alias ls='ls -GhAp'
alias cp='cp -r'
alias rm='rm -i'

# Include various sub-.zshrc files
# but don't include vim .swp files
for file in $(ls $HOME/.zshrc.d/* | grep -ve ".swp$" | grep -ve ".bak$")
do
    source $file
done

export XDG_CONFIG_HOME=$HOME"/.config/xdg"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
