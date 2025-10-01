# Homebrewの設定
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# alias設定
alias pj='cd ~/pj'
alias ls='ls -G'
alias python='python3.12'
alias pip='pip3.12'

# HomebrewのPythonを優先
export PATH="/opt/homebrew/bin/python3.12:$PATH"
