#!/bin/bash
#
# Install the code-shield security skills for goose.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Installing code-shield security skills..."
echo "  Repo root: $REPO_ROOT"

SKILLS_SRC="$REPO_ROOT/goose/skills/code-shield"
SKILLS_DIR="$HOME/.agents/skills/code-shield"

if [ ! -d "$SKILLS_SRC" ]; then
    echo "Error: skills source directory not found at $SKILLS_SRC" >&2
    exit 1
fi

echo "  Installing skills to: $SKILLS_DIR/"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$SKILLS_DIR/$skill_name"
    if [ -f "$skill_dir/SKILL.md" ]; then
        cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/"
        echo "    - $skill_name"
    fi
done

echo ""
echo "  Installing semgrep (security scanner)..."
if command -v semgrep &>/dev/null; then
    echo "    semgrep already installed at $(which semgrep)"
else
    install_semgrep() {
        if command -v pip3 &>/dev/null; then
            pip3 install semgrep --quiet 2>/dev/null || pip3 install semgrep --quiet --break-system-packages 2>/dev/null || return 1
        elif command -v pip &>/dev/null; then
            pip install semgrep --quiet 2>/dev/null || pip install semgrep --quiet --break-system-packages 2>/dev/null || return 1
        else
            return 1
        fi
    }
    if install_semgrep; then
        echo "    semgrep installed successfully"
    else
        echo "    WARNING: could not install semgrep via pip. Install manually: pip install semgrep"
    fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "Summary:"
echo "  - Skills installed to: $SKILLS_DIR/"
echo "    Includes: run-security-scanner, scan-dependencies, determine-threat-model,"
echo "              create-security-implementation-plan, run-poc,"
echo "              generate-security-audit-report, mandatory-secure-web-skills,"
echo "              code-shield-persona"
if command -v semgrep &>/dev/null; then
    echo "  - semgrep:          $(semgrep --version 2>/dev/null || echo 'installed')"
fi
echo ""
echo "Code-Shield is ready. Goose will now have security scanning skills available."
echo "Use code-shield-persona to orchestrate the full security remediation pipeline."
