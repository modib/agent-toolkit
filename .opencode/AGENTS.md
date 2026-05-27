# agent-toolkit - Herdr Integration & Agent Skills

## Meta-Repository Overview

This is a meta-repo tracking Goose AI agent configuration, skills, and integrations.

**Git Repo:** `~/Workspace/agent-toolkit/`
**Copied to runtime:** `~/.agents/`, `~/.config/opencode/plugins/`

---

## Directory Structure

```
agent-toolkit/
├── skills/
│   ├── herdr/
│   │   └── SKILL.md           # Herdr terminal multiplexer integration
│   └── goal/
│       └── SKILL.md           # /goal skill for autonomous execution
│
├── plugins/
│   └── herdr/
│       ├── herdr_report.py    # State reporter (Python)
│       ├── goose-wrapper.sh   # Binary wrapper
│       └── install.sh         # Installer script
│
├── config.yaml                # Goose configuration
└── README.md
```

---

## Herdr Integration (Primary Focus)

### Overview

Herdr is a terminal multiplexer (like tmux) with AI agent state integration. This repo contains the integration that lets goose/opencode report their state to herdr.

### How it Works

```
goose starts inside herdr pane
         ↓
herdr sets env vars:
  - HERDR_ENV=1
  - HERDR_SOCKET_PATH=/path/to/herdr.sock
  - HERDR_PANE_ID=pane_xxx
         ↓
Wrapper/plugin detects herdr environment
         ↓
Reports agent state via Unix socket API:
  - working = actively processing
  - blocked = waiting for user input/permission
  - idle = waiting for next command
  - done = task complete
```

### Components

| Component | Path in this Repo | Runtime Location | Purpose |
|-----------|-------------------|------------------|---------|
| **Python Reporter** | `plugins/herdr/herdr_report.py` | `~/.agents/plugins/herdr-goose/` | Unix socket API client |
| **Goose Wrapper** | `plugins/herdr/goose-wrapper.sh` | Replaces `goose` binary | Intercepts, reports state, execs original |
| **Goose Skill** | `skills/herdr/SKILL.md` | `~/.agents/skills/herdr/` | Teaches goose to self-report state |
| **Installer** | `plugins/herdr/install.sh` | - | Renames goose → goose-original, installs wrapper |
| **Opencode Plugin** | (auto-installed by herdr) | `~/.config/opencode/plugins/herdr-agent-state.js` | Native opencode integration |

### Herdr Skill Instructions (`skills/herdr/SKILL.md`)

When running inside herdr, goose must report:
1. `working` when starting processing
2. `blocked` BEFORE asking questions/waiting for permission
3. `working` after receiving user response
4. `idle` or `done` when complete

### Installation

```bash
bash ~/Workspace/agent-toolkit/plugins/herdr/install.sh
```

This:
1. Renames `goose` → `goose-original`
2. Installs wrapper script as `goose`
3. Copies skill to `~/.agents/skills/herdr/`

### Uninstallation

```bash
mv ~/.local/bin/goose-original ~/.local/bin/goose
```

---

## Goal Skill (`skills/goal/SKILL.md`)

The `/goal` skill provides structured goal-driven autonomous execution with:
- Task tracking with todo list
- State management (todo, in_progress, done, blocked, cancelled)
- Sub-agent delegation
- Progress updates

---

## Related Directories

| Path | Purpose |
|------|---------|
| `~/.agents/` | Runtime location for skills/plugins (copied from here during install) |
| `~/.config/herdr/` | Herdr runtime: socket, logs (NOT development) |
| `~/.config/opencode/plugins/` | Opencode plugins including `herdr-agent-state.js` |
