alias la='ls -A'
alias lal='ls -lA'
alias more='less'
alias rake='noglob rake'
alias ghi='git hist'

export LESS="-RM"
export LESSHISTFILE=-

HISTFILE=~/.cache/zsh_history

path() {
  echo $PATH | tr ":" "\n" | \
  awk "{ sub(\"/usr\",   \"$fg_no_bold[green]/usr$reset_color\"); \
     sub(\"/bin\",   \"$fg_no_bold[blue]/bin$reset_color\"); \
     sub(\"/opt\",   \"$fg_no_bold[cyan]/opt$reset_color\"); \
     sub(\"/sbin\",  \"$fg_no_bold[magenta]/sbin$reset_color\"); \
     sub(\"/local\", \"$fg_no_bold[yellow]/local$reset_color\"); \
     print }"
}

# This was written entirely by Mikael Magnusson (Mikachu)
# Basically type '...' to get '../..' with successive .'s adding /..
function rationalise-dot {
    local MATCH # keep the regex match from leaking to the environment
    if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
      LBUFFER+=/
      zle self-insert
      zle self-insert
    else
      zle self-insert
    fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
# without this, typing a . aborts incremental history search
bindkey -M isearch . self-insert

DIRSTACKSIZE=9
