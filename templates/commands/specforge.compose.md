## SpecForge: Compose Features from Requirement Units

You are executing the `/specforge.compose` command. Group requirement units into coherent, right-sized features with full traceability.

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

### Step 2: Validate Prerequisites
```bash
bash .specforge/scripts/bash/check-prerequisites.sh --json --phase compose
```
If `ready` is `false`, **STOP** and report:
- If units empty: "No requirement units found. Run `/specforge.distill` first to generate units from inbox files."
- If synthesis missing: "Synthesis overview not found. Run `/specforge.distill` first."

### Step 3: Clear Previous Features
Remove all existing feature directories from `requirements/features/`.

### Step 4: Read All Units and Synthesis
- Read every `UNIT-*.md` file from `requirements/units/`
- Read `requirements/synthesis/overview.md`
- Parse each unit's frontmatter (id, sources, uncertainty) and body (title, requirement, rationale)

### Step 5: Group Units into Features
Analyze all units and the synthesis overview. Group units into features by **business capability**. For each feature group:

1. Assign a sequential number (001, 002, ...)
2. Choose a descriptive name (kebab-case for the directory, human-readable for the content)
3. Target 3-8 units per feature

### Step 6: Create Feature Directories
For each feature group, run:
```bash
bash .specforge/scripts/bash/create-feature.sh --json --name "<feature-name>" --number <NNN>
```

Then write the four files in the created directory:

#### requirement.md
Write a cohesive, plain natural-language description of the feature. This must:
- Describe WHAT the feature does, WHO it serves, and WHY it matters
- Be consumable by `/speckit.specify` as input
- Contain NO implementation details

#### includes.md
```markdown
# Included Units: [Feature Name]

| Unit ID  | Title                    | Uncertainty |
|----------|--------------------------|-------------|
| UNIT-NNN | [title from unit file]   | [level]     |

**Total units**: [count]
```

#### sources.md
```markdown
# Source Traceability: [Feature Name]

## Unit → Inbox Mapping

| Unit ID  | Source Files                          |
|----------|---------------------------------------|
| UNIT-NNN | inbox/[files from unit frontmatter]   |

## Inbox Coverage

| Inbox File              | Units Derived          | Themes      |
|-------------------------|------------------------|-------------|
| inbox/[filename]        | UNIT-NNN, UNIT-MMM     | [themes]    |
```

#### readiness.md
Leave as the template placeholder — readiness is evaluated by `/specforge.status`.

### Step 7: Update Index
Write `requirements/index.md` with the feature listing:
```markdown
# Requirements Index

**Last updated**: [today's date]

## Features

| Feature ID | Name | Status | Units |
|------------|------|--------|-------|
| FEAT-001-name | [Human Name] | Pending | [count] |

## Statistics

- **Total inbox files**: [count]
- **Total units**: [count]
- **Total features**: [count]
- **Ready**: 0 | **Needs Refinement**: 0 | **Blocked**: 0
```

### Step 8: Report Results
Summarize: number of features created, unit distribution per feature, and any sizing flags.

## Agent Directives

**YOU MUST follow these rules strictly:**

1. **Group by business capability**: Features should represent coherent business domains, NOT arbitrary groupings by source file or alphabetical order
2. **Target 3-8 units per feature**: Flag features with <3 units as "under-scoped" and >8 units as "over-scoped" in the report
3. **requirement.md must be a narrative**: Write a cohesive description, not a bullet list of units. It must work as standalone input to `/speckit.specify`
4. **Every unit in exactly one feature**: No unit may be left unassigned. No unit may appear in multiple features.
5. **Every inbox file traceable**: Every inbox file must be represented through at least one unit in at least one feature
6. **No implementation details**: Feature descriptions must use business language only
