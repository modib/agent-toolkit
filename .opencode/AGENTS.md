# goose-config - Herdr Integration & Agent Skills

## Meta-Repository Overview

This is a meta-repo tracking Goose AI agent configuration, skills, and goals.

**Git Repo:** `~/Workspace/goose-config/`
**Copied to runtime:** `~/.agents/`, `~/.config/opencode/plugins/`

---

## Directory Structure

```
goose-config/
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
├── goals/
│   ├── modi-in-news/
│   │   └── PLAN.md            # modi.im news credibility tracker (COMPLETED)
│   └── workspace-github-setup/
│       └── PLAN.md            # Workspace + GitHub workflow setup
│
├── .opencode/
│   ├── opencode.jsonc         # This project config
│   └── AGENTS.md              # This file
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
| **Opencode Plugin** | (not here, auto-installed) | `~/.config/opencode/plugins/herdr-agent-state.js` | Native opencode integration (AUTO-ISOLATING) |

### Herdr Skill Instructions (`skills/herdr/SKILL.md`)

When running inside herdr, goose must report:
1. `working` when starting processing
2. `blocked` BEFORE asking questions/waiting for permission
3. `working` after receiving user response
4. `idle` or `done` when complete

### Opencode Plugin is Already Isolated!

The `herdr-agent-state.js` plugin has built-in separation:
```javascript
// Only activates inside herdr:
if (process.env.HERDR_ENV !== "1" ||
    !process.env.HERDR_SOCKET_PATH ||
    !process.env.HERDR_PANE_ID) {
  return {};  // Does nothing outside herdr!
}
```

### Installation

```bash
bash ~/Workspace/goose-config/plugins/herdr/install.sh
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

## Goals Tracking (`goals/`)

### modi-in-news (`goals/modi-in-news/PLAN.md`)
**Status:** ✅ COMPLETE — Delivered May 26, 2026

**Original Plan:** Node.js + vanilla JS version at `~/Workspace/modi.im/`
**Active Dev Version:** FastAPI + React at `~/Workspace/modi-im/` (separate project)

### workspace-github-setup (`goals/workspace-github-setup/PLAN.md`)
**Status:** In Progress

Goal: `~/Workspace` as default workspace, all projects as git repos, personal projects on GitHub.

---

## Related Directories

| Path | Purpose |
|------|---------|
| `~/.agents/` | Runtime location for skills/plugins (copied from here during install) |
| `~/.config/herdr/` | Herdr runtime: socket, logs (NOT development) |
| `~/.config/opencode/plugins/` | Opencode plugins including `herdr-agent-state.js` |
| `~/Workspace/modi-im/` | **SEPARATE PROJECT**: FastAPI+React news credibility (active dev) |
| `~/Workspace/modi.im/` | **SEPARATE PROJECT**: Node.js news credibility (legacy, completed) |

---

## Context from Recent Sessions

- **Issue investigated:** "Herdr failing to identify Goose as agent"
- **Key finding:** Opencode plugin `herdr-agent-state.js` already has built-in isolation via `HERDR_ENV` check - it does nothing outside herdr
- **Combined session:** This herdr work was discussed in the same session as modi.im news credibility work; they are SEPARATE projects

---

## For Future Herdr Work

1. Start from this repo: `cd ~/Workspace/goose-config/`
2. Check the herdr skill at `skills/herdr/SKILL.md`
3. Check the reporter at `plugins/herdr/herdr_report.py`
4. Verify integration by running inside a herdr pane:
   ```bash
   python3 ~/.agents/plugins/herdr-goose/herdr_report.py check
   ```
5. Consider adding `opencode-sessions` npm plugin for advanced multi-agent support
