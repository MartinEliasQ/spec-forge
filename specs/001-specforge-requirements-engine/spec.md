# Feature Specification: SpecForge — Pre-Specification Requirements Engine

**Feature Branch**: `001-specforge-requirements-engine`
**Created**: 2026-03-17
**Status**: Draft
**Input**: User description: "SpecForge is a pre-specification system that transforms unstructured inputs into structured, traceable, and feature-level specifications ready for spec-driven workflows such as Spec Kit."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Distill Raw Inputs into Structured Requirements (Priority: P1)

As a product owner or developer, I want to drop unstructured documents (meeting notes, brain dumps, Slack threads, PRD fragments) into an inbox folder and have SpecForge distill them into atomic requirement units and a synthesis overview, so that I can move from "messy ideas" to "organized requirements" without manually structuring everything.

**Why this priority**: This is the foundational capability. Without distillation, no downstream feature composition or spec generation can happen. It delivers immediate value by turning chaos into structure.

**Independent Test**: Can be fully tested by placing raw input files in the inbox, running the distill command, and verifying that synthesis and unit files are generated with proper structure and traceability.

**Acceptance Scenarios**:

1. **Given** one or more unstructured files exist in `requirements/inbox/`, **When** the user runs `/specforge.distill`, **Then** the system generates structured files in `requirements/synthesis/` and `requirements/units/` with no implementation details, no silent assumptions, and explicit uncertainty markers where information is incomplete.
2. **Given** the inbox is empty, **When** the user runs `/specforge.distill`, **Then** the system returns a clear error indicating no input files were found.
3. **Given** input files contain contradictory statements, **When** the user runs `/specforge.distill`, **Then** the system flags contradictions as explicit uncertainties in the synthesis output rather than silently choosing one interpretation.
4. **Given** input files contain implementation details (e.g., "use React", "deploy on AWS"), **When** the user runs `/specforge.distill`, **Then** the system strips implementation details and preserves only the underlying business requirements.
5. **Given** previous synthesis and unit outputs already exist from a prior distill run, **When** the user runs `/specforge.distill` again, **Then** the system regenerates all outputs from scratch using the current inbox contents, replacing all previous outputs.

---

### User Story 2 - Compose Features from Requirement Units (Priority: P2)

As a product owner, I want SpecForge to automatically group related requirement units into coherent, right-sized features with full traceability back to source units, so that I have well-scoped features ready for specification.

**Why this priority**: Composition depends on distillation (P1) but is essential for producing the feature-level output that integrates with Spec Kit. Without it, the user still has to manually organize requirements into features.

**Independent Test**: Can be fully tested by having valid units and synthesis in place, running the compose command, and verifying that feature directories are created with requirement.md, includes.md, sources.md, and readiness.md files.

**Acceptance Scenarios**:

1. **Given** valid requirement units and synthesis exist in `requirements/units/` and `requirements/synthesis/`, **When** the user runs `/specforge.compose`, **Then** the system creates feature directories under `requirements/features/` with each containing `requirement.md`, `includes.md`, `sources.md`, and `readiness.md`.
2. **Given** requirement units exist, **When** the user runs `/specforge.compose`, **Then** each generated feature is grouped by business capability, avoiding both micro-features (single trivial requirement) and mega-features (too broad to scope).
3. **Given** a feature is composed, **When** the user inspects `sources.md`, **Then** it traces back to the specific units and original inbox files that contributed to that feature.

---

### User Story 3 - Check Feature Readiness Status (Priority: P3)

As a product owner, I want to check which composed features are ready for spec-driven workflows, which are blocked, and which need refinement, so that I can prioritize which features to move into Spec Kit next.

**Why this priority**: Status checking is valuable for workflow management but depends on features already being composed (P2). It prevents wasted effort by identifying blockers before specification begins.

**Independent Test**: Can be fully tested by having composed features in place, running the status command, and verifying that each feature receives a correct readiness assessment (Ready, Blocked, or Needs Refinement).

**Acceptance Scenarios**:

