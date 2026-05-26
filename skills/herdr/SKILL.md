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

1. **At startup**: If herdr is detected, report `working` immediately when you begin processing.

2. **Before asking a question**: Before using `question` tool or asking for user input:
   - Report `blocked` state

3. **After receiving user response**: After the user answers your question or gives permission:
   - Report `working` state

4. **When task is complete**: When you've finished the user's request:
   - Report `idle` (if waiting for next command) OR `done` (if fully complete)

## Check Command

To verify herdr environment:
```bash
python3 ~/.agents/plugins/herdr/herdr_report.py check
```

## Important

- State reporting is non-blocking and failures can be silently ignored
- Always report state BEFORE the action that causes the state change
- This allows herdr to show your status in the sidebar for the user
