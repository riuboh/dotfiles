#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

dotfiles=(
    ".zshrc:$HOME/.zshrc"
    ".gitconfig:$HOME/.gitconfig"
    "vscode/settings.json:$HOME/Library/Application Support/Code/User/settings.json"
)

for dotfile in "${dotfiles[@]}"; do
    src="${dotfile%%:*}"
    dst="${dotfile##*:}"
    rm -rf "${dst}"
    ln -s "${SCRIPT_DIR}/${src}" "${dst}"
done
