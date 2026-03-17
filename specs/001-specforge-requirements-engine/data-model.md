# Data Model: SpecForge — Pre-Specification Requirements Engine

**Branch**: `001-specforge-requirements-engine`
**Date**: 2026-03-17

## Overview

SpecForge operates entirely on file-system artifacts. There is no database — all entities are Markdown files with optional YAML frontmatter, organized in a fixed directory hierarchy under `requirements/`.

## Entities

### Inbox Item

**Location**: `requirements/inbox/<filename>`
**Format**: Any text-based file (`.md`, `.txt`, `.csv`, or similar)
**Lifecycle**: Created by user → Read by distill → Preserved (never modified or deleted by SpecForge)

| Attribute     | Type   | Description                                      |
|---------------|--------|--------------------------------------------------|
| file name     | string | Original file name as provided by user            |
| file type     | string | File extension (`.md`, `.txt`, etc.)              |
| content       | text   | Raw unstructured content                          |
| date added    | date   | File system creation/modification timestamp       |

**Validation rules**:
- Must be text-based (binary files are skipped with warning)
- At least one file must exist for distill to proceed (Distill Gate)

---

### Requirement Unit

**Location**: `requirements/units/UNIT-NNN.md`
**Format**: Markdown with YAML frontmatter

```markdown
---
id: UNIT-001
sources:
  - inbox/meeting-notes.md
  - inbox/braindump.txt
uncertainty: none | low | high
---

# UNIT-001: [Requirement Title]

**Requirement**: [WHAT the system must do — business capability language only]

**Rationale**: [WHY this requirement exists — business value or user need]

**Uncertainty**: [If any: explicit description of what is unclear]
```

| Attribute     | Type     | Description                                         |
|---------------|----------|-----------------------------------------------------|
| id            | string   | Sequential numeric identifier (`UNIT-NNN`), reassigned each distill run |
| sources       | string[] | List of inbox file paths that contributed to this unit |
| uncertainty   | enum     | `none`, `low`, `high` — explicit uncertainty level   |
| title         | string   | Brief descriptive title                              |
| requirement   | text     | WHAT statement — no implementation details            |
| rationale     | text     | WHY statement — business value justification          |

**Validation rules**:
- Must contain no implementation details (no technology names, no HOW)
- Must reference at least one inbox source file
- Uncertainty must be explicitly stated (even if `none`)
- ID must follow `UNIT-NNN` pattern with zero-padded 3-digit number

**State transitions**: Created (by distill) → Referenced (by compose) → Regenerated (on next distill run)

---

### Synthesis Overview

**Location**: `requirements/synthesis/overview.md`
**Format**: Markdown

```markdown
# Synthesis Overview

**Generated**: [date]
**Input files**: [count] files from inbox/
**Units generated**: [count] units

## Themes

### Theme 1: [Theme Name]
- Related units: UNIT-001, UNIT-003, UNIT-007
- Summary: [Brief description of this theme]

### Theme 2: [Theme Name]
- Related units: UNIT-002, UNIT-004
- Summary: [Brief description]

## Cross-Cutting Concerns
- [Concerns that span multiple themes]

## Identified Gaps
- [Information missing from inbox that would be needed]
- [Contradictions found between sources]

## Uncertainties
- [Explicit list of unresolved questions with source references]
```

| Attribute          | Type     | Description                                    |
|--------------------|----------|------------------------------------------------|
| generated date     | date     | When this synthesis was created                 |
| input file count   | number   | Number of inbox files processed                 |
| unit count         | number   | Number of units generated                       |
| themes             | object[] | Groupings of related units by topic             |
| cross-cutting      | string[] | Concerns spanning multiple themes               |
| gaps               | string[] | Missing information identified                  |
| uncertainties      | string[] | Unresolved questions with source references     |

**Validation rules**:
- Must exist before compose phase (Compose Gate)
- Every generated unit must appear in at least one theme
- Gaps and uncertainties must reference specific source files or units

---

### Feature

**Location**: `requirements/features/FEAT-NNN-name/`
**Format**: Directory containing exactly four Markdown files

#### requirement.md

```markdown
# [Feature Name]

[Plain natural-language description of the feature, written as a cohesive
narrative that describes what the feature does, who it serves, and why it
matters. This file is designed to be passed directly to `/speckit.specify`
as its input argument.]
```

