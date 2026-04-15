# Contributing to the Governance Framework

## What This Covers

Changes to:

- Agent definitions (`.claude/agents/*.agent.md`)
- Prompt orchestrators (`.github/prompts/*.prompt.md`)
- Scoring rubrics (inside `governance/scoring-standard.md`)
- Scoring standard (`governance/scoring-standard.md`)
- Golden test cases (`governance/tests/`)
- Anti-patterns (`governance/references/anti-patterns.md`)
- Project-level config (`.github/copilot-instructions.md`)

## Change Process

1. **Run `/self-audit` before making changes** — establish a baseline.
2. **Make the change** in a branch.
3. **Run `/self-audit` again** — compare results against the baseline.
4. **Run golden test calibration** — verify scores remain in expected ranges.
5. **Document the rationale** in the commit message.

## Rules

### Scoring Rubrics

- Changes to rubric criteria require re-running both golden tests.
- If golden test scores drift outside expected ranges, adjust the rubrics or update the expected ranges with justification.
- Never remove a rubric level (0–5) — only refine the criteria.

### Agents

- Agents must remain self-contained — all logic in the agent file, not in prompts.
- Adding tools to an agent's `tools:` list requires justification in the commit message.
- Removing tools is always safe; adding tools requires review.

### Prompts

- Prompts must remain thin orchestrators — no audit logic, scoring criteria, or output templates.
- If you find yourself adding domain logic to a prompt, it belongs in an agent.

### Anti-Patterns

- New anti-patterns should include: pattern example, risk explanation, and fix.
- Each anti-pattern gets a unique ID (AP-N) for cross-referencing.

### Golden Tests

- Expected score ranges can be updated but must include justification.
- Never modify golden test assets to make them score better — modify the rubrics instead.
