# goose-config

Meta-repository tracking Goose AI agent configuration, skills, and goals.

## Contents
- `skills/` — Custom skills loaded by goose
  - `goal/` — `/goal` skill for structured goal-driven autonomous execution
  - `herdr/` — Herdr terminal multiplexer integration
- `plugins/` — Integration plugins
- `config.yaml` — Goose configuration files
- `goals/` — Goal-specific documentation and progress tracking
  - `workspace-github-setup/` — Workspace + GitHub workflow setup goal

## Setup
This repo tracks goose's configuration for portability and backup.

## Integrations

### Herdr Terminal Multiplexer

Allows goose to report its agent state (working/blocked/idle/done) to [herdr](https://herdr.dev) terminal multiplexer.

**Files:**
- `plugins/herdr/herdr_report.py` — Python helper to report state via herdr socket API
- `plugins/herdr/goose-wrapper.sh` — Shell wrapper that auto-reports state
- `plugins/herdr/install.sh` — Installer script
- `skills/herdr/SKILL.md` — Skill teaching goose to self-report state

**Installation:**
```bash
bash ~/Workspace/goose-config/plugins/herdr/install.sh
```

This will:
1. Rename your existing `goose` binary to `goose-original`
2. Install the wrapper script as `goose`
3. Copy the helper script and skill to `~/.agents/`

**How it works:**
- When goose starts inside a herdr pane, herdr sets environment variables
- The wrapper detects these and reports `agent=goose` with `state=working`
- When goose exits, it reports `state=idle`
- For advanced state tracking, the herdr skill teaches goose to report `blocked` when asking questions

**Uninstall:**
```bash
# Revert to original goose binary
mv ~/.local/bin/goose-original ~/.local/bin/goose
```
