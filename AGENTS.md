# SpecForge Development Guidelines

## Overview

SpecForge is a pre-specification requirements engine that transforms unstructured inputs into structured, traceable feature-level specifications. It follows the spec-kit distribution model.

## Installation

```bash
uv tool install specforge-cli --from git+https://github.com/martin/specforge.git
specforge init myproject --ai claude
```

## Project Structure

```text
src/specforge_cli/          # CLI (specforge init, specforge check)
scripts/
  bash/                     # Bash scripts (copied to user projects)
  powershell/               # PowerShell scripts
templates/
  commands/                 # Command templates (copied to .claude/commands/)
  *.md                      # Document templates (unit, feature, synthesis)
.claude/commands/           # Active agent commands (this repo is also a working project)
tests/
specs/
```

## Technologies

- Python 3.11+ (CLI: typer, rich)
- Bash 5.x (scripts)
- Markdown (agent skills/templates)

## Commands

```bash
specforge init [dir] --ai claude   # Initialize project
specforge check                     # Verify environment
specforge version                   # Show version
```

## Code Style

- Bash: `set -euo pipefail`, use `$SCRIPT_DIR` for relative paths, JSON output with `--json` flag
- Python: Standard typing, no over-engineering
- Markdown commands: Follow spec-kit command template format

## Path Conventions

- Scripts: `scripts/bash/` (not `.specforge/scripts/`)
- Templates: `templates/` (not `.specforge/templates/`)
- Commands: `.claude/commands/` (active), `templates/commands/` (source of truth)
- Runtime output: `requirements/` (gitignored)
- Project metadata: `.specforge/init-options.json` (gitignored)
