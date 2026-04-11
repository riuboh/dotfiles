#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude

dotfiles=(
    "bin:$HOME/bin"
    "claude/commands:$HOME/.claude/commands"
    "claude/skills:$HOME/.claude/skills"
    "claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
    "claude/mcp.json:$HOME/.claude/mcp.json"
    "claude/settings.json:$HOME/.claude/settings.json"
    "claude/statusline.sh:$HOME/.claude/statusline.sh"
)
