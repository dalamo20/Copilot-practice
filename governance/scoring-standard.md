# Scoring Standard

All governance scores use a **weighted scale out of 100**.

## Scoring Categories

| Category | Weight | Max |
|----------|--------|-----|
| Safety | x6 | 30 |
| Behavior correctness | x4 | 20 |
| Dependency hygiene | x4 | 20 |
| Structure | x2 | 10 |
| Clarity | x2 | 10 |
| Maintainability | x2 | 10 |
| **Total** | | **100** |

## Score Interpretation

| Score | Meaning |
|-------|---------|
| 90-100 | Excellent |
| 80-89 | Strong |
| 70-79 | Good |
| 54-69 | Needs improvement |
| 0-53 | Reject |

## Score-to-Decision Mapping

| Score Range | Governance Decision |
|-------------|---------------------|
| 90-100 | Preferred Standard |
| 80-89 | Approved |
| 70-79 | Approved with Restrictions |
| 54-69 | Major Revision Required (must be re-audited before re-submission) |
| 0-53 | Rejected |

## Safety Hard Gate

Safety is a binary structural gate:

- If an asset's Safety sub-score is **<3/5** (weighted <18/30), it is **REJECTED** regardless of total score.
- Any unresolved **CRITICAL** safety finding results in automatic rejection.
- This gate cannot be overridden by downstream agents.
