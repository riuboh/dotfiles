#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
VSCODE_SETTING_DIR="$HOME/Library/Application Support/Code/User"

# Link settings.json to vscode
if [ -d "${VSCODE_SETTING_DIR}" ]; then
    ln -fsvn "${SCRIPT_DIR}/settings.json" "${VSCODE_SETTING_DIR}/settings.json"
    echo "Linked settings.json to vscode."
else
    echo "vscode setting directory is not found."
fi
