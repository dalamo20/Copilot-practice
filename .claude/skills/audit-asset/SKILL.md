---
name: audit-asset
description: Audits a single AI workflow asset (skill, agent, hook, prompt file) using the super-auditor agent. Produces a structured report with scores, findings, and a final verdict.
when_to_use: >
  When the user provides a path to an asset and asks for an audit, review, quality check,
  or safety assessment. Also the mandatory first step before /govern-submissions.
  Do not invoke automatically on casual mentions of "review" — only on explicit invocation.
argument-hint: "[file path to audit]"
disable-model-invocation: true
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

## audit-asset

Invokes the `super-auditor` agent against a single file path.

### Inputs

- `$ARGUMENTS`: path to the asset file to audit (relative to project root)

### Steps

1. **Validate input.** If `$ARGUMENTS` is empty, respond:
   > Usage: `/audit-asset <path-to-file>`
   Stop.

2. **Confirm file exists.** Use `Read` to check the file at `$ARGUMENTS`. If the file
   cannot be read, return the Audit Error format from
   `.claude/agents/super-auditor.md` and stop. Do not guess scores.

3. **Delegate to super-auditor.** Pass the file path and content to the `super-auditor`
   agent (`.claude/agents/super-auditor.md`). The agent performs the full audit
   independently.

4. **Return the report.** The output must include:
   - Asset Summary
   - Score Breakdown table (weighted, per `governance/scoring-standard.md`)
   - Findings table (severity, status, category, finding, evidence, recommendation)
   - Priority Fix Order
   - Final Verdict (exact terms from scoring standard)

5. **Save output.** Write the report to:
   `governance/output/YYYY-MM-DD-audit-<asset-filename>.md`
   using today's date. Confirm the path after saving.

### Constraints

- This skill is read-only. Do not modify the audited asset.
- Do not inline scoring rubrics — they live in `governance/scoring-standard.md`.
- Do not collapse findings into summaries — each finding gets its own table row.
- If the Safety hard gate is triggered (sub-score < 3/5 or unresolved CRITICAL),
  state this explicitly at the top of the verdict section.
