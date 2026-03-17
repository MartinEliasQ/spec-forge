## SpecForge: Full Pipeline — Distill → Compose → Status

You are executing the `/specforge.prepare` command. Run the complete SpecForge pipeline in sequence.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### Step 1: Auto-Initialize
Run from repo root:
```bash
bash .specforge/scripts/bash/setup-requirements.sh --json
```
Report: directory structure status.

### Step 2: Execute Distill Phase
Execute the full `/specforge.distill` workflow:
1. Run `check-prerequisites.sh --json --phase distill`
2. If not ready → **HALT PIPELINE** and report what's missing
3. Clear existing units and synthesis
4. Read all inbox files
5. Extract atomic requirement units (WHAT + WHY only, no implementation details)
6. Write `UNIT-NNN.md` files to `requirements/units/`
7. Write `requirements/synthesis/overview.md`
8. Report distill results

**If distill fails at any point → HALT. Report the error and do NOT proceed to compose.**

### Step 3: Execute Compose Phase
Execute the full `/specforge.compose` workflow:
1. Run `check-prerequisites.sh --json --phase compose`
2. If not ready → **HALT PIPELINE** (distill outputs are preserved)
3. Clear existing features
4. Read all units and synthesis
5. Group units into features by business capability (3-8 units each)
6. For each feature: run `create-feature.sh`, write requirement.md, includes.md, sources.md
7. Update `requirements/index.md`
8. Report compose results

**If compose fails → HALT. Distill outputs are preserved. Report the error.**

### Step 4: Execute Status Phase
Execute the full `/specforge.status` workflow:
1. Run `check-prerequisites.sh --json --phase status`
2. Evaluate each feature against readiness criteria
3. Write `readiness.md` per feature
4. Update `requirements/index.md` with statuses
5. Report status results

### Step 5: Report Combined Summary
Display a full pipeline summary:

```
SpecForge Pipeline Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━

Distill:
  - Inbox files processed: [count]
  - Requirement units generated: [count]
  - Themes identified: [count]
  - Uncertainties flagged: [count]

Compose:
  - Features composed: [count]
  - Unit distribution: [min]-[max] units per feature
  - Sizing flags: [any under/over-scoped features]

Status:
  - Ready: [count]
  - Needs Refinement: [count]
  - Blocked: [count]

Ready for handoff:
  /speckit.specify requirements/features/FEAT-NNN-name/requirement.md
```

## Halt Behavior

- If **distill fails**: Stop immediately. Report what went wrong. Suggest fixing the issue and re-running `/specforge.prepare`.
- If **compose fails**: Stop. Distill outputs are preserved in `requirements/units/` and `requirements/synthesis/`. Report the error.
- If **status fails**: Report the error but note that distill and compose outputs are intact.

Partial outputs from completed phases are NEVER rolled back.
