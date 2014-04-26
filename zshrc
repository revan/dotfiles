bindkey -e
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi



# Start tmux
#[[ -z "$TMUX" ]] && exec tmux

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt autocd beep
# The following lines were added by compinstall
zstyle :compinstall filename '/cygdrive/c/Users/Revan/.zshrc'

autoload -Uz compinit
compinit -u
# End of lines added by compinstall


#autoload promptinit
#promptinit
#prompt fade blue

#prompt (modified fade)
#local fadebar_cwd=${1:-'blue'}
#local userhost=${2:-'white'}
#local date=${3:-'white'}

#local -A schars
#autoload -Uz prompt_special_chars
#prompt_special_chars

#PS1="%(?..[%?] )%F{$fadebar_cwd}%B%K{$fadebar_cwd}$schars[333]$schars[262]$schars[261]$schars[260]%F{$userhost}%K{$fadebar_cwd}%B%~/%b%k%f%b%F{$fadebar_cwd}%K{black}$schars[333]$schars[262]$schars[261]$schars[260]%f%k"
#PS2="%F{$fadebar_cwd}%K{black}$schars[333]$schars[262]$schars[261]$schars[260]%f%k>"
#RPROMPT="%F{$date}%K{black}%B %D{%I:%M:%S%P}%F{$fadebar_cwd}%K{black}%B%b"

#prompt_opts=(cr subst percent)

#back-delete stops at symbols
autoload -U select-word-style
select-word-style bash

#colorize ls
alias ls='LANG=en_US ls -Gh --file-type --color=tty --hide="\$RECYCLE.BIN" --hide="System Volume Information" --hide="ntuser.dat*" --hide="NTUSER.DAT*"'

#alias subl="run /cygdrive/c/Program\ Files/Sublime\ Text\ 2/sublime_text.exe"
alias heroku="/usr/local/heroku/bin/heroku"
#alias virtualenv="/cygdrive/c/Python27/Scripts/virtualenv"

alias vm="ssh -l revan -p 2222 localhost"
alias ilab="ssh rws114@man.cs.rutgers.edu"

alias xclip="xclip -selection c"

export PATH="/usr/local/heroku/bin:$PATH"
export PATH=".gem/ruby/2.0.0/bin:$PATH"

unalias rm
