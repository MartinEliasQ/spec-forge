# Implementation Plan: SpecForge — Pre-Specification Requirements Engine

**Branch**: `001-specforge-requirements-engine` | **Date**: 2026-03-17 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-specforge-requirements-engine/spec.md`

## Summary

SpecForge is a pre-specification system that transforms unstructured inputs (meeting notes, brain dumps, PRD fragments) into structured, traceable, feature-level specifications. It extends spec-driven development one phase earlier: Raw Input → Distillation → Feature Composition → Spec Kit handoff. The system is implemented as a set of bash validation scripts, Claude agent skills (slash commands), and markdown templates — following the same architecture patterns already established by the Spec Kit tooling in this repository.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (agent skills/templates)
**Primary Dependencies**: jq (optional, for JSON construction), Python 3 (optional, for registry sorting in common.sh)
**Storage**: File system — Markdown files for content, JSON for structured metadata, organized under `requirements/` directory
**Testing**: bats (Bash Automated Testing System) for script validation, manual verification for agent skill flows
**Target Platform**: macOS/Linux (Bash), Windows (PowerShell equivalents)
**Project Type**: Agent tooling / CLI toolkit
**Performance Goals**: N/A — agent-driven interactive system, not a service
**Constraints**: Must integrate with existing `.specify/` infrastructure and Spec Kit commands; must follow established script patterns (JSON output, common.sh sourcing, error handling conventions)
**Scale/Scope**: Single-user CLI tool; typical inbox of 5-10 documents per distillation run

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. WHAT Before HOW | PASS | Spec defines outcomes without prescribing implementation. Plan appropriately introduces HOW. |
| II. Atomicity Before Composition | PASS | Distill phase produces atomic units before Compose groups them. Feature sizing bounded at 3-8 units. |
| III. No Silent Assumptions | PASS | System uses explicit uncertainty markers. Readiness assessment enforces zero-uncertainty for Ready status. |
| IV. Traceability Always | PASS | `sources.md` and `includes.md` required per feature. Units reference inbox sources. |
| V. Explicit Uncertainty | PASS | Strict readiness criteria: any uncertainty marker → Needs Refinement. |
| VI. Specification Purity & Phase Separation | PASS | Distill/Compose/Status phases are strictly separated with validation gates between them. |

**Gate result: PASS** — No violations. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-specforge-requirements-engine/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
.specforge/
├── scripts/
│   ├── bash/
│   │   ├── common.sh              # Shared utilities (extends .specify pattern)
│   │   ├── setup-requirements.sh  # Creates requirements/ directory structure
│   │   ├── check-prerequisites.sh # Validates phase prerequisites
│   │   └── create-feature.sh      # Creates feature directory structure
│   └── powershell/
│       ├── common.ps1
│       ├── setup-requirements.ps1
│       ├── check-prerequisites.ps1
│       └── create-feature.ps1
├── templates/
│   ├── unit-template.md           # Template for requirement units
│   ├── synthesis-template.md      # Template for synthesis overview
│   ├── feature-requirement.md     # Template for feature requirement.md
│   ├── feature-includes.md        # Template for feature includes.md
│   ├── feature-sources.md         # Template for feature sources.md
│   └── feature-readiness.md       # Template for feature readiness.md
└── agents/
    └── specforge-agent.md         # Agent behavior definition

.claude/commands/
├── specforge.distill.md           # Distill skill definition
├── specforge.compose.md           # Compose skill definition
├── specforge.status.md            # Status skill definition
└── specforge.prepare.md           # Prepare (full pipeline) skill definition

requirements/                      # Runtime data directory (created by setup)
├── inbox/                         # User drops raw inputs here
├── synthesis/
│   └── overview.md                # Consolidated themes and gaps
├── units/
│   ├── UNIT-001.md                # Atomic requirement units
│   ├── UNIT-002.md
│   └── ...
├── features/
│   └── FEAT-001-feature-name/
│       ├── requirement.md         # Plain-language feature description
│       ├── includes.md            # List of constituent units
│       ├── sources.md             # Traceability to units and inbox files
│       └── readiness.md           # Readiness assessment
└── index.md                       # Master index of all features

tests/
├── bash/
│   ├── test_setup_requirements.bats
│   ├── test_check_prerequisites.bats
│   └── test_create_feature.bats
└── fixtures/
    ├── sample-inbox/              # Sample inbox files for testing
    └── expected-outputs/          # Expected outputs for validation
```

**Structure Decision**: Follows the established `.specify/` pattern — scripts in `.specforge/scripts/bash/`, templates in `.specforge/templates/`, agent skills in `.claude/commands/`. Runtime data lives in `requirements/` at repo root. Test infrastructure uses bats with fixtures.

## Complexity Tracking

> No violations to justify — Constitution Check passed cleanly.