1. **Given** composed features exist in `requirements/features/`, **When** the user runs `/specforge.status`, **Then** the system evaluates each feature and reports its status as Ready, Blocked, or Needs Refinement with specific reasons.
2. **Given** a feature is missing required information, **When** the user runs `/specforge.status`, **Then** the system identifies exactly what is missing or unclear and marks the feature as Needs Refinement.
3. **Given** a feature has all required information and no ambiguities, **When** the user runs `/specforge.status`, **Then** the system marks it as Ready and indicates it can be passed to `/speckit.specify`.

---

### User Story 4 - Run Full Pipeline End-to-End (Priority: P4)

As a developer who wants a streamlined workflow, I want to run a single command that executes distill, compose, and status in sequence, so that I can go from raw inputs to ready features in one step.

**Why this priority**: This is a convenience feature that chains the three core capabilities. It's valuable for efficiency but not essential since each step can be run independently.

**Independent Test**: Can be fully tested by placing input files in the inbox, running the prepare command, and verifying that the full pipeline executes: synthesis and units are created, features are composed, and readiness statuses are reported.

**Acceptance Scenarios**:

1. **Given** unstructured files exist in `requirements/inbox/`, **When** the user runs `/specforge.prepare`, **Then** the system sequentially runs distill, compose, and status, producing fully evaluated features.
2. **Given** the distill phase fails (e.g., empty inbox), **When** the user runs `/specforge.prepare`, **Then** the pipeline halts with a clear error and does not proceed to compose or status.

---

### User Story 5 - Initialize Requirements Structure (Priority: P5)

As a new user setting up SpecForge for the first time, I want the system to automatically create the required directory structure when it doesn't exist, so that I can start working immediately without manual setup.

**Why this priority**: Setup is a one-time operation that unblocks all other capabilities. It's low priority because it only runs once per project, but it's a prerequisite for everything else.

**Independent Test**: Can be fully tested by running the setup in a clean project directory and verifying that all required directories and the index file are created.

**Acceptance Scenarios**:

1. **Given** no `requirements/` directory exists, **When** any SpecForge command is invoked, **Then** the system automatically creates the full directory structure (`requirements/inbox/`, `requirements/synthesis/`, `requirements/units/`, `requirements/features/`, `requirements/index.md`).
2. **Given** the `requirements/` directory already exists with some content, **When** setup runs, **Then** existing content is preserved and only missing directories are created.

---

### Edge Cases

- What happens when inbox files are in unsupported formats (e.g., binary files, images)? The system should skip unsupported files and warn the user.
- What happens when the same requirement appears in multiple inbox files? The system should deduplicate during synthesis and trace back to all source files.
- What happens when requirement units cannot be meaningfully grouped into features? The system should create single-unit features and flag them as under-scoped (below the 3-unit minimum).
- What happens when the user runs compose before distill? The prerequisite check should block execution and provide a clear error with guidance.
- What happens when the branch name doesn't follow the NNN-feature-name convention? The prerequisite check should warn the user about the non-standard branch format.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a setup mechanism that creates the full requirements directory structure (`inbox/`, `synthesis/`, `units/`, `features/`, `index.md`) if it does not already exist.
- **FR-002**: System MUST validate prerequisites before each phase (distill, compose, status) and halt with clear error messages if prerequisites are not met.
- **FR-003**: System MUST read all files from `requirements/inbox/` and transform them into atomic requirement units in `requirements/units/` and a synthesis overview in `requirements/synthesis/`.
- **FR-004**: System MUST strip implementation details from distilled outputs, preserving only business requirements expressed as WHAT and WHY.
- **FR-005**: System MUST flag contradictions, ambiguities, and incomplete information as explicit uncertainties rather than making silent assumptions.
- **FR-006**: System MUST group requirement units into features organized by business capability, targeting 3-8 units per feature. Features with fewer than 3 units should be flagged as potentially under-scoped; features with more than 8 units should be flagged as potentially over-scoped.
- **FR-007**: System MUST create a complete feature directory structure for each composed feature containing `requirement.md`, `includes.md`, `sources.md`, and `readiness.md`.
- **FR-008**: System MUST maintain full traceability from features back to units and from units back to original inbox source files via `sources.md`.
- **FR-009**: System MUST evaluate each composed feature using strict readiness criteria: **Ready** requires zero uncertainty markers, all units have source references, 3-8 units per feature, and no contradictions. Any single violation marks the feature as **Needs Refinement** with the specific failing criteria listed. Missing required feature files (`requirement.md`, `includes.md`, `sources.md`, `readiness.md`) marks the feature as **Blocked**.
- **FR-010**: System MUST provide a single command (`/specforge.prepare`) that chains distill, compose, and status in sequence, halting on failure.
- **FR-011**: System MUST validate that the current branch follows the `NNN-feature-name` naming convention and warn if it does not.
- **FR-012**: System MUST expose four user-facing commands: `/specforge.distill`, `/specforge.compose`, `/specforge.status`, and `/specforge.prepare`.
- **FR-013**: System MUST return structured output from all scripts to enable the agent to parse and act on results.
- **FR-014**: System MUST preserve existing content when re-running setup on an already-initialized project.
- **FR-015**: System MUST produce feature outputs where `requirement.md` contains a plain natural-language feature description directly consumable by `/speckit.specify` as its input argument.
- **FR-016**: System MUST regenerate all outputs from scratch on each invocation of `/specforge.distill` or `/specforge.compose`, replacing previous outputs entirely rather than appending or merging.

