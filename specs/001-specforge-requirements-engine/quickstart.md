# Quickstart: SpecForge — Pre-Specification Requirements Engine

**Branch**: `001-specforge-requirements-engine`
**Date**: 2026-03-17

## Prerequisites

- Bash 5.x (macOS/Linux) or PowerShell 7+ (Windows)
- Git repository with Spec Kit (`.specify/`) already initialized
- Claude Code CLI (for agent skill execution)
- Optional: jq (improves JSON output formatting)
- Optional: bats (for running script tests)

## Setup

SpecForge initializes automatically on first command run. To set up manually:

```bash
# From repository root
bash .specforge/scripts/bash/setup-requirements.sh --json
```

This creates:
```
requirements/
├── inbox/
├── synthesis/
├── units/
├── features/
└── index.md
```

## Basic Workflow

### 1. Add raw inputs to the inbox

Drop unstructured documents into `requirements/inbox/`:
```bash
cp meeting-notes.md requirements/inbox/
cp braindump.txt requirements/inbox/
cp prd-draft.md requirements/inbox/
```

Supported formats: `.md`, `.txt`, `.csv`, or any text-based file.

### 2. Distill into structured requirements

```
/specforge.distill
```

This reads all inbox files and produces:
- Atomic requirement units in `requirements/units/` (UNIT-001.md, UNIT-002.md, ...)
- Synthesis overview in `requirements/synthesis/overview.md`

### 3. Compose features

```
/specforge.compose
```

This groups requirement units into coherent features (3-8 units each) under `requirements/features/`.

### 4. Check readiness

```
/specforge.status
```

Reports each feature's status: Ready, Needs Refinement, or Blocked.

### 5. Hand off to Spec Kit

For features marked "Ready":
```
/speckit.specify requirements/features/FEAT-001-name/requirement.md
```

### One-step pipeline

Run all three phases in sequence:
```
/specforge.prepare
```

## Key Concepts

| Concept | Description |
|---------|-------------|
| Inbox | Where you drop raw, unstructured inputs |
| Unit | An atomic requirement (WHAT + WHY, no HOW) |
| Synthesis | A consolidated view of themes, gaps, and uncertainties |
| Feature | A cohesive grouping of 3-8 units by business capability |
| Readiness | Strict evaluation: zero uncertainties, full traceability, right-sized |

## Important Notes

- **Regeneration**: Each distill/compose run regenerates all outputs from scratch. Previous outputs are replaced.
- **No implementation details**: SpecForge strips technology references. Units describe WHAT and WHY only.
- **Traceability**: Every feature traces back to units, and every unit traces back to inbox source files.
- **Inbox is read-only**: SpecForge never modifies or deletes inbox files.

## Development

### Running tests

```bash
# Install bats if needed
brew install bats-core  # macOS
# or: apt-get install bats  # Linux

# Run all tests
bats tests/bash/

# Run specific test
bats tests/bash/test_setup_requirements.bats
```

### Project structure

```
.specforge/scripts/bash/    # Validation and structure scripts
.specforge/templates/       # File templates for generated artifacts
.claude/commands/           # Agent skill definitions
requirements/               # Runtime data (created by setup)
tests/bash/                 # bats test files
tests/fixtures/             # Test data
```
