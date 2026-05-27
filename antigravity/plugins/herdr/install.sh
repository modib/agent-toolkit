#!/bin/bash
#
# Install the antigravity-herdr integration.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Installing antigravity-herdr integration..."
echo "  Repo root: $REPO_ROOT"

AGY_BIN=""
for dir in "$HOME/.local/bin" /usr/local/bin; do
    if [ -x "$dir/agy" ] && [ ! -L "$dir/agy" ]; then
        AGY_BIN="$dir/agy"
        break
    fi
done

if [ -z "$AGY_BIN" ]; then
    AGY_BIN="$(which agy 2>/dev/null || true)"
    if [ -z "$AGY_BIN" ]; then
        echo "Error: agy binary not found in PATH" >&2
        exit 1
    fi
fi

AGY_DIR="$(dirname "$AGY_BIN")"
AGY_ORIGINAL="$AGY_DIR/agy-original"

if [ -x "$AGY_ORIGINAL" ]; then
    echo "  Found existing agy-original at: $AGY_ORIGINAL"
    echo "  Skipping rename."
else
    echo "  Found agy at: $AGY_BIN"
    echo "  Renaming to: $AGY_ORIGINAL"
    mv "$AGY_BIN" "$AGY_ORIGINAL"
fi

AGENTS_DIR="$HOME/.agents/plugins/herdr"
mkdir -p "$AGENTS_DIR"

REPORTER_SRC="$REPO_ROOT/goose/plugins/herdr/herdr_report.py"
if [ -f "$REPORTER_SRC" ]; then
    echo "  Installing helper script to: $AGENTS_DIR/"
    cp "$REPORTER_SRC" "$AGENTS_DIR/"
    chmod +x "$AGENTS_DIR/herdr_report.py"
fi

echo "  Installing wrapper to: $AGY_BIN"
cp "$SCRIPT_DIR/agy-wrapper.sh" "$AGY_BIN"
chmod +x "$AGY_BIN"

echo ""
echo "Installation complete!"
echo ""
echo "Summary:"
echo "  - Original agy: $AGY_ORIGINAL"
echo "  - Wrapper script: $AGY_BIN"
echo "  - Report helper:  $AGENTS_DIR/herdr_report.py"
echo ""
echo "Now running agy inside herdr will automatically report it as an agent."
