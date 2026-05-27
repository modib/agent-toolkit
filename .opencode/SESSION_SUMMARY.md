# Session Summary: herdr & Goose Integration Work

## Project: goose-config (Herdr Terminal Multiplexer Integration)
**Location:** `~/Workspace/goose-config/`

---

## Context from Combined Session

This work was discussed in a combined session that also covered modi.im news credibility work. These are SEPARATE projects.

---

## Herdr Integration Overview

**Herdr:** Terminal multiplexer (like tmux) with AI agent state integration
**Integration Purpose:** Let goose/opencode report their state (working/blocked/idle) to herdr for display

---

## Integration Components

### 1. Herdr Skill (`skills/herdr/SKILL.md`)
Teaches goose to self-report state when inside herdr:
- Report `working` when starting processing
- Report `blocked` BEFORE asking questions
- Report `working` after receiving response
- Report `idle`/`done` when complete

**Environment Detection:**
- `HERDR_ENV=1`
- OR both `HERDR_SOCKET_PATH` AND `HERDR_PANE_ID` set

### 2. Python Reporter (`plugins/herdr/herdr_report.py`)
Unix socket API client to report state to herdr.

**Usage:**
```bash
python3 herdr_report.py <state>
# States: working, blocked, idle, done, release, check

# Check if inside herdr:
python3 herdr_report.py check
```

**Socket JSON-RPC format:**
```json
{
  "id": "herdr:opencode:timestamp:random",
  "method": "pane.report_agent",
  "params": {
    "pane_id": "pane_xxx",
    "source": "herdr:opencode",
    "agent": "opencode",
    "state": "working",
    "seq": 12345
  }
}
\n
```

### 3. Goose Wrapper (`plugins/herdr/goose-wrapper.sh`)
Intercepts the goose binary, reports state to herdr, then execs original.

### 4. Installer (`plugins/herdr/install.sh`)
1. Finds goose binary (`~/.local/bin/goose` or `/usr/local/bin/goose`)
2. Renames: `goose` → `goose-original`
3. Installs wrapper script as `goose`
4. Copies skill to `~/.agents/skills/herdr/`

### 5. Opencode Native Plugin (`~/.config/opencode/plugins/herdr-agent-state.js`)
**INSTALLED SEPARATELY, auto-isolating!**

```javascript
// Only activates inside herdr:
if (process.env.HERDR_ENV !== "1" ||
    !process.env.HERDR_SOCKET_PATH ||
    !process.env.HERDR_PANE_ID) {
  return {};  // Does nothing outside herdr!
}
```

**State mapping:**
| Opencode Event | herdr State |
|----------------|-------------|
| `permission.asked` | `blocked` |
| `question.asked` | `blocked` |
| `permission.replied` (once/always) | `working` |
| `permission.replied` (reject) | `idle` |
| `question.replied` | `working` |
| `question.rejected` | `idle` |
| `session.status: busy/retry` | `working` |
| `session.status: idle` | `idle` |
| `session.idle` | `idle` |

---

## File Locations

| Item | This Repo (`~/Workspace/goose-config/`) | Runtime Location |
|------|-------------------------------------------|------------------|
| Herdr Skill | `skills/herdr/SKILL.md` | `~/.agents/skills/herdr/SKILL.md` |
| State Reporter | `plugins/herdr/herdr_report.py` | `~/.agents/plugins/herdr-goose/herdr_report.py` |
| Goose Wrapper | `plugins/herdr/goose-wrapper.sh` | Replaces `goose` binary |
| Installer | `plugins/herdr/install.sh` | - |
| Opencode Plugin | (not in this repo) | `~/.config/opencode/plugins/herdr-agent-state.js` |
| Herdr Runtime | (not in this repo) | `~/.config/herdr/` (socket, logs) |

---

## Issue Investigated

**Problem:** "Herdr failing to identify Goose as agent"

**Key Finding:** The opencode plugin `herdr-agent-state.js` ALREADY has built-in isolation via the `HERDR_ENV` check. It will never report state or interfere when running outside herdr.

---

## Other Content in This Repo

| Item | Location | Description |
|------|----------|-------------|
| Goal Skill | `skills/goal/SKILL.md` | `/goal` command for autonomous execution |
| modi-in-news Goal | `goals/modi-in-news/PLAN.md` | **SEPARATE PROJECT** tracking (COMPLETED) |
| workspace-github-setup | `goals/workspace-github-setup/PLAN.md` | Workspace/GitHub workflow setup |

---

## How to Work on Herdr Next Time

```bash
cd ~/Workspace/goose-config/
opencode
```

This project (goose-config) is a GIT repo and will be detected properly by opencode.

---

## Related But Separate

**modi.im News Credibility Project:**
- Active development: `~/Workspace/modi-im/` (FastAPI + React)
- Legacy completed: `~/Workspace/modi.im/` (Node.js)
- This is a COMPLETELY SEPARATE project from herdr integration
