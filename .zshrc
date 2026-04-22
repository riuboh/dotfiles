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

# PATH
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

#==========================================================#
# aliases
#==========================================================#
alias v='code .'
alias ws='cd ~/ws'
alias tmp='code ~/tmp'
alias ls='ls -G'
alias cc='claude --mcp-config ~/.claude/mcp.json'
alias python='python3'
alias pip='pip3'
alias ccmcp='code /Users/riuboh/.claude.json'
alias ga='gwq add -b'

#==========================================================#
# prompt
#==========================================================#
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt prompt_subst
PROMPT='%n@%m %F{69}%1~%f${vcs_info_msg_0_} %# '

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

# move to repo
function g() {
  cd "$(ghq list -p | fzf)"
}

# switch to a local branch
function b() {
  if [ -n "$(git status --porcelain)" ]; then
    echo "b: working tree is dirty. commit or stash first." >&2
    return 1
  fi
  local branch
  branch=$(git for-each-ref --format='%(refname:short)' refs/heads/ | fzf)
  [ -z "$branch" ] && return 1
  git switch "$branch"
}

# add a local branch
function ba() {
  [ -z "$1" ] && echo "ba: branch name required" >&2 && return 1
  git switch -c "$1"
}

# delete a local branch
function bd() {
  local flag="-d"
  [ "$1" = "-f" ] && flag="-D"
  local branch
  branch=$(git for-each-ref --format='%(refname:short)' refs/heads/ | fzf)
  [ -z "$branch" ] && return 1
  git branch "$flag" "$branch"
}

# fetch and switch to a remote branch
function bf() {
  if [ -n "$(git status --porcelain)" ]; then
    echo "bf: working tree is dirty. commit or stash first." >&2
    return 1
  fi
  local branch
  branch=$(git ls-remote --heads origin | sed 's|.*refs/heads/||' | fzf)
  [ -z "$branch" ] && return 1
  git fetch origin "$branch" && git switch -t "origin/$branch"
}
