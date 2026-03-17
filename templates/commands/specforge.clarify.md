## SpecForge: Clarify Uncertain Requirements

You are executing the `/specforge.clarify` command. Resolve uncertainties in requirement units by generating targeted questions and updating units with answers.

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
Parse the JSON output.

### Step 2: Validate Prerequisites
```bash
bash scripts/bash/check-prerequisites.sh --json --phase compose
```
Parse the JSON output. If `ready` is `false`, **STOP** and report: units must exist before clarifying.

### Step 3: Scan for Uncertainties
Read all files in `requirements/units/`. Collect every unit where the YAML frontmatter `uncertainty` field is NOT `none`.

Group them by severity:
- **High** uncertainty first
- **Low** uncertainty second

If no uncertain units found, report: "All requirements are clear — no clarification needed." and stop.

### Step 4: Generate Clarification Questions
From the uncertain units, generate **at most 5** targeted clarification questions. Each question must:

1. Reference the specific unit(s) it addresses (e.g., "UNIT-003, UNIT-007")
2. State what is unclear and why it matters
3. Provide a **recommended answer** based on context from other units and inbox files
4. Be actionable — the answer should directly resolve the uncertainty

Prioritize questions that:
- Address `high` uncertainty units first
- Resolve uncertainties shared across multiple units with a single question
- Unblock downstream feature composition

### Step 5: Present Questions to User
Present each question clearly with its recommended answer. Use `AskUserQuestion` to let the user accept, modify, or reject each recommendation:

For each question:
```
**Q[N]** — [Question text]
Affects: UNIT-NNN, UNIT-NNN
Recommended: [Your recommended answer]
```

Ask the user to accept the recommended answer, provide their own, or skip.

### Step 6: Update Unit Files
For each resolved question:

1. Update the affected unit file(s) in `requirements/units/`
2. Incorporate the answer into the **Requirement**, **Rationale**, or **Evidence & Constraints** section as appropriate
3. Set `uncertainty: none` in the YAML frontmatter
4. Update the **Uncertainty** text to "None" (or remove the specific uncertainty that was resolved — if other uncertainties remain, keep `uncertainty: low` or `high`)

### Step 7: Report Status
After all updates, report:
- Number of questions asked
- Number of units updated
- Remaining uncertain units (if any)
- Summary of changes made

## Agent Directives

**YOU MUST follow these rules strictly:**

1. **Max 5 questions**: Never generate more than 5 clarification questions per run. Focus on the highest-impact uncertainties.
2. **Always recommend**: Every question must include a recommended answer. The user should be able to accept all recommendations quickly.
3. **High severity first**: Always process `high` uncertainty before `low`.
4. **Batch related uncertainties**: If multiple units share the same uncertainty, combine them into one question.
5. **Update in place**: Modify the existing unit files directly. Do not create new files.
6. **Preserve structure**: When updating units, maintain the exact template format (frontmatter, sections, Evidence & Constraints).
7. **No new requirements**: Clarification resolves ambiguity — it does not add new requirements. If the answer reveals a missing requirement, note it but do not create a unit.

## Error Handling

- **No units exist**: Clear error with guidance to run `/specforge.distill` first
- **No uncertain units**: Report success — all clear
- **User skips all questions**: Report unchanged status, suggest re-running later with more context
