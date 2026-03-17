# Script Interface Contracts: SpecForge

**Branch**: `001-specforge-requirements-engine`
**Date**: 2026-03-17

All scripts live in `.specforge/scripts/bash/` and `.specforge/scripts/powershell/`. Each script sources `common.sh` (or `common.ps1`), accepts `--json` for structured output, and follows the error conventions established by the Spec Kit scripts.

---

## setup-requirements.sh

**Purpose**: Create the `requirements/` directory structure if missing.

**Input**: `--json` (optional)

**Output (JSON)**:
```json
{
  "created": true,
  "requirements_dir": "/absolute/path/to/requirements",
  "inbox_dir": "/absolute/path/to/requirements/inbox",
  "directories_created": ["inbox", "synthesis", "units", "features"],
  "index_created": true
}
```

**Output (JSON, already exists)**:
```json
{
  "created": false,
  "requirements_dir": "/absolute/path/to/requirements",
  "inbox_dir": "/absolute/path/to/requirements/inbox",
  "directories_created": [],
  "index_created": false
}
```

**Behavior**:
- Creates `requirements/inbox/`, `requirements/synthesis/`, `requirements/units/`, `requirements/features/`, `requirements/index.md`
- Preserves existing content (only creates missing directories/files)
- Returns `created: true` if any new directory or file was created
- Exit code 0 on success, 1 on failure

---

## check-prerequisites.sh

**Purpose**: Validate that prerequisites for a given phase are met.

**Input**: `--phase distill|compose|status` `--json` (optional)

**Output (JSON)**:
```json
{
  "phase": "distill",
  "valid_branch": true,
  "requirements_dir": "/absolute/path/to/requirements",
  "missing": [],
  "ready": true
}
```

**Output (JSON, failing)**:
```json
{
  "phase": "compose",
  "valid_branch": true,
  "requirements_dir": "/absolute/path/to/requirements",
  "missing": ["requirements/units/ (empty)", "requirements/synthesis/overview.md"],
  "ready": false
}
```

**Phase validations**:

| Phase   | Prerequisites                                                        |
|---------|----------------------------------------------------------------------|
| distill | `requirements/inbox/` exists and contains at least one text file     |
| compose | `requirements/units/` has files, `requirements/synthesis/overview.md` exists |
| status  | `requirements/features/` has at least one feature directory, each with `requirement.md` |

**Additional checks (all phases)**:
- Branch follows `NNN-feature-name` convention (warning if not, does not block)
- `requirements/` directory exists (error if not — suggests running setup first)

**Exit codes**: 0 = ready, 1 = not ready (missing prerequisites), 2 = structural error

---

## create-feature.sh

**Purpose**: Create a feature directory structure under `requirements/features/`.

**Input**: `--json` (optional) `--name <feature-name>` `--number <NNN>`

**Output (JSON)**:
```json
{
  "feature_id": "FEAT-001-authentication",
  "feature_dir": "/absolute/path/to/requirements/features/FEAT-001-authentication",
  "files_created": ["requirement.md", "includes.md", "sources.md", "readiness.md"]
}
```

**Behavior**:
- Creates `requirements/features/FEAT-NNN-name/` with four template files
- Uses templates from `.specforge/templates/` for initial file content
- Feature number is zero-padded to 3 digits
- Feature name is kebab-case, derived from the provided name
- Exit code 0 on success, 1 if directory already exists or creation fails

---

## Common Interface Conventions

All scripts follow these conventions (inherited from `.specify/scripts/bash/common.sh`):

| Convention | Description |
|------------|-------------|
| `--json` flag | Returns structured JSON instead of human-readable text |
| `common.sh` sourcing | All scripts source the common library for shared functions |
| jq fallback | JSON output works with or without jq installed |
| Error to stderr | All error messages go to stderr; stdout is reserved for structured output |
| Exit codes | 0 = success, 1 = validation failure, 2 = structural error |
| Path safety | All paths are absolute; special characters are escaped via `printf '%q'` |
| Branch validation | Non-feature branches produce a warning, not an error |
