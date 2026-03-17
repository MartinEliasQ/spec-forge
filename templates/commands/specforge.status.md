## SpecForge: Check Feature Readiness Status

You are executing the `/specforge.status` command. Evaluate each composed feature's readiness and report status.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### Step 1: Auto-Initialize
Run from repo root:
```bash
bash scripts/bash/setup-requirements.sh --json
```

### Step 2: Validate Prerequisites
```bash
bash scripts/bash/check-prerequisites.sh --json --phase status
```
If `ready` is `false`, **STOP** and report:
- If no features: "No feature directories found. Run `/specforge.compose` first to create features from requirement units."

### Step 3: Evaluate Each Feature
For each feature directory in `requirements/features/FEAT-*`:

#### 3a. Check Required Files
Verify all four files exist: `requirement.md`, `includes.md`, `sources.md`, `readiness.md`. If any are missing → **Blocked**.

#### 3b. Check Unit Count
Read `includes.md` and count the units listed. Check if count is in range 3-8.

#### 3c. Check Uncertainty Markers
For each unit listed in `includes.md`, read the corresponding `UNIT-NNN.md` file from `requirements/units/`. Check the `uncertainty` field in the frontmatter. Any value other than `none` counts as an uncertainty marker.

#### 3d. Check Source References
Read `sources.md` and verify all units listed in `includes.md` have at least one source reference in the Unit → Inbox Mapping table.

#### 3e. Check for Contradictions
Read the content of all included unit files. Look for units with `uncertainty: high` that mention contradictions, or units where requirements conflict with each other.

#### 3f. Determine Status
Apply these strict criteria:

| Criterion | Ready | Needs Refinement |
|-----------|-------|-------------------|
| All required files present | Yes | Yes |
| Zero uncertainty markers (all units have `uncertainty: none`) | Yes | No — any non-none |
| All units have source references | Yes | No — any missing |
| Unit count in range (3-8) | Yes | No — outside range |
| No contradictions | Yes | No — any found |

- **Ready**: ALL criteria pass
- **Needs Refinement**: All files present but one or more content criteria fail
- **Blocked**: Any required file is missing

### Step 4: Write Readiness Assessments
For each feature, write `readiness.md`:

```markdown
# Readiness Assessment: [Feature Name]

**Status**: [Ready | Needs Refinement | Blocked]
**Evaluated**: [today's date]

## Criteria Check

| Criterion                    | Result | Details                     |
|------------------------------|--------|-----------------------------|
| Zero uncertainty markers     | [PASS/FAIL] | [details]              |
| All units have source refs   | [PASS/FAIL] | [details]              |
| Unit count in range (3-8)    | [PASS/FAIL] | [count] units          |
| No contradictions            | [PASS/FAIL] | [details]              |
| All required files present   | [PASS/FAIL] |                        |

## Recommendation

[If Ready: "Feature is ready for handoff. Run: `/speckit.specify requirements/features/FEAT-NNN-name/requirement.md`"]
[If Needs Refinement: List specific items to address with actionable guidance]
[If Blocked: Describe what is missing and how to unblock]
```

### Step 5: Update Index
Update `requirements/index.md` with current statuses:

```markdown
# Requirements Index

**Last updated**: [today's date]

## Features

| Feature ID | Name | Status | Units |
|------------|------|--------|-------|
| FEAT-001-name | [Name] | [Ready/Needs Refinement/Blocked] | [count] |

## Statistics

- **Total inbox files**: [count from inbox/]
- **Total units**: [count from units/]
- **Total features**: [count]
- **Ready**: [count] | **Needs Refinement**: [count] | **Blocked**: [count]
```

### Step 6: Report Results
Display a summary table:

```
Feature Status Summary
━━━━━━━━━━━━━━━━━━━━━
| Feature | Status | Units | Issues |
|---------|--------|-------|--------|
| FEAT-001-name | Ready | 5 | — |
| FEAT-002-name | Needs Refinement | 4 | 2 uncertainties |
```

For Ready features, include the handoff command:
```
/speckit.specify requirements/features/FEAT-NNN-name/requirement.md
```

## Readiness Evaluation Rules

These criteria are **strict and non-negotiable**:

1. **Ready** = Zero uncertainty markers AND all units have source refs AND 3-8 units AND no contradictions AND all files present
2. **Needs Refinement** = All files present but ANY single content criterion fails. Report which criteria failed and what specifically needs attention.
3. **Blocked** = Any required file (requirement.md, includes.md, sources.md, readiness.md) is missing. Report which files are missing.

There is no "partial ready" or "mostly ready". A single failing criterion moves a feature from Ready to Needs Refinement.
