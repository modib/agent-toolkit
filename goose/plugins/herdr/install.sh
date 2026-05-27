#!/bin/bash
#
# Install the goose-herdr integration from this repo.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Installing goose-herdr integration..."
echo "  Repo root: $REPO_ROOT"

GOOSE_BIN=""
for dir in "$HOME/.local/bin" /usr/local/bin; do
    if [ -x "$dir/goose" ] && [ ! -L "$dir/goose" ]; then
        GOOSE_BIN="$dir/goose"
        break
    fi
done

if [ -z "$GOOSE_BIN" ]; then
    GOOSE_BIN="$(which goose 2>/dev/null || true)"
    if [ -z "$GOOSE_BIN" ]; then
        echo "Error: goose binary not found in PATH" >&2
        exit 1
    fi
fi

GOOSE_DIR="$(dirname "$GOOSE_BIN")"
GOOSE_ORIGINAL="$GOOSE_DIR/goose-original"

if [ -x "$GOOSE_ORIGINAL" ]; then
    echo "  Found existing goose-original at: $GOOSE_ORIGINAL"
    echo "  Skipping rename."
else
    echo "  Found goose at: $GOOSE_BIN"
    echo "  Renaming to: $GOOSE_ORIGINAL"
    mv "$GOOSE_BIN" "$GOOSE_ORIGINAL"
fi

AGENTS_DIR="$HOME/.agents/plugins/herdr"
mkdir -p "$AGENTS_DIR"
echo "  Installing helper script to: $AGENTS_DIR/"
cp "$SCRIPT_DIR/herdr_report.py" "$AGENTS_DIR/"
chmod +x "$AGENTS_DIR/herdr_report.py"

echo "  Installing wrapper to: $GOOSE_BIN"
cp "$SCRIPT_DIR/goose-wrapper.sh" "$GOOSE_BIN"
chmod +x "$GOOSE_BIN"

SKILLS_DIR="$HOME/.agents/skills/herdr"
if [ -d "$REPO_ROOT/goose/skills/herdr" ]; then
    mkdir -p "$SKILLS_DIR"
    echo "  Installing skill to: $SKILLS_DIR/"
    cp "$REPO_ROOT/goose/skills/herdr/SKILL.md" "$SKILLS_DIR/" 2>/dev/null || true
fi

echo ""
echo "Installation complete!"
echo ""
echo "Summary:"
echo "  - Original goose: $GOOSE_ORIGINAL"
echo "  - Wrapper script: $GOOSE_BIN"
echo "  - Report helper:  $AGENTS_DIR/herdr_report.py"
if [ -d "$SKILLS_DIR" ]; then
    echo "  - Skill:          $SKILLS_DIR/SKILL.md"
fi
echo ""
echo "Now running goose inside herdr will automatically report it as an agent."
echo "Goose will show up in the herdr sidebar with working/idle status."
