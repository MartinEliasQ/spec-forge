<div align="center">
    <h1>SpecForge</h1>
    <h3><em>From raw ideas to structured specs.</em></h3>
</div>

<p align="center">
    <strong>Pre-specification requirements engine &mdash; transform unstructured inputs into structured, traceable feature specs ready for <a href="https://github.com/github/spec-kit">spec-kit</a>.</strong>
</p>

<p align="center">
    <a href="https://github.com/MartinEliasQ/spec-forge/blob/main/LICENSE"><img src="https://img.shields.io/github/license/MartinEliasQ/spec-forge" alt="License"/></a>
    <a href="https://github.com/MartinEliasQ/spec-forge/stargazers"><img src="https://img.shields.io/github/stars/MartinEliasQ/spec-forge?style=social" alt="GitHub stars"/></a>
</p>

---

## Where SpecForge fits

[Spec-kit](https://github.com/github/spec-kit) turns specs into code. **SpecForge turns raw braindumps, meeting notes, and research into clean specs** ready for spec-kit.

```
Raw inputs  ──►  /specforge.distill  ──►  /specforge.clarify  ──►  /specforge.compose  ──►  /specforge.status
                                                                                                    │
                                                                                                    ▼
                                                                                    Ready for /speckit.specify
```

## Get Started

### 1. Install

```bash
uv tool install specforge-cli --from git+https://github.com/MartinEliasQ/spec-forge.git
```

### 2. Initialize a project

```bash
specforge init myproject --ai claude
cd myproject
```

### 3. Add your raw inputs

Drop your braindumps, meeting notes, PRDs, or any unstructured text into the inbox:

```bash
cp my-braindump.md requirements/inbox/
cp meeting-notes.md requirements/inbox/
```

### 4. Run the pipeline

Inside Claude Code, run the full pipeline with a single command:

```
/specforge.prepare
```

Or run each step individually for more control:

```
/specforge.distill     # Extract requirement units from inbox
/specforge.clarify     # Resolve uncertainties interactively
/specforge.compose     # Group units into features
/specforge.status      # Evaluate feature readiness
```

---

## Pipeline

```
requirements/inbox/              You put raw files here
        │
        ▼  distill
requirements/units/              Atomic requirements (UNIT-001.md, ...)
requirements/synthesis/          Themes, gaps, cross-cutting concerns
        │
        ▼  clarify (optional)
requirements/units/              Uncertainties resolved
        │
        ▼  compose
requirements/features/           FEAT-001-name/ with requirement, includes, sources
requirements/index.md            Master index
        │
        ▼  status
requirements/features/           readiness.md added (Ready / Needs Refinement / Blocked)
        │
        ▼
Ready for spec-kit:  /speckit.specify requirements/features/FEAT-001-name/requirement.md
```

## Commands

| Command | Description |
|---------|-------------|
| `/specforge.distill` | Inbox files &rarr; atomic requirement units (WHAT + WHY) |
| `/specforge.clarify` | Resolve uncertainties with targeted questions |
| `/specforge.compose` | Group units into right-sized features |
| `/specforge.status` | Evaluate feature readiness |
| `/specforge.prepare` | Run full pipeline: distill &rarr; compose &rarr; status |

## Project Structure

After running `specforge init`, your project will look like this:

```
myproject/
├── .specforge/                  SpecForge internals
│   ├── init-options.json
│   ├── scripts/
│   │   ├── bash/
│   │   └── powershell/
│   └── templates/
├── .claude/commands/            Agent slash commands
│   ├── specforge.distill.md
│   ├── specforge.clarify.md
│   ├── specforge.compose.md
│   ├── specforge.status.md
│   └── specforge.prepare.md
├── CLAUDE.md                    Agent definition
└── requirements/
    ├── inbox/                   Your raw inputs go here
    ├── units/                   Generated requirement units
    ├── synthesis/               Themes & gap analysis
    ├── features/                Composed features
    └── index.md                 Master index
```

## Principles

| # | Principle | Description |
|---|-----------|-------------|
| 1 | **WHAT before HOW** | No technology names in requirements. Business capabilities only. |
| 2 | **No silent assumptions** | Ambiguity is flagged, never resolved silently. |
| 3 | **Traceability always** | `inbox → unit → feature` chain is unbroken. |
| 4 | **Explicit uncertainty** | Every unit marked `none`, `low`, or `high`. |

## CLI Reference

```bash
specforge init [dir] --ai claude   # Scaffold project
specforge init --here --ai claude  # Initialize in current directory
specforge check                    # Verify environment
specforge version                  # Show version
```

## Prerequisites

- **Python 3.11+**
- [uv](https://docs.astral.sh/uv/) for package management
- [Git](https://git-scm.com/downloads)
- A supported AI coding agent ([Claude Code](https://www.anthropic.com/claude-code))

## License

This project is licensed under the terms of the MIT open source license. See [LICENSE](./LICENSE) for details.
