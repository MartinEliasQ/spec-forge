# Tasks: SpecForge — Pre-Specification Requirements Engine

**Input**: Design documents from `/specs/001-specforge-requirements-engine/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not explicitly requested. Test tasks excluded. Bats test infrastructure is included in setup for future use.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the .specforge project structure and shared utilities

- [X] T001 Create .specforge directory structure: `.specforge/scripts/bash/`, `.specforge/scripts/powershell/`, `.specforge/templates/`, `.specforge/agents/`
- [X] T002 Create shared bash utilities in `.specforge/scripts/bash/common.sh` — reuse patterns from `.specify/scripts/bash/common.sh` (get_repo_root, get_current_branch, has_git, json_escape, has_jq, check_file, check_dir) and add SpecForge-specific helpers: `get_requirements_dir()` returns `$REPO_ROOT/requirements`, `get_requirements_paths()` returns all requirement subdirectory paths as shell variables
- [X] T003 [P] Create shared PowerShell utilities in `.specforge/scripts/powershell/common.ps1` — port common.sh functions to PowerShell equivalents with same interface semantics
- [X] T004 [P] Create test infrastructure: `tests/bash/` directory and `tests/fixtures/sample-inbox/` directory with 3 sample input files (a meeting notes .md, a braindump .txt, and a PRD fragment .md)

**Checkpoint**: Project structure ready, shared utilities available

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core scripts and templates that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Implement `setup-requirements.sh` in `.specforge/scripts/bash/setup-requirements.sh` — creates `requirements/inbox/`, `requirements/synthesis/`, `requirements/units/`, `requirements/features/`, and `requirements/index.md` if missing. Must preserve existing content. Accept `--json` flag. Return JSON with `created`, `requirements_dir`, `inbox_dir`, `directories_created`, `index_created` fields per contracts/script-interfaces.md
- [X] T006 [P] Implement `setup-requirements.ps1` in `.specforge/scripts/powershell/setup-requirements.ps1` — PowerShell equivalent of T005 with `-Json` parameter and identical JSON output
- [X] T007 Implement `check-prerequisites.sh` in `.specforge/scripts/bash/check-prerequisites.sh` — accept `--phase distill|compose|status` and `--json` flags. Validate: distill requires inbox with files; compose requires units + synthesis/overview.md; status requires features with requirement.md each. Also validate branch format `NNN-feature-name` (warn only). Return JSON with `phase`, `valid_branch`, `requirements_dir`, `missing[]`, `ready` fields per contracts/script-interfaces.md
- [X] T008 [P] Implement `check-prerequisites.ps1` in `.specforge/scripts/powershell/check-prerequisites.ps1` — PowerShell equivalent of T007 with `-Phase` and `-Json` parameters
- [X] T009 [P] Create unit template in `.specforge/templates/unit-template.md` — YAML frontmatter with `id`, `sources[]`, `uncertainty` fields; body with `# UNIT-NNN: [Title]`, `**Requirement**:`, `**Rationale**:`, `**Uncertainty**:` sections per data-model.md
- [X] T010 [P] Create synthesis template in `.specforge/templates/synthesis-template.md` — sections for `Generated`, `Input files`, `Units generated`, `## Themes`, `## Cross-Cutting Concerns`, `## Identified Gaps`, `## Uncertainties` per data-model.md
- [X] T011 [P] Create feature requirement template in `.specforge/templates/feature-requirement.md` — simple template with `# [Feature Name]` header and placeholder for plain natural-language description
- [X] T012 [P] Create feature includes template in `.specforge/templates/feature-includes.md` — template with `# Included Units: [Feature Name]` header and markdown table with `Unit ID | Title | Uncertainty` columns and `**Total units**:` footer
- [X] T013 [P] Create feature sources template in `.specforge/templates/feature-sources.md` — template with `# Source Traceability: [Feature Name]` header, `## Unit → Inbox Mapping` table, and `## Inbox Coverage` table per data-model.md
- [X] T014 [P] Create feature readiness template in `.specforge/templates/feature-readiness.md` — template with `# Readiness Assessment: [Feature Name]` header, `**Status**:`, `**Evaluated**:`, `## Criteria Check` table (5 criteria rows), and `## Recommendation` section per data-model.md
- [X] T015 Create SpecForge agent definition in `.specforge/agents/specforge-agent.md` — define agent behavior: orchestrate skills, call scripts, enforce constitution principles (WHAT before HOW, no silent assumptions, traceability). Reference the four commands, script interfaces, and template locations. Include directive to always call setup-requirements.sh before any phase to satisfy US5 (auto-initialization)

