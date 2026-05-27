# agent-toolkit

Agent configuration, skills, and tooling integrations for Goose AI.

## Contents
- `skills/` — Custom skills loaded by goose
  - `herdr/` — Herdr terminal multiplexer integration
  - `goal/` — `/goal` skill for structured goal-driven autonomous execution
- `plugins/` — Integration plugins
- `config.yaml` — Goose configuration

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
bash ~/Workspace/agent-toolkit/plugins/herdr/install.sh
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
