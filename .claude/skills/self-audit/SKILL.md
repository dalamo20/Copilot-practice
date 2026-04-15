---
name: self-audit
description: >
  Dogfoods the governance framework by running the full pipeline against the framework's
  own files: agent definitions, skills, scoring standard, and anti-patterns catalog.
  Used to verify the framework's health before and after any change to governance artifacts.
when_to_use: >
  Before and after modifying any governance artifact (agent files, skills, scoring-standard.md,
  anti-patterns.md). Also run as a baseline check when bumping governance/VERSION.
  Do not invoke automatically — only on explicit /self-audit invocation.
argument-hint: "[no arguments — audits framework files only]"
disable-model-invocation: true
context: fork
# Read/Glob/Grep for framework file inspection; Write for saving the self-audit report to governance/output/
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

## self-audit

Runs the full governance pipeline against the framework itself. This is the dogfooding
entry point described in `governance/CONTRIBUTING.md`.

### Inputs

None. The audit scope is fixed — it always covers the framework's own files.
This skill takes no arguments.

### Fixed audit scope

Always audit these files (do not skip, do not add ad-hoc targets):

**Agents:**
- `.claude/agents/super-auditor.md`
- `.claude/agents/comparator.md`
- `.claude/agents/project-synthesizer.md`
- `.claude/agents/portfolio-governor.md`

**Skills:**
- `.claude/skills/audit-asset/SKILL.md`
- `.claude/skills/govern-submissions/SKILL.md`
- `.claude/skills/self-audit/SKILL.md`

### Steps

1. **Confirm all scope files exist.** Use `Read` to check each file in the fixed scope.
   Log any missing files as CRITICAL findings in the summary. Continue with files
   that are present.

2. **Stage 1 — Audit.** For each file in the fixed scope, delegate to `super-auditor`
   (`.claude/agents/super-auditor.md`). Collect all 7 audit reports.

3. **Stage 2 — Compare.** Group agents together and skills together. Delegate to
   `comparator` (`.claude/agents/comparator.md`) for each group.

4. **Stage 3 — Synthesize.** Pass all audit reports to `project-synthesizer`
   (`.claude/agents/project-synthesizer.md`).

5. **Stage 4 — Govern.** Pass all reports to `portfolio-governor`
   (`.claude/agents/portfolio-governor.md`).

6. **Save output.** Write the report to:
   `governance/output/YYYY-MM-DD-self-audit.md`
   using today's date. Confirm the path after saving.

### Output structure

The self-audit report must include:

1. Self-Audit Summary (framework version from `governance/VERSION`, date, file count)
2. Per-File Audit Results
3. Agent Group Comparison
4. Skill Group Comparison
5. Project-Level Synthesis
6. Portfolio Governance Decisions
7. Framework Health Score (aggregate)
8. Recommended Actions (if any)

### Constraints

- Scope is fixed. Do not add or remove files from the audit target list without updating
  this skill and running a new self-audit afterward.
- Write access is scoped to `governance/output/` only. Do not modify any framework file.
- The self-audit report is the framework's health record. Never delete it.
- If the framework itself fails the Safety hard gate on any component, report it
  prominently at the top of the output.
