# Pipeline Stage Input/Output Schemas

This document defines the formal input and output contracts for each stage of the
governance pipeline. All agents and skills must conform to these schemas.

Scoring weights and decision thresholds are defined in `governance/scoring-standard.md`.
Anti-patterns are defined in `governance/references/anti-patterns.md`.

---

## Error Propagation Contract

All stages must follow these rules when encountering errors:

### When Stage 1 (super-auditor) encounters an error:
- Return the **Audit Error** format (see below)
- Do NOT produce a score or verdict
- The error must be passed upstream as-is to Stage 2
- Downstream stages (2, 3, 4) must treat this asset as "errored" and exclude it from comparisons and governance decisions
- Log the error explicitly in final reports

### When Stage 2 (comparator) receives an error:
- Exclude the errored asset from all rankings and comparisons
- Note it in the output: "Asset <path> excluded due to audit error: <reason>"
- If ALL assets in a group errored, report: "Comparison skipped — no valid audit reports for this group"
- Pass the error list upstream to Stage 3

### When Stage 3 (project-synthesizer) encounters missing/incomplete data:
- Explicitly note which stages have incomplete data (missing audit reports, failed comparisons, etc.)
- Analyze only the available data
- Downgrade risk assessments for findings based on incomplete data (mark as "provisional")
- Recommend re-running the full pipeline once data is complete
- Pass the data completeness status to Stage 4

### When Stage 4 (portfolio-governor) receives incomplete data:
- Apply conservative decision rules: downgrade all verdicts one tier (Approved → Approved with Restrictions, etc.)
- Flag all decisions as "provisional — based on incomplete audit data"
- Recommend re-running the full pipeline before accepting these decisions

---

## Stage 1 — super-auditor

### Input

```
asset_path: string        # Relative path to the file being audited (required)
asset_content: string     # Full text content of the file (required)
```

For batch audits, repeat the above per asset. Each asset produces one independent report.

### Output (per asset)

```
## Audit Report: <asset_path>

### Asset Summary
type: string              # Detected asset type (skill | agent | hook | prompt | unknown)
path: string              # Relative file path
verdict: string           # One of the 6 verdict labels (see scoring-standard.md)
total_score: number       # 0-100 weighted total

### Score Breakdown
| Category             | Raw (0-5) | Weight | Weighted |
|----------------------|-----------|--------|----------|
| Safety               | n         | x6     | n        |
| Behavior Correctness | n         | x4     | n        |
| Dependency Hygiene   | n         | x4     | n        |
| Structure            | n         | x2     | n        |
| Clarity              | n         | x2     | n        |
| Maintainability      | n         | x2     | n        |
| **Total**            |           |        | **n**    |

### Findings
| Severity | Status | Category | Finding | Evidence | Recommendation |
|----------|--------|----------|---------|----------|----------------|
| ...      | Open   | ...      | ...     | ...      | ...            |

### Priority Fix Order
1. ...

### Final Verdict
<verdict label> (<score>/100)
[Safety hard gate result: PASS | FAIL]
```

### Error output (when audit cannot proceed)

```
## Audit Error
| Field  | Value                                       |
|--------|---------------------------------------------|
| Asset  | <path>                                      |
| Error  | <description>                               |
| Action | No score produced. Resolve and re-audit.    |
```

---

## Stage 2 — comparator

### Input

```
audit_reports: list       # One or more super-auditor output reports (see Stage 1 output)
                          # Must contain ≥2 reports with matching asset type or similar purpose
                          # Assets that failed the safety hard gate must be excluded before passing
```

If fewer than 2 audit reports are provided, comparator must refuse and return:
```
## Comparator Error
Reason: Insufficient audit reports. Run /audit-asset on each asset before comparing.
```

### Output

```
## Comparison Report

### Comparison Summary
assets_compared: number
grouping_basis: string    # How assets were grouped (type, purpose, etc.)

### Ranked Table
| Rank | Asset | Score | Safety | Verdict | Recommendation |
|------|-------|-------|--------|---------|----------------|
| ...  | ...   | ...   | ...    | ...     | ...            |

### Per-Asset Analysis
#### <asset_name>
Strengths: ...
Weaknesses: ...

### Best Overall: <asset_name>
### Safest: <asset_name>
### Most Efficient: <asset_name>
### Most Maintainable: <asset_name>
### Most Unique: <asset_name>

### Merge / Archive Candidates
...

### Final Recommendations
...
```

---

## Stage 3 — project-synthesizer

### Input

```
audit_reports: list       # All super-auditor output reports from Stage 1 (complete set)
comparison_reports: list  # All comparator output reports from Stage 2
```

If `audit_reports` is empty or incomplete, project-synthesizer must note which assets
are missing and proceed with available data. It must not fabricate findings for
unavailable reports.

### Output

```
## Project Synthesis Report

### Project Summary
assets_in_scope: number
stages_completed: ["audit", "compare"]   # or subset if stages missing

### Cross-File Findings
| ID  | Category | Severity | Affected Assets | Finding | Status |
|-----|----------|----------|-----------------|---------|--------|
| ... | ...      | ...      | ...             | ...     | Open   |

### Overlap Analysis
...

### Recursion / Delegation Risk Analysis
...

### Safety Consistency Analysis
...

### Standardization Opportunities
...

### Highest Priority Fixes
1. ...

### Governance Recommendation
<narrative recommendation for Stage 4>
```

---

## Stage 4 — portfolio-governor

### Input

```
audit_reports: list       # All super-auditor output reports (Stage 1)
comparison_reports: list  # All comparator output reports (Stage 2)
synthesis_report: object  # Single project-synthesizer output (Stage 3)
```

If any stage report is missing, portfolio-governor must note the gap explicitly and
apply conservative decisions (downgrade verdicts one tier) rather than assuming health.

### Output

```
## Portfolio Governance Report

### Portfolio Summary
total_assets: number
health_score: number      # Aggregate weighted score (0-100)
overall_status: string    # Approved | Approved with Restrictions | Major Revision Required | Rejected

### Asset Decisions Table
| Asset | Score | Safety Gate | Decision | Conditions |
|-------|-------|-------------|----------|------------|
| ...   | ...   | PASS/FAIL   | ...      | ...        |

### Preferred Standards by Category
...

### Unique Specialists
...

### Merge Recommendations
...

### Archive Candidates
...

### Reject List
...

### Top Governance Actions
1. ...
```

---

## Data flow summary

```
User
  └─ invokes skill (/audit-asset, /govern-submissions, /self-audit)
       └─ Stage 1: super-auditor(asset_path, asset_content) → audit_report[]
            └─ Stage 2: comparator(audit_report[]) → comparison_report[]
                 └─ Stage 3: project-synthesizer(audit_report[], comparison_report[]) → synthesis_report
                      └─ Stage 4: portfolio-governor(audit_report[], comparison_report[], synthesis_report) → governance_report
```

Each stage consumes the **full outputs** of all prior stages as context.
No stage may skip a prior stage or fabricate missing data.
