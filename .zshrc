#==========================================================#
# zsh options
#==========================================================#
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt correct
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_no_functions
setopt hist_no_store
setopt hist_reduce_blanks
setopt no_promptcr
setopt share_history

#==========================================================#
# env settings
#==========================================================#
# Homebrew
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#==========================================================#
# aliases
#==========================================================#
alias v='code .'
alias ws='cd ~/ws'
alias tmp='code ~/tmp'
alias ls='ls -G'
alias cc='claude'
alias python='python3'
alias pip='pip3'
alias ccmcp='code /Users/riuboh/.claude.json'

#==========================================================#
# path settings
#==========================================================#
export PATH="$HOME/.local/bin:$PATH"
