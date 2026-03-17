# SpecForge

**Pre-specification requirements engine** — transform unstructured inputs into structured, traceable feature specs.

SpecForge sits *before* [spec-kit](https://github.com/github/spec-kit). Where spec-kit turns specs into code, SpecForge turns raw braindumps, meeting notes, and research into clean specs ready for spec-kit.

```
Raw inputs → /specforge.distill → /specforge.clarify → /specforge.compose → /specforge.status → Ready for /speckit.specify
```

## Install

```bash
uv tool install specforge-cli --from git+https://github.com/MartinEliasQ/specforge.git
```

## Quick Start

```bash
# Initialize project
specforge init myproject --ai claude
cd myproject

# Add raw inputs
cp my-braindump.md requirements/inbox/
cp meeting-notes.md requirements/inbox/

# Run full pipeline (or run each step individually)
# Inside Claude Code:
/specforge.prepare
```

## Commands

| Command | What it does |
|---------|-------------|
| `/specforge.distill` | Inbox files → atomic requirement units (WHAT + WHY) |
| `/specforge.clarify` | Resolve uncertainties with targeted questions |
| `/specforge.compose` | Group units into right-sized features |
| `/specforge.status` | Evaluate feature readiness |
| `/specforge.prepare` | Run full pipeline: distill → compose → status |

## Pipeline

```
requirements/inbox/          ← You put raw files here
        ↓ distill
requirements/units/          ← Atomic requirements (UNIT-001.md, ...)
requirements/synthesis/      ← Themes, gaps, cross-cutting concerns
        ↓ clarify (optional)
requirements/units/          ← Uncertainties resolved
        ↓ compose
requirements/features/       ← FEAT-001-name/ with requirement, includes, sources
requirements/index.md        ← Master index
        ↓ status
requirements/features/       ← readiness.md added (Ready / Needs Refinement / Blocked)
        ↓
Ready for spec-kit: /speckit.specify requirements/features/FEAT-001-name/requirement.md
```

## Principles

1. **WHAT before HOW** — No technology names in requirements. Business capabilities only.
2. **No silent assumptions** — Ambiguity is flagged, never resolved silently.
3. **Traceability always** — `inbox → unit → feature` chain is unbroken.
4. **Explicit uncertainty** — Every unit marked `none`, `low`, or `high`.

## CLI

```bash
specforge init [dir] --ai claude   # Scaffold project
specforge check                     # Verify environment
specforge version                   # Show version
```

## License

MIT