#### includes.md

```markdown
# Included Units: [Feature Name]

| Unit ID  | Title                    | Uncertainty |
|----------|--------------------------|-------------|
| UNIT-001 | [Unit title]             | none        |
| UNIT-003 | [Unit title]             | low         |
| UNIT-007 | [Unit title]             | none        |

**Total units**: 3
```

#### sources.md

```markdown
# Source Traceability: [Feature Name]

## Unit → Inbox Mapping

| Unit ID  | Source Files                          |
|----------|---------------------------------------|
| UNIT-001 | inbox/meeting-notes.md                |
| UNIT-003 | inbox/braindump.txt, inbox/prd.md     |
| UNIT-007 | inbox/prd.md                          |

## Inbox Coverage

| Inbox File              | Units Derived | Themes      |
|-------------------------|---------------|-------------|
| inbox/meeting-notes.md  | UNIT-001      | Theme 1     |
| inbox/braindump.txt     | UNIT-003      | Theme 1     |
| inbox/prd.md            | UNIT-003, UNIT-007 | Theme 1 |
```

#### readiness.md

```markdown
# Readiness Assessment: [Feature Name]

**Status**: Ready | Needs Refinement | Blocked
**Evaluated**: [date]

## Criteria Check

| Criterion                    | Result | Details                     |
|------------------------------|--------|-----------------------------|
| Zero uncertainty markers     | PASS   |                             |
| All units have source refs   | PASS   |                             |
| Unit count in range (3-8)    | PASS   | 3 units                     |
| No contradictions            | PASS   |                             |
| All required files present   | PASS   |                             |

## Recommendation

[If Ready: "Feature is ready for `/speckit.specify requirements/features/FEAT-NNN-name/requirement.md`"]
[If Needs Refinement: specific items to address]
[If Blocked: what is missing and how to unblock]
```

| Attribute          | Type     | Description                                    |
|--------------------|----------|------------------------------------------------|
| feature ID         | string   | `FEAT-NNN-name` identifier                     |
| requirement        | text     | Plain-language feature description              |
| included units     | string[] | List of unit IDs composing this feature         |
| source mappings    | object[] | Unit → inbox file traceability                  |
| readiness status   | enum     | `Ready`, `Needs Refinement`, `Blocked`          |
| criteria results   | object[] | Individual pass/fail for each readiness criterion |

**Validation rules**:
- Must contain all four files (structural contract)
- Unit count must be 3-8 (flagged if outside range)
- requirement.md must contain no implementation details
- All units listed in includes.md must exist in `requirements/units/`
- All source files in sources.md must exist in `requirements/inbox/`

**State transitions**: Created (by compose) → Evaluated (by status) → Handed off (to Spec Kit) → Regenerated (on next compose run)

---

### Index

**Location**: `requirements/index.md`
**Format**: Markdown

```markdown
# Requirements Index

**Last updated**: [date]

## Features

| Feature ID       | Name              | Status           | Units |
|------------------|-------------------|------------------|-------|
| FEAT-001-auth    | Authentication    | Ready            | 5     |
| FEAT-002-dash    | Dashboard         | Needs Refinement | 4     |

## Statistics

- **Total inbox files**: [count]
- **Total units**: [count]
- **Total features**: [count]
- **Ready**: [count] | **Needs Refinement**: [count] | **Blocked**: [count]
```

## Entity Relationships

```text
Inbox Item (1..*) ──sources──► Requirement Unit (1..*)
Requirement Unit (3..8) ──includes──► Feature (1)
Requirement Unit (1..*) ──themes──► Synthesis Overview (1)
Feature (1) ──evaluated──► Readiness Assessment (1)
Feature (1) ──handoff──► Spec Kit /speckit.specify
```

## Directory Hierarchy

```text
requirements/
├── inbox/           # Inbox Items (user-managed, read-only by SpecForge)
├── synthesis/
│   └── overview.md  # Synthesis Overview (regenerated each distill)
├── units/
│   ├── UNIT-001.md  # Requirement Units (regenerated each distill)
│   ├── UNIT-002.md
│   └── ...
├── features/
│   └── FEAT-NNN-name/  # Features (regenerated each compose)
│       ├── requirement.md
│       ├── includes.md
│       ├── sources.md
│       └── readiness.md
└── index.md         # Master index (updated by status)
```
