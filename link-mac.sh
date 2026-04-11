#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


mkdir -p ~/.claude
mkdir -p ~/bin

dotfiles=(
    ".zshrc:$HOME/.zshrc"
    ".gitconfig:$HOME/.gitconfig"
    "bin:$HOME/bin"
    "claude/commands:$HOME/.claude/commands"
    "claude/skills:$HOME/.claude/skills"
    "claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
    "claude/mcp.json:$HOME/.claude/mcp.json"
    "claude/settings.json:$HOME/.claude/settings.json"
    "claude/statusline.sh:$HOME/.claude/statusline.sh"
    "gwq/config.toml:$HOME/.config/gwq/config.toml"
    "vscode/settings.json:$HOME/Library/Application Support/Code/User/settings.json"
)

for dotfile in "${dotfiles[@]}"; do
    src="${dotfile%%:*}"
    dst="${dotfile##*:}"
    rm -rf "${dst}"
    ln -s "${SCRIPT_DIR}/${src}" "${dst}"
done
