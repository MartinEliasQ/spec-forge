## SpecForge: Distill Raw Inputs into Structured Requirements

You are executing the `/specforge.distill` command. Transform unstructured inbox files into atomic requirement units and a synthesis overview.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Flow

### Step 1: Auto-Initialize
Run from repo root:
```bash
bash scripts/bash/setup-requirements.sh --json
```
Parse the JSON output. This ensures the `requirements/` directory structure exists.

### Step 2: Validate Prerequisites
```bash
bash scripts/bash/check-prerequisites.sh --json --phase distill
```
Parse the JSON output. If `ready` is `false`, **STOP** and report the `missing` items with clear guidance:
- If inbox is empty: "No files found in `requirements/inbox/`. Please add your raw input files (meeting notes, braindumps, PRDs, etc.) to `requirements/inbox/` and run `/specforge.distill` again."

### Step 3: Clear Previous Outputs
Remove all existing files from:
- `requirements/units/` (all `UNIT-*.md` files)
- `requirements/synthesis/` (all files)

Do NOT touch `requirements/inbox/` — inbox files are read-only.

### Step 4: Inventory Inbox Files
Run from repo root:
```bash
bash scripts/bash/inventory-inbox.sh --json
```
Parse the JSON output. Review the file list with line counts. For files flagged as `large` (>500 lines), you MUST read them in sections (use `offset` and `limit` parameters) rather than reading the entire file at once. Read each text file's content for analysis. Skip binary files with a warning.

### Step 5: Distill Requirements
Analyze all inbox content and extract atomic requirement units. For each unit:

1. Assign a sequential ID: `UNIT-001`, `UNIT-002`, etc.
2. Write a brief descriptive title
3. Write the **Requirement** as a WHAT statement — business capability language only
4. Write the **Rationale** as a WHY statement — business value justification
5. Extract any **Evidence & Constraints** — quantitative targets, performance thresholds, frequency constraints, latency bounds, academic references
6. Assign an **Uncertainty** level: `none`, `low`, or `high`
7. Record which inbox file(s) contributed to this unit in `sources`

### Step 6: Write Unit Files
For each extracted unit, write a file to `requirements/units/UNIT-NNN.md` using the template at `templates/unit-template.md`. The format is:

```markdown
---
id: UNIT-NNN
sources:
  - inbox/[filename]
uncertainty: [none|low|high]
---

# UNIT-NNN: [Title]

**Requirement**: [WHAT statement]

**Rationale**: [WHY statement]

**Uncertainty**: [Description if any, or "None"]

## Evidence & Constraints

- [Quantitative targets, thresholds, frequencies, academic refs from source]
```

### Step 7: Write Synthesis Overview
Write `requirements/synthesis/overview.md` containing:
- **Generated** date
- **Input files** count
- **Units generated** count
- **Themes**: Group related units by topic. Every unit must appear in at least one theme.
- **Cross-Cutting Concerns**: Concerns spanning multiple themes
- **Identified Gaps**: Information missing from inbox that would be needed
- **Uncertainties**: Unresolved questions with source references

### Step 8: Report Results
Summarize: number of units generated, themes identified, uncertainty counts (none/low/high), and any gaps or issues found.

## Agent Directives

**YOU MUST follow these rules strictly:**

1. **Strip technology choices**: Remove technology names, framework references, API specifics, database choices, or language preferences. Express everything as WHAT the system must do, not HOW.
2. **Preserve quantitative constraints**: Sharpe ratios, return percentages, frequency requirements, latency bounds, drawdown limits, and other measurable thresholds are NOT implementation details — they are domain constraints. Preserve these in the **Evidence & Constraints** section of each unit.
3. **WHAT + WHY + EVIDENCE**: Each unit describes a business capability (WHAT), its justification (WHY), and any quantitative targets or domain constraints extracted from the source (EVIDENCE). Never include implementation approach.
4. **Assign uncertainty levels**:
   - `none`: Requirement is clear and unambiguous
   - `low`: Minor ambiguity that likely won't affect implementation
   - `high`: Significant ambiguity, missing information, or contradiction
5. **Source traceability**: Every unit MUST reference at least one inbox source file
6. **Sequential numbering**: Start at UNIT-001 and increment sequentially
7. **Deduplicate**: If the same requirement appears in multiple inbox files, create ONE unit that references all contributing sources
8. **Flag contradictions**: If inbox files contradict each other, create the unit with `uncertainty: high` and describe the contradiction explicitly in the Uncertainty section. Also flag it in the synthesis overview under Identified Gaps.
9. **Never silently resolve ambiguity**: If something is unclear, mark it as uncertain. Do not guess or assume.

## Error Handling

- **Empty inbox**: Clear error with guidance to add files
- **All binary files**: Warn about each skipped file, then error if no text files remain
- **JSON parse failures from scripts**: Report the raw output and suggest re-running the command
- **Contradictory inputs**: Flag in synthesis under Identified Gaps — never silently resolve
