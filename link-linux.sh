#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude

dotfiles=(
    "linux/.gitconfig:$HOME/.gitconfig"
    "linux/.bashrc:$HOME/.bashrc"
    "linux/claude/skills:$HOME/.claude/skills"
    "linux/claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
    "linux/claude/mcp.json:$HOME/.claude/mcp.json"
    "linux/claude/settings.json:$HOME/.claude/settings.json"
    "linux/claude/statusline.sh:$HOME/.claude/statusline.sh"
)

for dotfile in "${dotfiles[@]}"; do
    src="${dotfile%%:*}"
    dst="${dotfile##*:}"
    rm -rf "${dst}"
    ln -s "${SCRIPT_DIR}/${src}" "${dst}"
done
