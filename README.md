# agent-toolkit

Agent configuration, skills, and tooling integrations for Goose AI and Opencode.

## Structure

```
agent-toolkit/
├── goose/                    # Goose AI agent artifacts
│   ├── skills/
│   │   ├── herdr/            # Herdr state-reporting skill
│   │   └── goal/             # /goal skill for autonomous execution
│   ├── plugins/herdr/        # Herdr integration (wrapper, reporter, installer)
│   └── config.yaml           # Goose configuration
├── opencode/                 # Opencode agent artifacts
│   └── plugins/
│       └── herdr-agent-state.js  # Native opencode herdr plugin
└── README.md
```

## Integrations

### Herdr Terminal Multiplexer

Allows goose/opencode to report agent state (working/blocked/idle) to [herdr](https://herdr.dev).

**For Goose:**
```bash
bash goose/plugins/herdr/install.sh
```

**For Opencode:**
The herdr plugin is auto-installed by `herdr integration install opencode`. The source is in `opencode/plugins/herdr-agent-state.js`.

**Files:**
- `goose/plugins/herdr/herdr_report.py` — Python helper for herdr socket API
- `goose/plugins/herdr/goose-wrapper.sh` — Goose binary wrapper
- `goose/plugins/herdr/install.sh` — Installer for goose integration
- `goose/skills/herdr/SKILL.md` — Skill teaching goose to self-report state
- `opencode/plugins/herdr-agent-state.js` — Native opencode plugin
