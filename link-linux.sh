#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude

dotfiles=(
    "bin:$HOME/bin"
    ".bashrc:$HOME/.bashrc"
    "claude/commands:$HOME/.claude/commands"
    "claude/skills:$HOME/.claude/skills"
    "claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
    "claude/mcp.json:$HOME/.claude/mcp.json"
    "claude/settings.json:$HOME/.claude/settings.json"
    "claude/statusline.sh:$HOME/.claude/statusline.sh"
    "claude/notify.sh:$HOME/.claude/notify.sh"
)

for dotfile in "${dotfiles[@]}"; do
    src="${dotfile%%:*}"
    dst="${dotfile##*:}"
    rm -rf "${dst}"
    ln -s "${SCRIPT_DIR}/${src}" "${dst}"
done
