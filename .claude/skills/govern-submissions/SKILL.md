---
name: govern-submissions
description: >
  Full 4-stage governance pipeline (audit → compare → synthesize → govern) across all
  AI workflow assets in a given directory. Produces per-asset audit reports, a comparison
  ranking, a cross-file synthesis, and final governance decisions.
when_to_use: >
  When the user wants a complete governance review across a set of assets — batch intake
  of new skills or agents, periodic portfolio health checks, or pre-release reviews.
  Do not invoke automatically — only on explicit /govern-submissions invocation.
argument-hint: "[directory path containing assets]"
disable-model-invocation: true
context: fork
# Read/Glob/Grep for asset discovery and inspection; Write for saving the output report to governance/output/
# Bash is not used directly — present to support subagent delegation if needed
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

## govern-submissions

Orchestrates the full 4-stage governance pipeline across all assets in the given directory.
Each stage runs sequentially; each stage's output feeds the next.

### Inputs

- `$ARGUMENTS`: path to directory containing assets (relative to project root)

### Steps

1. **Validate input.** If `$ARGUMENTS` is empty, respond:
   > Usage: `/govern-submissions <directory-path>`
   Stop.

2. **Discover assets.** Use `Glob` to find all `.md` files in `$ARGUMENTS`.
   Exclude `README.md` and files in `governance/output/`. If no assets found, report
   and stop.

3. **Stage 1 — Audit.** For each discovered asset, delegate to `super-auditor`
   (`.claude/agents/super-auditor.md`). Collect all audit reports.
   - If any asset returns an Audit Error, log it and continue with the remaining assets.
   - Do not proceed to Stage 2 until all assets have been attempted.

4. **Stage 2 — Compare.** Group assets using the following algorithm, then delegate
   each group of 2+ assets to `comparator` (`.claude/agents/comparator.md`):

   **Grouping algorithm (apply in order):**
   1. Group by file location: `.claude/agents/` → group "agents"; `.claude/skills/` →
      group "skills"; other paths → group "other"
   2. Within each location group, sub-group by declared `name` prefix if names share
      a common prefix (e.g., `audit-*`), otherwise keep as one group
   3. Any group with only 1 asset is skipped (no comparison needed; note in output)
   4. Any asset that failed the Safety hard gate in Stage 1 is excluded from its group
      and noted as "excluded — failed safety gate"

   Pass the full audit reports for each group as context to the comparator.

5. **Stage 3 — Synthesize.** Pass all Stage 1 audit reports to `project-synthesizer`
   (`.claude/agents/project-synthesizer.md`) for cross-file risk analysis.

6. **Stage 4 — Govern.** Pass all audit reports, comparison reports, and synthesis
   report to `portfolio-governor` (`.claude/agents/portfolio-governor.md`) for final
   governance decisions.

7. **Save output.** Write the complete governance report to:
   `governance/output/YYYY-MM-DD-govern-<dirname>.md`
   using today's date and the base name of `$ARGUMENTS`. Confirm the path after saving.

### Output structure

The final report must contain:

1. Governance Run Summary (directory, asset count, date)
2. Per-Asset Audit Results (condensed — link to full reports if saved separately)
3. Comparison Rankings
4. Project-Level Synthesis Findings
5. Final Portfolio Decisions Table
6. Top Governance Actions (prioritized)

### Constraints

- Pipeline order is fixed: audit → compare → synthesize → govern. Never skip a stage.
- Never invoke comparator or later stages without completed audit reports.
- Write access is scoped to `governance/output/` only. Do not modify any audited asset.
- Do not re-declare scoring rubrics or weights — they live in `governance/scoring-standard.md`.
