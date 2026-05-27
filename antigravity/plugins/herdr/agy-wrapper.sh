#!/bin/bash
#
# Antigravity CLI (agy) wrapper for herdr integration.
# Reports agent state to herdr before/after executing agy.
#
# To use:
# 1. Rename original agy: mv ~/.local/bin/agy ~/.local/bin/agy-original
# 2. Place this wrapper at: ~/.local/bin/agy
# 3. Make executable: chmod +x ~/.local/bin/agy
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find_agy_original() {
    local dir
    for dir in "$(dirname "$0")" "$HOME/.local/bin" /usr/local/bin; do
        if [ -x "$dir/agy-original" ]; then
            echo "$dir/agy-original"
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
    echo ""
    return 1
}

AGY_REAL="$(find_agy_original)"

if [ -z "$AGY_REAL" ]; then
    echo "Error: agy-original not found." >&2
    echo "" >&2
    echo "Setup instructions:" >&2
    echo "  1. mv ~/.local/bin/agy ~/.local/bin/agy-original" >&2
    echo "  2. Place this wrapper at ~/.local/bin/agy" >&2
    exit 1
fi

REPORT_SCRIPT="$(find_report_script)"

export HERDR_AGENT_NAME=agy

IN_HERDR=0
if [ "$HERDR_ENV" = "1" ] || [ -n "$HERDR_SOCKET_PATH" ] && [ -n "$HERDR_PANE_ID" ]; then
    IN_HERDR=1
fi

if [ $IN_HERDR -eq 1 ] && [ -n "$REPORT_SCRIPT" ]; then
    python3 "$REPORT_SCRIPT" idle 2>/dev/null || true
fi

cleanup() {
    if [ $IN_HERDR -eq 1 ] && [ -n "$REPORT_SCRIPT" ]; then
        python3 "$REPORT_SCRIPT" release 2>/dev/null || true
    fi
}
trap cleanup EXIT

AGY_EXIT=0
"$AGY_REAL" "$@" || AGY_EXIT=$?
cleanup
exit $AGY_EXIT
