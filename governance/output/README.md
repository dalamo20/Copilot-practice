# Governance Output

This directory stores timestamped audit and governance reports.

## Convention

```text
governance/output/
  YYYY-MM-DD-audit-<asset-name>.md
  YYYY-MM-DD-compare-<category>.md
  YYYY-MM-DD-govern-<scope>.md
  YYYY-MM-DD-self-audit.md
```

## Usage

After running any governance prompt, save the output here with the date prefix. This enables:

- **Tracking score changes** over time for the same asset.
- **Detecting regression** when agents or rubrics are modified.
- **Auditing the auditors** by comparing self-audit results across versions.
- **Establishing baselines** for portfolio health.

## Retention

- Keep at least the 3 most recent reports per asset.
- Archive older reports if the directory grows large.
- Never delete self-audit reports — they are the framework's own health record.
