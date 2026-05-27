---
name: herdr
description: Integrate with herdr terminal multiplexer. Report agent state (working/blocked/idle) when running inside herdr.
---

# Herdr Integration for Goose

When you are running inside a herdr terminal session, you MUST report your state to herdr using the helper script.

## Detection

You are running inside herdr if ANY of these are true:
- Environment variable `HERDR_ENV=1`
- Both `HERDR_SOCKET_PATH` and `HERDR_PANE_ID` environment variables are set

## State Reporting Script

Use the Python helper script. Look in these locations in order:
1. `~/.agents/plugins/herdr/herdr_report.py`
2. `~/Workspace/goose-config/plugins/herdr/herdr_report.py`

Usage:
```bash
python3 <path-to-script> <state>
```

## States

Report these states at the appropriate times:

| State | When to report |
|-------|----------------|
| `working` | When you start processing, calling tools, or actively working |
| `blocked` | When asking the user a question, waiting for permission/approval |
| `idle` | When you finish a task and are waiting for user input |
| `done` | When the user's request is fully completed |

## Required Reporting Flow

The wrapper script already reports `idle` at startup (TUI open, awaiting user input).
You only need to transition between states during work.

1. **When starting work**: When you receive a user prompt and begin processing:
   - Report `working`
   ```bash
   python3 ~/.agents/plugins/herdr-goose/herdr_report.py working
   ```

2. **Before asking a question**: Before using `question` tool or asking for user input:
   - Report `blocked`
   ```bash
   python3 ~/.agents/plugins/herdr-goose/herdr_report.py blocked
   ```

3. **After receiving user response**: After the user answers your question or gives permission:
   - Report `working`
   ```bash
   python3 ~/.agents/plugins/herdr-goose/herdr_report.py working
   ```

4. **When task is complete**: When you've finished the user's request:
   - Report `idle` (if waiting for next command) OR `done` (if fully complete)
   ```bash
   python3 ~/.agents/plugins/herdr-goose/herdr_report.py idle
   ```

5. **On exit**: The wrapper script automatically reports `release` when the TUI closes (telling herdr the agent is gone) — you don't need to handle this.

## Check Command

To verify herdr environment:
```bash
python3 ~/.agents/plugins/herdr/herdr_report.py check
```

## Important

- State reporting is non-blocking and failures can be silently ignored
- Always report state BEFORE the action that causes the state change
- This allows herdr to show your status in the sidebar for the user
