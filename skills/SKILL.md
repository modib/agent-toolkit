---
name: goal
description: Execute complex objectives with structured planning, phased milestones, and full inspectability. When user invokes /goal, switch to goal-driven autonomous execution mode.
---

# /goal — Goal-Driven Autonomous Execution

When the user types `/goal <desired outcome>`, you switch to **goal-driven mode** — a structured methodology for tackling complex objectives with full transparency.

## Core Protocol

### Phase 0: Acknowledge & Clarify
1. **Acknowledge** the `/goal` command and restate the desired outcome clearly
2. **Assess clarity**: Does the goal need clarification?
   - If **absolutely necessary** (ambiguous scope, conflicting constraints, missing key info), ask focused clarifying questions (max 3)
   - If the goal is reasonably clear, skip asking and proceed directly to planning
3. Document all assumptions explicitly — never proceed with hidden assumptions

### Phase 1: Plan — Document Architecture, Design & Milestones

Create a comprehensive plan document at `~/.config/goose/goals/<goal-name>/PLAN.md`:

```markdown
# Goal: <title>

## Desired Outcome
<restated goal>

## Assumptions
<explicit list of all assumptions made>

## Architecture / Design
<high-level approach, system design, key decisions>

## Phases & Milestones

### Phase 1: <name> — Foundation
**Goal:** <what this phase achieves>
**Key Deliverables:**
- [ ] <deliverable 1>
- [ ] <deliverable 2>
**Estimated complexity:** <low/medium/high>

### Phase 2: <name> — Core
...
```

**Always use `todoWrite`** to track progress across all phases. The task list should show:
- All phases with checkboxes
- Current phase highlighted as in-progress
- Completed phases marked done

### Phase 2: Execute — Phase by Phase
1. Execute phases **sequentially** — each phase builds on the last
2. For each phase:
   - Update `todoWrite` marking current phase as in-progress
   - Execute all deliverables for that phase
   - Update `todoWrite` marking items done
   - Report completion and summary to the user
3. Use `delegate(async: true, instructions: "...")` for **parallel research sub-tasks** (read-only)
4. Use `delegate(async: true, source: "goal-worker", instructions: "...")` for implementation sub-tasks that don't touch the same files (partition by file)

### Phase 3: Document & Report
1. **Update `PLAN.md`** with:
   - What was actually done vs planned
   - Any deviations with rationale
   - Current status of each deliverable
2. Present a clear summary to the user

## Inspectability
The user can check progress anytime by reading:
- `~/.config/goose/goals/<goal-name>/PLAN.md` — full plan + status
- The `todoWrite` content shows real-time task tracking
- Each chat turn shows current phase and progress

## Rules
- **Always work from the plan** — never skip planning and jump into execution
- If the plan needs revision during execution, update the plan first, then proceed
- Document all design decisions, trade-offs, and rationale
- Ask clarifying questions only when truly stuck — prefer documenting assumptions over asking
- When delegating, partition work strictly so no two delegates touch the same file
- Use `todoWrite()` to maintain a visible task list at all times
## Policy: GitHub Repo Creation
New GitHub repositories MUST always be created as **private**. Use:
```bash
gh repo create <name> --private --source=. --push
```

This is enforced by aliases `git repo-priv` and `gh-repo`.
