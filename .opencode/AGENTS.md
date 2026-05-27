# agent-toolkit

## Meta-Repository Overview

Artifacts organized by agent. Currently:

| Agent | Directory | Contents |
|-------|-----------|----------|
| **Goose** | `goose/` | Herdr integration (wrapper, reporter, installer, skill), goal skill, config |
| **Opencode** | `opencode/` | Herdr native plugin |

**Git Repo:** `~/Workspace/agent-toolkit/`
**Runtime paths:** `~/.agents/`, `~/.config/opencode/plugins/`

---

## Directory Structure

```
agent-toolkit/
├── goose/
│   ├── skills/
│   │   ├── herdr/SKILL.md       # Herdr state-reporting skill
│   │   └── goal/SKILL.md        # /goal skill for autonomous execution
│   ├── plugins/herdr/
│   │   ├── herdr_report.py      # State reporter (Python)
│   │   ├── goose-wrapper.sh     # Binary wrapper
│   │   └── install.sh           # Installer script
│   └── config.yaml              # Goose configuration
├── opencode/
│   └── plugins/
│       └── herdr-agent-state.js # Native opencode herdr plugin
└── README.md
```

---

## Goose — Herdr Integration

### Overview

Allows goose to report agent state to herdr terminal multiplexer.

### How it Works

```
goose starts inside herdr pane
         ↓
herdr sets env vars: HERDR_ENV, HERDR_SOCKET_PATH, HERDR_PANE_ID
         ↓
Wrapper detects herdr environment
         ↓
Reports via Unix socket: working / blocked / idle / release
```

### Components

| Component | Path in Repo | Runtime Location | Purpose |
|-----------|-------------|------------------|---------|
| Python Reporter | `goose/plugins/herdr/herdr_report.py` | `~/.agents/plugins/herdr-goose/` | Unix socket API client |
| Goose Wrapper | `goose/plugins/herdr/goose-wrapper.sh` | Replaces `goose` binary | Intercepts, reports state |
| Goose Skill | `goose/skills/herdr/SKILL.md` | `~/.agents/skills/herdr/` | Self-report state during session |
| Installer | `goose/plugins/herdr/install.sh` | - | One-shot setup |

### Installation

```bash
bash ~/Workspace/agent-toolkit/goose/plugins/herdr/install.sh
```

### Uninstallation

```bash
mv ~/.local/bin/goose-original ~/.local/bin/goose
```

---

## Opencode — Herdr Integration

### Overview

Opencode's native herdr plugin at `opencode/plugins/herdr-agent-state.js` provides state reporting via the `HerdrAgentStatePlugin` export. It is the source that gets installed by `herdr integration install opencode`.

The upstream source is at `~/Workspace/herdr/src/integration/assets/opencode/herdr-agent-state.js`. This copy tracks our local changes for upstream contribution.

### Exit Handling

The plugin registers process exit handlers to report `release` on termination:
- `beforeExit` — graceful shutdown
- `SIGINT` / `SIGTERM` / `SIGHUP` / `SIGQUIT` — signals

---

## Upstream Contributions

| Project | Mechanism | Status |
|---------|-----------|--------|
| **herdr** (opencode plugin) | Issue + PR to `ogulcancelik/herdr` | Issue #314 open, awaiting `/approve` |
| **goose** (herdr integration) | Recipe PR to `aaif-goose/goose` | Recipe file in `~/Workspace/goose-fork` |
