# Claude Agent Configuration

This directory contains Claude-specific agent definitions required by the `.claude/agents/` convention.

## Agents

| Agent | Purpose |
|-------|---------|
| `super-auditor` | Audit engine — structure, safety, scoring |
| `comparator` | Comparison engine — ranking, tradeoffs |
| `project-synthesizer` | Cross-file risk analysis |
| `portfolio-governor` | Final governance decisions |

## Governance Framework

The full governance framework (scoring standard, calibration tests, anti-pattern catalog, contribution guidelines, and output reports) lives in the **`governance/`** root directory.

See [`governance/README.md`](../governance/README.md) for full documentation.

Instead of relying on subjective reviews, teams gain:

- objective quality metrics
- consistent safety standards
- maintainable agent portfolios
