# Skill Interface Contracts: SpecForge

**Branch**: `001-specforge-requirements-engine`
**Date**: 2026-03-17

Each skill is a Claude command file in `.claude/commands/` that orchestrates script calls and agent reasoning. Skills follow the established Spec Kit command pattern.

---

## /specforge.distill

**Trigger**: User runs `/specforge.distill`
**Input**: None (reads from `requirements/inbox/`)

**Execution flow**:
1. Run `setup-requirements.sh --json` → ensure directory structure exists
2. Run `check-prerequisites.sh --json --phase distill` → validate inbox has files
3. If not ready → ERROR with guidance
4. Clear existing `requirements/units/` and `requirements/synthesis/` contents
5. Read all files from `requirements/inbox/`
6. Agent reasons about content: extract atomic requirements, identify themes, flag uncertainties
7. Write `UNIT-NNN.md` files to `requirements/units/`
8. Write `overview.md` to `requirements/synthesis/`
9. Report: number of units generated, themes identified, uncertainties flagged

**Agent directives**:
- Strip all implementation details (technology names, framework references)
- Express each unit as WHAT + WHY only
- Flag contradictions between sources as explicit uncertainties
- Deduplicate requirements that appear in multiple inbox files
- Assign sequential IDs: UNIT-001, UNIT-002, etc.

**Output to user**: Summary of distillation results (unit count, theme count, uncertainty count)

---

## /specforge.compose

**Trigger**: User runs `/specforge.compose`
**Input**: None (reads from `requirements/units/` and `requirements/synthesis/`)

**Execution flow**:
1. Run `check-prerequisites.sh --json --phase compose` → validate units and synthesis exist
2. If not ready → ERROR with guidance
3. Clear existing `requirements/features/` contents
4. Read all unit files and synthesis overview
5. Agent groups units by business capability into features (3-8 units each)
6. For each feature group:
   a. Run `create-feature.sh --json --name <name> --number <NNN>`
   b. Write `requirement.md` — plain natural-language feature description
   c. Write `includes.md` — table of included unit IDs
   d. Write `sources.md` — unit-to-inbox traceability mapping
   e. Write `readiness.md` — placeholder (evaluated in status phase)
7. Update `requirements/index.md` with feature listing
8. Report: number of features created, unit distribution

**Agent directives**:
- Group by business capability, not by source file or arbitrary splits
- Target 3-8 units per feature; flag any outside this range
- requirement.md must be a coherent narrative consumable by `/speckit.specify`
- Every unit must appear in exactly one feature
- Every inbox file must be traceable through at least one unit

**Output to user**: Summary of composition results (feature count, unit distribution, any flagged sizing issues)

---

## /specforge.status

**Trigger**: User runs `/specforge.status`
**Input**: None (reads from `requirements/features/`)

**Execution flow**:
1. Run `check-prerequisites.sh --json --phase status` → validate features exist
2. If not ready → ERROR with guidance
3. For each feature directory in `requirements/features/`:
   a. Verify all four required files exist (→ Blocked if missing)
   b. Read includes.md → count units, verify in range (3-8)
   c. Read all included unit files → check for uncertainty markers
   d. Read sources.md → verify all units have source references
   e. Check for contradictions across included units
   f. Write `readiness.md` with evaluation results
4. Update `requirements/index.md` with current statuses
5. Report: per-feature status summary

**Readiness criteria (strict)**:

| Criterion | Ready | Needs Refinement | Blocked |
|-----------|-------|-------------------|---------|
| Required files | All 4 present | All 4 present | Any file missing |
| Uncertainty markers | Zero | 1 or more | N/A |
| Unit source refs | All have refs | Any missing | N/A |
| Unit count | 3-8 | <3 or >8 | N/A |
| Contradictions | None | 1 or more | N/A |

**Output to user**: Status table with per-feature assessment and recommended next actions

---

## /specforge.prepare

**Trigger**: User runs `/specforge.prepare`
**Input**: None

**Execution flow**:
1. Run `/specforge.distill` → halt on error
2. Run `/specforge.compose` → halt on error
3. Run `/specforge.status` → report results
4. Report: full pipeline summary

**Halt behavior**: If any phase fails, the pipeline stops immediately. Partial outputs from completed phases are preserved (not rolled back).

**Output to user**: Combined summary of all three phases
