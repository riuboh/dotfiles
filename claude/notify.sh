#!/bin/bash
# Usage: notify.sh <title> <message> <sound>
TITLE="${1:-Claude Code}"
MESSAGE="${2:-通知}"
SOUND="${3:-Glass}"

if [[ "$(uname)" == "Darwin" ]]; then
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"$SOUND\""
fi