**Checkpoint**: Foundation ready — all scripts, templates, and agent definition in place. User story implementation can begin.

---

## Phase 3: User Story 1 — Distill Raw Inputs into Structured Requirements (Priority: P1) 🎯 MVP

**Goal**: Users drop unstructured documents into an inbox and SpecForge distills them into atomic requirement units and a synthesis overview.

**Independent Test**: Place 3+ sample files in `requirements/inbox/`, run `/specforge.distill`, verify that `requirements/units/UNIT-NNN.md` files and `requirements/synthesis/overview.md` are generated with proper structure, no implementation details, and explicit uncertainty markers.

### Implementation for User Story 1

- [X] T016 [US1] Create the `/specforge.distill` skill in `.claude/commands/specforge.distill.md` — define the full execution flow: (1) call `setup-requirements.sh --json` for auto-init, (2) call `check-prerequisites.sh --json --phase distill` to validate inbox, (3) clear existing `requirements/units/` and `requirements/synthesis/` contents, (4) read all text files from `requirements/inbox/`, (5) agent extracts atomic requirements as WHAT+WHY only, strips implementation details, flags contradictions and uncertainties, deduplicates across files, (6) write `UNIT-NNN.md` files using unit-template.md format with sequential IDs (UNIT-001, UNIT-002...), (7) write `requirements/synthesis/overview.md` using synthesis-template.md format with themes, cross-cutting concerns, gaps, and uncertainties, (8) report unit count, theme count, uncertainty count
- [X] T017 [US1] Add error handling to distill skill in `.claude/commands/specforge.distill.md` — handle: empty inbox (clear error with guidance), all binary files skipped (warn + error), JSON parse failures from scripts (abort with re-run guidance), contradictory inputs (flag in synthesis, don't silently resolve)
- [X] T018 [US1] Add agent directives section to distill skill in `.claude/commands/specforge.distill.md` — explicit rules: strip technology names/framework references, express each unit as WHAT+WHY only, assign uncertainty levels (none/low/high), ensure every unit references at least one inbox source, sequential numbering starting at UNIT-001

**Checkpoint**: User Story 1 (Distill) is independently functional. Users can distill raw inputs into structured units and synthesis.

---

## Phase 4: User Story 2 — Compose Features from Requirement Units (Priority: P2)

**Goal**: SpecForge groups requirement units into coherent, right-sized features (3-8 units each) with full traceability.

**Independent Test**: With valid units and synthesis from a distill run, run `/specforge.compose`, verify feature directories are created under `requirements/features/FEAT-NNN-name/` each containing `requirement.md`, `includes.md`, `sources.md`, and `readiness.md` with correct content.

### Implementation for User Story 2

- [X] T019 [US2] Implement `create-feature.sh` in `.specforge/scripts/bash/create-feature.sh` — accept `--json`, `--name <name>`, `--number <NNN>` flags. Create `requirements/features/FEAT-NNN-name/` directory. Copy feature templates (requirement.md, includes.md, sources.md, readiness.md) from `.specforge/templates/`. Return JSON with `feature_id`, `feature_dir`, `files_created[]` per contracts/script-interfaces.md. Exit code 0 success, 1 if exists or failure
- [X] T020 [P] [US2] Implement `create-feature.ps1` in `.specforge/scripts/powershell/create-feature.ps1` — PowerShell equivalent of T019 with `-Json`, `-Name`, `-Number` parameters
- [X] T021 [US2] Create the `/specforge.compose` skill in `.claude/commands/specforge.compose.md` — define the full execution flow: (1) call `check-prerequisites.sh --json --phase compose` to validate units and synthesis exist, (2) clear existing `requirements/features/` contents, (3) read all unit files and synthesis overview, (4) agent groups units by business capability targeting 3-8 units per feature, (5) for each group: call `create-feature.sh --json --name <name> --number <NNN>`, then write `requirement.md` as plain natural-language description, write `includes.md` with unit table, write `sources.md` with unit-to-inbox traceability, write `readiness.md` as placeholder, (6) update `requirements/index.md` with feature listing, (7) report feature count, unit distribution, any sizing flags
- [X] T022 [US2] Add agent directives section to compose skill in `.claude/commands/specforge.compose.md` — explicit rules: group by business capability not by source file, target 3-8 units (flag <3 as under-scoped, >8 as over-scoped), requirement.md must be a coherent narrative consumable by `/speckit.specify`, every unit must appear in exactly one feature, every inbox file must be traceable through at least one unit

**Checkpoint**: User Story 2 (Compose) is independently functional. Users can compose features from distilled units.

---

## Phase 5: User Story 3 — Check Feature Readiness Status (Priority: P3)

**Goal**: Evaluate each composed feature's readiness and report status (Ready, Needs Refinement, or Blocked) with specific reasons.

**Independent Test**: With composed features in place, run `/specforge.status`, verify each feature receives correct readiness assessment based on strict criteria (zero uncertainties, source completeness, 3-8 unit range, no contradictions).

### Implementation for User Story 3

- [X] T023 [US3] Create the `/specforge.status` skill in `.claude/commands/specforge.status.md` — define the full execution flow: (1) call `check-prerequisites.sh --json --phase status` to validate features exist, (2) for each feature directory in `requirements/features/`: verify all 4 required files exist (Blocked if missing), read includes.md and count units (check 3-8 range), read all included unit files and check for uncertainty markers, read sources.md and verify all units have source references, check for contradictions across included units, (3) write `readiness.md` per feature using strict criteria from spec (zero uncertainties + all sources + 3-8 units + no contradictions = Ready; any single violation = Needs Refinement; missing files = Blocked), (4) update `requirements/index.md` with current statuses and statistics, (5) report per-feature status summary with recommendations
- [X] T024 [US3] Add readiness evaluation rules to status skill in `.claude/commands/specforge.status.md` — encode strict criteria table: Ready requires zero uncertainty markers AND all units have source refs AND 3-8 units per feature AND no contradictions; any single violation marks Needs Refinement with specific failing criteria; missing required files marks Blocked. For Ready features, include handoff command: `/speckit.specify requirements/features/FEAT-NNN-name/requirement.md`

**Checkpoint**: User Story 3 (Status) is independently functional. Users can evaluate feature readiness.

---

## Phase 6: User Story 4 — Run Full Pipeline End-to-End (Priority: P4)

**Goal**: Single command that chains distill → compose → status with halt-on-failure behavior.

**Independent Test**: Place files in inbox, run `/specforge.prepare`, verify all three phases execute in sequence producing fully evaluated features. Verify pipeline halts with clear error if distill fails (e.g., empty inbox).

### Implementation for User Story 4

- [X] T025 [US4] Create the `/specforge.prepare` skill in `.claude/commands/specforge.prepare.md` — define the full execution flow: (1) call `setup-requirements.sh --json` for auto-init, (2) execute `/specforge.distill` — if error, halt pipeline and report, (3) execute `/specforge.compose` — if error, halt pipeline and report (distill outputs preserved), (4) execute `/specforge.status` — report results, (5) report combined summary: total inbox files processed, units generated, features composed, readiness distribution (Ready/Needs Refinement/Blocked)

**Checkpoint**: User Story 4 (Prepare) is independently functional. Full pipeline works end-to-end.

---

## Phase 7: User Story 5 — Initialize Requirements Structure (Priority: P5)

**Goal**: System automatically creates required directory structure when it doesn't exist, so users can start immediately without manual setup.

**Independent Test**: Run any SpecForge command in a clean project (no `requirements/` directory), verify the full directory structure is created automatically before the command proceeds.

### Implementation for User Story 5

- [X] T026 [US5] Verify auto-initialization behavior across all skills — confirm that `specforge.distill.md`, `specforge.compose.md`, and `specforge.prepare.md` all call `setup-requirements.sh --json` as their first step. Add auto-init call to `specforge.status.md` if not already present. Ensure `setup-requirements.sh` preserves existing content (idempotent). Document the auto-init pattern in `.specforge/agents/specforge-agent.md`

**Checkpoint**: User Story 5 (Initialize) is confirmed working. All commands auto-initialize on first use.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T027 [P] Create `requirements/index.md` generation logic — add a shared section to the agent definition in `.specforge/agents/specforge-agent.md` documenting how index.md is updated: compose creates initial feature listing, status updates readiness statuses, format uses markdown table with Feature ID, Name, Status, Units columns plus statistics summary
- [X] T028 [P] Add sample test fixtures in `tests/fixtures/expected-outputs/` — create expected output examples for each phase: a sample `UNIT-001.md`, a sample `overview.md`, a sample feature directory with all 4 files, and a sample `readiness.md` in each status (Ready, Needs Refinement, Blocked)
- [ ] T029 Validate end-to-end workflow using test fixtures — run the full pipeline (`/specforge.prepare`) against `tests/fixtures/sample-inbox/` files. Verify: units are generated with correct format, synthesis has themes and gaps, features are composed with 3-8 units, readiness is evaluated with strict criteria, index.md is complete. Document any issues found and fix
- [ ] T030 Run quickstart.md validation — follow quickstart.md steps from scratch in a clean state. Verify each step works as documented. Update quickstart.md if any steps are incorrect or unclear

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **US1 Distill (Phase 3)**: Depends on Foundational — no other story dependencies
- **US2 Compose (Phase 4)**: Depends on Foundational — no dependency on US1 code (compose reads units that distill produces, but compose skill is independently implementable)
- **US3 Status (Phase 5)**: Depends on Foundational — no dependency on US1/US2 code (status reads features that compose produces, but status skill is independently implementable)
- **US4 Prepare (Phase 6)**: Depends on US1, US2, US3 being implemented (chains all three)
- **US5 Initialize (Phase 7)**: Depends on Foundational (setup-requirements.sh) — verification pass across all skills
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational (Phase 2) — No dependencies on other stories
- **US2 (P2)**: Can start after Foundational (Phase 2) — Independently implementable (reads file outputs, not code from US1)
- **US3 (P3)**: Can start after Foundational (Phase 2) — Independently implementable (reads file outputs, not code from US2)
- **US4 (P4)**: Requires US1 + US2 + US3 complete — chains all three skills
- **US5 (P5)**: Verification pass — requires all skills to exist

### Within Each User Story

- Scripts before skills (skills call scripts)
- Templates before skills (skills reference templates)
- Core skill implementation before error handling refinements

### Parallel Opportunities

- T003, T004 can run in parallel with T002 (different files)
- T006, T008 can run in parallel with T005, T007 (bash vs powershell)
- T009 through T014 can all run in parallel (independent templates)
- US1, US2, US3 skill implementations can run in parallel after Foundational (they read file outputs, not each other's code)
- T027, T028 can run in parallel (independent files)

---

## Parallel Example: Foundational Phase

```bash
# Launch all templates in parallel:
Task: "Create unit template in .specforge/templates/unit-template.md"           # T009
Task: "Create synthesis template in .specforge/templates/synthesis-template.md"  # T010
Task: "Create feature requirement template in .specforge/templates/feature-requirement.md"  # T011
Task: "Create feature includes template in .specforge/templates/feature-includes.md"        # T012
Task: "Create feature sources template in .specforge/templates/feature-sources.md"          # T013
Task: "Create feature readiness template in .specforge/templates/feature-readiness.md"      # T014

# Launch PowerShell scripts in parallel with bash scripts:
Task: "Implement setup-requirements.ps1"       # T006 (parallel with T005)
Task: "Implement check-prerequisites.ps1"      # T008 (parallel with T007)
```

## Parallel Example: User Stories After Foundational

```bash
# All three core user stories can be implemented in parallel:
Task: "Create /specforge.distill skill"   # T016 (US1)
Task: "Create /specforge.compose skill"   # T021 (US2) — also needs T019 first
Task: "Create /specforge.status skill"    # T023 (US3)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T015)
3. Complete Phase 3: User Story 1 — Distill (T016-T018)
4. **STOP and VALIDATE**: Test distillation independently with sample inbox files
5. Demo: "Drop files in inbox → get structured requirements"

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add US1 (Distill) → Test independently → Demo raw-to-units pipeline (MVP!)
3. Add US2 (Compose) → Test independently → Demo units-to-features pipeline
4. Add US3 (Status) → Test independently → Demo feature readiness evaluation
5. Add US4 (Prepare) → Test end-to-end → Demo full pipeline
6. Add US5 (Initialize) → Verify auto-setup → Complete
7. Polish → Validate with quickstart → Ship

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All skills are Claude command files (markdown), not code — they orchestrate scripts + agent reasoning
- PowerShell tasks can be deferred if Windows support is not immediately needed
