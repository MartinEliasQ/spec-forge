# Research: SpecForge — Pre-Specification Requirements Engine

**Branch**: `001-specforge-requirements-engine`
**Date**: 2026-03-17

## R1: Script Architecture Pattern

**Decision**: Follow the established `.specify/scripts/bash/` pattern — each script sources `common.sh`, accepts `--json` flag for structured output, returns JSON with actionable fields for the agent.

**Rationale**: The existing Spec Kit infrastructure (common.sh, create-new-feature.sh, check-prerequisites.sh, setup-plan.sh) already establishes robust conventions for JSON output, error handling, path resolution, jq fallback, and branch validation. Reusing these patterns minimizes learning curve and ensures consistency.

**Alternatives considered**:
- Python scripts: More expressive for text processing, but adds a hard dependency. Current project uses Python only optionally (for registry sorting). Bash keeps the dependency footprint minimal.
- Node.js scripts: Unnecessary runtime dependency for what is primarily file creation and validation.

## R2: Agent Skill Architecture

**Decision**: Each SpecForge command (`/specforge.distill`, `/specforge.compose`, `/specforge.status`, `/specforge.prepare`) is a Claude command file in `.claude/commands/` that orchestrates script calls and agent reasoning.

**Rationale**: This mirrors how Spec Kit commands work (e.g., `speckit.specify.md`, `speckit.plan.md`). The agent handles content generation (distillation, grouping, evaluation) while scripts handle structural validation and directory creation. This separation aligns with Constitution Principle I (WHAT before HOW) — scripts enforce structure, the agent reasons about content.

**Alternatives considered**:
- Fully scripted pipeline: Would require embedding LLM API calls in bash, which is fragile and couples the tool to a specific LLM provider.
- Single monolithic command: Violates atomicity principle; each phase should be independently runnable.

## R3: Requirement Unit Format

**Decision**: Each unit is a standalone Markdown file (`UNIT-NNN.md`) in `requirements/units/` with YAML-style frontmatter for machine-readable metadata and a body for the requirement statement.

**Rationale**: Markdown files are human-readable, diffable in git, and consistent with every other artifact in the Spec Kit ecosystem. Frontmatter enables scripts to parse metadata (ID, sources, uncertainty markers) without complex parsing. Sequential numeric IDs (per clarification Q2) are reassigned each distill run since outputs are regenerated from scratch (per clarification Q1).

**Alternatives considered**:
- Single JSON file containing all units: Harder to review in PRs, merge conflicts more likely.
- Single markdown file with sections per unit: Harder for scripts to validate individual units.

## R4: Synthesis Overview Format

**Decision**: Single `requirements/synthesis/overview.md` file containing themes, cross-references to units, and identified uncertainties/gaps.

**Rationale**: The synthesis is a consolidated view — a single file is appropriate since it represents one coherent analysis. Multiple synthesis files would fragment the overview and make gap identification harder.

**Alternatives considered**:
- Multiple theme files: Over-engineers the synthesis phase; themes may overlap and a single document better shows relationships.

## R5: Feature Directory Structure

**Decision**: Each feature gets a directory `requirements/features/FEAT-NNN-name/` containing exactly four files: `requirement.md`, `includes.md`, `sources.md`, `readiness.md`.

**Rationale**: Mandated by the constitution's structural contract. The `requirement.md` file contains a plain natural-language feature description (per clarification Q5) consumable by `/speckit.specify`. The four-file structure enables independent validation of each concern (content, composition, traceability, readiness).

**Alternatives considered**:
- Single feature file with sections: Harder to validate individual concerns programmatically.
- Additional files (e.g., metadata.json): Adds complexity without clear benefit; markdown frontmatter can carry metadata.

## R6: Readiness Evaluation Implementation

**Decision**: The `check-prerequisites.sh` script validates structural prerequisites (files exist, directories populated). The agent evaluates content-level readiness criteria (zero uncertainties, source completeness, unit count bounds) during the `/specforge.status` command.

**Rationale**: Structural checks are deterministic and belong in scripts. Content evaluation (e.g., "are there uncertainty markers in this text?") requires reading and reasoning about markdown content, which is the agent's strength. This maintains the script-validates-structure, agent-reasons-about-content separation.

**Alternatives considered**:
- Fully scripted readiness check: Would require regex-based content analysis in bash, which is fragile and hard to maintain.
- Fully agent-driven validation: Would miss structural checks that scripts can enforce deterministically.

## R7: Regeneration Strategy

**Decision**: Both `/specforge.distill` and `/specforge.compose` regenerate all outputs from scratch on each invocation, clearing previous outputs before writing new ones.

**Rationale**: Per clarification Q1. This is the simplest and most predictable approach for a requirements pipeline. Since the agent re-reads all inbox files each time, regeneration ensures consistency. Sequential unit IDs (UNIT-001, UNIT-002) are reassigned each run, which is acceptable because all downstream references (features, sources) are also regenerated.

**Alternatives considered**:
- Incremental append: Risk of stale/orphaned units if inbox files are removed.
- Diff-and-merge: Complex to implement correctly and overkill for a pre-specification tool.

## R8: Testing Strategy

**Decision**: Use bats (Bash Automated Testing System) for script testing. Tests validate directory creation, prerequisite checking, JSON output format, and error handling. Agent skill testing is manual via end-to-end workflow verification.

**Rationale**: bats is the standard testing framework for bash scripts, already well-suited for this project. Agent skills cannot be unit-tested in isolation (they require LLM interaction), so end-to-end manual testing with fixture data is the pragmatic approach.

**Alternatives considered**:
- ShellSpec: More features than bats but adds another tool. bats is simpler and sufficient.
- No script tests: Risk of regressions in structural validation logic.

## R9: PowerShell Parity

**Decision**: Provide PowerShell equivalents for all bash scripts in `.specforge/scripts/powershell/`. PowerShell scripts follow the same interface (accept `--json`/`-Json` flag, return equivalent JSON structures).

**Rationale**: The existing Spec Kit pattern includes PowerShell support. Windows users need equivalent functionality. The interface contract (JSON input/output) ensures agent skills work identically regardless of shell.

**Alternatives considered**:
- Bash-only with WSL requirement: Excludes native Windows users.
- Cross-platform scripting language (Python): Adds hard dependency, diverges from established pattern.
