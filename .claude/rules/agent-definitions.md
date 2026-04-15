---
paths:
  - ".claude/agents/**"
  - ".claude/skills/**"
---

# Rules: Agent and Skill Definitions

These rules apply whenever you are reading or editing files under `.claude/agents/`
or `.claude/skills/`.

## Agent files (.claude/agents/*.md)

- Extension must be `.md`. The `.agent.md` suffix is not recognized by Claude Code.
- Every agent file must have valid YAML frontmatter with at minimum:
  `name`, `description`, `when_to_use`, `tools`.
- `tools:` must use Claude Code tool names: `Read`, `Write`, `Edit`, `Bash`, `Glob`,
  `Grep`. **Not** Copilot tool names (`read_file`, `list_dir`, `grep_search`, etc.).
- Agents are **self-contained**. Never move domain logic (rubrics, scoring criteria,
  output templates) from an agent into a skill or CLAUDE.md.
- Adding a tool to `tools:` requires justification in the commit message.
  Removing a tool requires no justification.
- All agents in this framework are **read-only by design**. If you are adding a write
  tool, document why and how the safety gate is preserved.
- Direct writes to `.claude/agents/*` are blocked by the permission deny list in
  `.claude/settings.json`. Use your editor for agent edits; do not ask Claude to
  rewrite agent files in-session.

## Skill files (.claude/skills/<name>/SKILL.md)

- Every skill must have valid YAML frontmatter with:
  `name`, `description`, `when_to_use`, `argument-hint`, `disable-model-invocation`,
  `context`, `allowed-tools`.
- Governance skills must set `context: fork` — they orchestrate expensive multi-agent
  pipelines and must not pollute the main context window.
- Governance skills must set `disable-model-invocation: true` — they are expensive
  and should only run on explicit user invocation.
- Skills are **thin orchestrators**. If you find yourself adding scoring rubrics or
  audit logic to a skill body, it belongs in an agent.

## Pipeline integrity

The governance pipeline order is **fixed**: audit → compare → synthesize → govern.

- Never invoke `comparator` without prior `super-auditor` output.
- Never invoke `project-synthesizer` without prior `comparator` output.
- Never invoke `portfolio-governor` without all prior stages complete.
- This order is enforced by skill orchestration logic, not by the agents themselves.