### Key Entities

- **Inbox Item**: A raw, unstructured input document (meeting notes, brain dumps, requirements fragments). Key attributes: file name, file type, content, date added.
- **Requirement Unit**: An atomic, structured requirement extracted from one or more inbox items. Key attributes: sequential numeric identifier (`UNIT-001`, `UNIT-002`, etc., reassigned each distill run), requirement statement (WHAT/WHY only), source references, uncertainty markers.
- **Synthesis Overview**: A consolidated summary of all distilled requirement units showing themes, relationships, and gaps. Key attributes: themes, cross-references to units, identified uncertainties.
- **Feature**: A cohesive grouping of related requirement units representing a business capability. Key attributes: feature identifier (FEAT-XXX-name), requirement description, included units, source traceability, readiness status.
- **Readiness Assessment**: An evaluation of a feature's completeness and clarity. Key attributes: status (Ready/Blocked/Needs Refinement), reasons, blockers, recommendations.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can go from raw unstructured inputs to evaluated, spec-ready features in under 15 minutes for a typical set of 5-10 inbox documents.
- **SC-002**: 100% of generated features maintain traceability back to their source inbox documents (no orphaned requirements).
- **SC-003**: Zero implementation details appear in distilled outputs (all WHAT/WHY, no HOW).
- **SC-004**: Every generated feature output is directly consumable by `/speckit.specify` without manual reformatting.
- **SC-005**: Users report at least 50% reduction in time spent manually organizing requirements compared to doing it without SpecForge.
- **SC-006**: 90% of features marked as "Ready" by the status check are accepted into Spec Kit workflows without needing additional refinement.
- **SC-007**: All prerequisite validation errors provide actionable guidance that enables the user to resolve the issue without external help.

## Clarifications

### Session 2026-03-17

- Q: When re-running distill or compose, should existing outputs be appended, regenerated, or diff-merged? → A: Regenerate all — re-process all inputs from scratch each time, replacing previous outputs.
- Q: How should requirement units be uniquely identified? → A: Sequential numeric — `UNIT-001`, `UNIT-002`, etc., assigned during each distill run.
- Q: What quantitative bounds define feature right-sizing (micro vs mega)? → A: 3-8 units per feature — balanced range for mid-sized business capabilities.
- Q: What criteria distinguish Ready vs Needs Refinement vs Blocked? → A: Strict — Ready requires zero uncertainty markers, all units have source refs, 3-8 units, no contradictions. Any single violation → Needs Refinement. Missing required files → Blocked.
- Q: What format should requirement.md follow for Spec Kit compatibility? → A: Plain feature description — requirement.md contains a natural-language feature description that `/speckit.specify` consumes as-is.

## Assumptions

- Users are working within a project that follows standard directory conventions and uses a command-line or agent-based interface.
- Input files in the inbox are text-based documents (markdown, plain text, or similar). Binary files are skipped with a warning.
- The system operates within a git repository and expects branches to follow the `NNN-feature-name` convention.
- Spec Kit is already installed or available in the project for downstream consumption of SpecForge outputs.
- The agent (Claude or similar) handles the reasoning and content generation; scripts handle structure and validation only.
