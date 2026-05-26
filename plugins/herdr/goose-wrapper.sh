#!/bin/bash
#
# Goose wrapper for herdr integration.
# This script reports goose's agent state to herdr before executing goose.
#
# To use: 
# 1. Rename original goose: mv ~/.local/bin/goose ~/.local/bin/goose-original
# 2. Place this wrapper at: ~/.local/bin/goose
# 3. Make executable: chmod +x ~/.local/bin/goose
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find_goose_original() {
    local dir
    for dir in "$(dirname "$0")" "$HOME/.local/bin" /usr/local/bin; do
        if [ -x "$dir/goose-original" ]; then
            echo "$dir/goose-original"
            return 0
        fi
    done
    echo ""
    return 1
}

find_report_script() {
    local script="$HOME/.agents/plugins/herdr/herdr_report.py"
    if [ -f "$script" ]; then
        echo "$script"
        return 0
    fi
    
    local repo_dir
    for repo_dir in "$HOME/Workspace/goose-config" "$HOME/workspace/goose-config"; do
        script="$repo_dir/plugins/herdr/herdr_report.py"
        if [ -f "$script" ]; then
            echo "$script"
            return 0
        fi
    done
    
    echo ""
    return 1
}

GOOSE_REAL="$(find_goose_original)"

if [ -z "$GOOSE_REAL" ]; then
    echo "Error: goose-original not found." >&2
    echo "" >&2
    echo "Setup instructions:" >&2
    echo "  1. mv ~/.local/bin/goose ~/.local/bin/goose-original" >&2
    echo "  2. Place this wrapper at ~/.local/bin/goose" >&2
    exit 1
fi

REPORT_SCRIPT="$(find_report_script)"

IN_HERDR=0
if [ "$HERDR_ENV" = "1" ] || [ -n "$HERDR_SOCKET_PATH" ] && [ -n "$HERDR_PANE_ID" ]; then
    IN_HERDR=1
fi

if [ $IN_HERDR -eq 1 ] && [ -n "$REPORT_SCRIPT" ]; then
    python3 "$REPORT_SCRIPT" working 2>/dev/null || true
fi

cleanup() {
    if [ $IN_HERDR -eq 1 ] && [ -n "$REPORT_SCRIPT" ]; then
        python3 "$REPORT_SCRIPT" idle 2>/dev/null || true
    fi
}
trap cleanup EXIT

exec "$GOOSE_REAL" "$@"
