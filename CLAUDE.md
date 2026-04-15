# AI Governance Framework

This project provides a governance pipeline for auditing, comparing, and approving AI
workflow assets (skills, agents, hooks, prompt files).

Full documentation: @governance/README.md
Framework version: @governance/VERSION

---

## Safety Hard Gate

**Non-negotiable. No override is possible.**

- Any asset with Safety sub-score < 3/5 is **REJECTED** regardless of total score.
- Any asset with an unresolved CRITICAL safety finding is **REJECTED**.
- High scores in other categories cannot unlock this gate.

Do not approve, merge, or recommend any asset that fails this gate.

---

## Governance Principles

1. **Prompts orchestrate, agents analyze.** Never duplicate agent logic (rubrics, scoring
   criteria, output templates) inside a skill or in this file.
2. **super-auditor runs first.** No asset reaches comparison, synthesis, or governance
   without a completed audit report.
3. **Single source of truth.** Scoring weights and rubrics live only in
   @governance/scoring-standard.md — do not restate them here or in skills.
4. **Read-only by default.** Agents have read-only tool access unless explicitly justified
   in the agent file and in the commit message.
5. **Agents are self-contained.** All domain logic lives in the agent file, not in callers.

---

## Slash Commands

These are real skills. Type `/` in Claude Code to invoke them. They do **not** run
automatically — always on-demand only.

| Command | Purpose |
|---------|---------|
| `/audit-asset [file]` | Audit one AI asset using super-auditor |
| `/govern-submissions [dir]` | Full 4-stage pipeline: audit → compare → synthesize → govern |
| `/self-audit` | Run the pipeline against this governance framework itself |

Each skill runs in an isolated subagent context (`context: fork`) — it does not consume
your main session's context window.

---

## Agent Roster

All agents are defined in `.claude/agents/`. Each runs as an isolated subagent.

| Stage | Agent | File |
|-------|-------|------|
| 1 — Audit | super-auditor | @.claude/agents/super-auditor.md |
| 2 — Compare | comparator | @.claude/agents/comparator.md |
| 3 — Synthesize | project-synthesizer | @.claude/agents/project-synthesizer.md |
| 4 — Govern | portfolio-governor | @.claude/agents/portfolio-governor.md |

Pipeline order is fixed and enforced by skills: **audit → compare → synthesize → govern.**
Never invoke a later stage without the prior stage's output.

---

## Scoring Quick Reference

Full rubrics and decision mapping: @governance/scoring-standard.md

| Score | Decision |
|-------|----------|
| 90–100 | Preferred Standard |
| 80–89 | Approved |
| 70–79 | Approved with Restrictions |
| 54–69 | Major Revision Required |
| 0–53 | Rejected |

Safety sub-score < 3/5 → Rejected (hard gate, any total score).

---

## Anti-Patterns

Full catalog (AP-1 through AP-10): @governance/references/anti-patterns.md

Always check this catalog during any audit. Cite the anti-pattern ID in findings.

---

## Governance Artifact Rules

- Do not modify `governance/scoring-standard.md` without running `/self-audit` before
  and after the change.
- Do not modify `governance/references/anti-patterns.md` without running `/self-audit`.
  Anti-pattern IDs are additive only — never renumber (cross-referenced in reports).
- Output reports go in `governance/output/` — see @governance/output/README.md for
  naming convention and retention policy.
- Run `/self-audit` before and after any change to `.claude/agents/` or `.claude/skills/`.

---

## Path-Scoped Rules

Additional rules load automatically when you edit specific paths:

- Editing `governance/**` → `.claude/rules/governance-artifacts.md`
- Editing `.claude/agents/**` or `.claude/skills/**` → `.claude/rules/agent-definitions.md`
