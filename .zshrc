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
alias ga='gwq add -b'

#==========================================================#
# load something
#==========================================================#

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# env
[[ -f secrets/.env.local ]] && source secrets/.env.local

#==========================================================#
# functions
#==========================================================#

# move to worktree
function g() {
  cd "$(ghq list -p | fzf)"
}

# generate worktree from remote branch
function gf() {
  local branch
  branch=$(git ls-remote --heads origin | sed 's|.*refs/heads/||' | fzf)
  [ -z "$branch" ] && return 1
  git fetch origin "$branch" && gwq add "$branch"
}

# remove worktree safely
function gr() {
  local branch
  branch=$(gwq list --json | jq -r '.[].branch' | fzf)
  [ -z "$branch" ] && return 1
  gwq remove -b "$branch"
}



#==========================================================#
# path settings
#==========================================================#
export PATH="$HOME/.local/bin:$PATH"
