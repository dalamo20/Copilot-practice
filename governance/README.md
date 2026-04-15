# AI Agent Governance & Evaluation Framework

A governance system for auditing, ranking, and managing AI workflow assets:

- Claude Code Skills
- Agents / Subagents
- Commands
- Hooks
- Instruction files
- Automation scripts

The framework evaluates these assets for:

- Safety
- Architecture quality
- Context efficiency
- Maintainability
- Behavioral robustness
- Strategic value

It provides a structured process for selecting the best implementation, maintaining standards, and preventing unsafe or redundant AI assets from entering production.

---

## Why This Exists

As teams build more AI workflows, several problems appear quickly:

| Problem | Impact |
|---------|--------|
| Too many overlapping agents | Hard to maintain |
| Unsafe instructions or scripts | Security risk |
| Poor prompt design | Context waste |
| Inconsistent architecture | Hard to scale |
| No objective comparison | Hard to choose best implementation |

This framework introduces a structured review pipeline similar to a code review and architecture review system.

---

## High Level Architecture

The system consists of three layers:

**Prompts** (`.github/prompts/*.prompt.md`)
User-facing entry points. Thin orchestrators that define workflow order and delegate all analysis to agents via subagent invocation.

**Agents** (`.claude/agents/*.agent.md`)
Specialized analysis engines. Each agent owns its domain logic, scoring criteria, severity definitions, and output format. Agents are the single source of truth — prompts never duplicate their content.

**Governance Artifacts** (`governance/`)
Framework-owned, vendor-neutral directory containing the scoring standard, calibration tests, anti-pattern catalog, contribution guidelines, and output reports.

**Pipeline:**
`audit → compare → rank → govern`

**Flow:**

```text
User Prompt
     |
     ▼
Prompt Orchestrator (.prompt.md)
     |——▶ super-auditor (subagent)
     |——▶ comparator (subagent)
     |——▶ project-synthesizer (subagent)
     |——▶ portfolio-governor (subagent)
          |
          ▼
     Structured Report
```

---

## Project Structure

```text
governance/
  VERSION                  # Current framework version (semver)
  scoring-standard.md      # Canonical scoring rubric and decision mapping
  CONTRIBUTING.md          # Change process and rules
  README.md                # This file
  tests/
    golden-good-asset.md   # Calibration: should score 86-94/100
    golden-bad-asset.md    # Calibration: should score 24-40/100
    README.md              # Test usage and expected results
  references/
    anti-patterns.md       # 10 named anti-patterns (AP-1 through AP-10)
  output/
    README.md              # Timestamped report storage convention

.github/                   # GitHub platform config
  copilot-instructions.md  # Project-level AI config and agent roster
  prompts/
    audit-asset.prompt.md           # Orchestrates: super-auditor
    compare-assets.prompt.md        # Orchestrates: super-auditor → comparator
    rank-category.prompt.md         # Orchestrates: super-auditor → comparator
    govern-submissions.prompt.md    # Orchestrates: all 4 agents in sequence
    self-audit.prompt.md            # Dogfooding: runs the framework against itself

.claude/                   # Claude platform config
  agents/
    super-auditor.agent.md          # Audit engine (structure, safety, scoring)
    comparator.agent.md             # Comparison engine (ranking, tradeoffs)
    project-synthesizer.agent.md    # Cross-file risk analysis
    portfolio-governor.agent.md     # Final governance decisions
```

---

## Quick Start

| Command | What It Does |
|---------|-------------|
| `/audit-asset <path>` | Audit a single asset |
| `/compare-assets <path1> <path2>` | Compare and rank similar assets |
| `/rank-category <dir>` | Discover, audit, and rank all assets in a directory |
| `/govern-submissions <dir>` | Full 4-stage pipeline |
| `/self-audit` | Validate the framework against itself |

---

## Key Design Principles

1. **Prompts orchestrate, agents analyze** — prompts define workflow order; agents contain all domain logic.
2. **Never bypass super-auditor** — every asset must be audited before comparison or governance.
3. **Safety is a hard gate** — Safety < 3/5 = automatic rejection, no override.
4. **Single source of truth** — canonical scoring rubric lives in `governance/scoring-standard.md`.
5. **Read-only by default** — all agents have read-only tool access.
6. **No platform assumption** — agents are vendor-neutral by design and intent.
7. **Vendor namespaces stay thin** — `.claude/` and `.github/` contain only what those platforms require.

---

## Versioning

The framework version is tracked in `governance/VERSION` using [semantic versioning](https://semver.org/):

- **MAJOR** — breaking changes to scoring weights, verdict terms, or agent interfaces
- **MINOR** — new features, new anti-patterns, new rubric levels, new prompts
- **PATCH** — fixes, typo corrections, documentation clarifications

Bump `VERSION` with every PR that changes framework behavior. Audit reports should reference the framework version they were produced under.

---

## Install to User Profile

To use the governance framework across all your workspaces (GCC, ISL, MFI, etc.), install agents and prompts to your user profile:

```powershell
# Windows (PowerShell)
.\scripts\Install-GovernanceFramework.ps1           # Install
.\scripts\Install-GovernanceFramework.ps1 -Check    # Dry run — see what would change
.\scripts\Install-GovernanceFramework.ps1 -Uninstall
```

```bash
# macOS / Linux
./scripts/Install-governance-framework.sh           # Install
./scripts/Install-governance-framework.sh --check   # Dry run
./scripts/Install-governance-framework.sh --uninstall
```

This copies agents to `~/.claude/agents/`, prompts to `~/.github/prompts/`, and governance artifacts to `~/governance/` — use `--force / -f` to overwrite without prompting.
