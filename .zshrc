# Homebrewの設定
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# alias設定
alias pj='cd ~/pj'
alias tmp='code ~/tmp'
alias ls='ls -G'
alias python='python3'
alias pip='pip3'
alias cc='claude'
alias ccmcp='code /Users/riuboh/.claude.json'

# local binを優先
export PATH="/Users/riuboh/.local/bin:$PATH"
