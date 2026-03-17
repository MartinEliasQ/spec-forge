<!--
Sync Impact Report
===================
- Version change: N/A → 1.0.0
- Added principles:
  - I. WHAT Before HOW
  - II. Atomicity Before Composition
  - III. No Silent Assumptions
  - IV. Traceability Always
  - V. Explicit Uncertainty
- Added sections:
  - Core Principles (5 principles)
  - Validation Gates & Structural Contracts
  - Development Workflow
  - Governance
- Removed sections: None
- Templates requiring updates:
  - .specify/templates/plan-template.md — ✅ aligned (Constitution Check section present)
  - .specify/templates/spec-template.md — ✅ aligned (NEEDS CLARIFICATION pattern matches Principle V)
  - .specify/templates/tasks-template.md — ✅ aligned (phase structure supports atomicity)
- Follow-up TODOs: None
-->

# SpecForge Constitution

## Core Principles

### I. WHAT Before HOW

All specifications, requirements, and feature descriptions MUST define
the desired outcome before prescribing implementation. Implementation
details are prohibited in distillation and composition phases. Feature
specs MUST use technology-agnostic language for requirements and success
criteria. Implementation choices belong exclusively in the planning
phase (plan.md), never in spec.md or requirement.md.

### II. Atomicity Before Composition

Every requirement MUST be decomposed into the smallest independently
meaningful unit before being grouped into features. Units MUST be
self-contained and testable in isolation. Feature composition MUST
group units by business capability, avoiding both micro-features
(single-unit) and mega-features (unbounded scope). Each user story
MUST be independently implementable, testable, and deployable.

### III. No Silent Assumptions

When information is missing, incomplete, or ambiguous, the system MUST
surface it explicitly rather than filling gaps with assumed values.
Requirements MUST use `[NEEDS CLARIFICATION: <reason>]` markers for
unresolved details. Agents and scripts MUST NOT infer defaults for
business-critical decisions. Every assumption made during distillation
MUST be documented in synthesis artifacts for user review.

### IV. Traceability Always

Every output artifact MUST be traceable back to its source input.
Feature specs MUST include `sources.md` linking to originating inbox
items and units. Tasks MUST reference their parent user story via
`[US<N>]` labels. Plan decisions MUST reference the spec requirements
they satisfy. The `includes.md` file in each feature MUST enumerate
all constituent units. No artifact may exist without a documented
origin.

### V. Explicit Uncertainty

When confidence in a requirement, scope boundary, or technical
constraint is low, the system MUST mark it with explicit uncertainty
indicators rather than presenting it as settled. Readiness assessments
(`readiness.md`) MUST classify features as Ready, Blocked, or Needs
Refinement. Specs MUST flag unclear requirements with structured
markers. Plans MUST use `NEEDS CLARIFICATION` for undecided technical
choices. Uncertainty is a first-class status, not a failure state.

### VI. Specification Purity & Phase Separation

All outputs produced during SpecForge phases MUST adhere to strict
separation between requirement definition and implementation design.

#### Requirements MUST:

- Be expressed in system-level and business capability terms
- Define clear inputs, outputs, and expected behavior
- Respect the Distill → Compose → Status phase boundaries
- Maintain atomicity before composition

#### Requirements MUST NOT:

- Reference specific technologies (e.g., databases, frameworks, APIs)
- Include implementation details or architectural decisions
- Contain execution steps, tasks, or development instructions
- Merge or skip defined phases (distill, compose, status)

Any violation of these rules MUST be treated as a failure of the
distillation or composition process and require correction before
proceeding.

## Validation Gates & Structural Contracts

All phase transitions MUST pass validation gates enforced by scripts:

- **Distill Gate**: `requirements/inbox/` MUST exist and contain at
  least one input file before distillation begins.
- **Compose Gate**: `requirements/units/` and
  `requirements/synthesis/overview.md` MUST exist before composition.
- **Status Gate**: `requirements/features/` MUST exist and each feature
  MUST contain `requirement.md` before status evaluation.

Structural contracts for features are non-negotiable. Every feature
directory MUST contain exactly: `requirement.md`, `includes.md`,
`sources.md`, and `readiness.md`.

Branch naming MUST follow the pattern `NNN-feature-name` (e.g.,
`001-authentication`, `002-dashboard`). Scripts MUST validate branch
format before allowing phase execution.

## Development Workflow

The SpecForge workflow enforces a strict phase order:

1. **Distill**: Raw inputs are read from `inbox/`, decomposed into
   atomic units in `units/`, and synthesized into `synthesis/`.
2. **Compose**: Units are grouped by business capability into features
   under `features/FEAT-XXX-name/`.
3. **Status**: Each feature is evaluated for readiness and classified.
4. **Handoff**: Ready features are passed to downstream spec-driven
   workflows (e.g., `/speckit.specify`) via their `requirement.md`.

The `/specforge.prepare` command runs all three phases sequentially.
No phase may be skipped. Downstream consumption of a feature that has
not passed the Status gate is prohibited.

## Governance

This constitution is the highest-authority document for the SpecForge
project. All specifications, plans, tasks, and agent behaviors MUST
comply with the principles defined herein.

**Amendment procedure**:
1. Propose the change with rationale and affected principles.
2. Document the change in a Sync Impact Report.
3. Update all dependent templates and artifacts for consistency.
4. Increment the version according to semantic versioning:
   - **MAJOR**: Principle removal, redefinition, or backward-incompatible
     governance change.
   - **MINOR**: New principle or section added, or material expansion
     of existing guidance.
   - **PATCH**: Clarifications, wording fixes, non-semantic refinements.

**Compliance review**: Every spec, plan, and task list MUST be verified
against this constitution before finalization. The plan template's
"Constitution Check" section serves as the enforcement gate.

**Version**: 1.0.0 | **Ratified**: 2026-03-17 | **Last Amended**: 2026-03-17
