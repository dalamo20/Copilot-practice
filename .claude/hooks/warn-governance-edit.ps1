# PreToolUse hook: warn or block edits to governance-critical files.
#
# Claude Code passes the tool input as JSON on stdin.
# Exit 0 = allow (with optional warning on stderr).
# Exit 2 = block (message on stderr is shown to the user as the block reason).
#
# Block patterns  : files that must never be silently overwritten
# Warn patterns   : governance-controlled files that warrant a /self-audit reminder

param()

$BLOCK_PATTERNS = @(
    "governance/scoring-standard.md",
    "governance/references/anti-patterns.md"
)

# Warn when editing governance framework files (not all .claude files)
$WARN_PATTERNS = @(
    ".claude/agents/super-auditor",
    ".claude/agents/comparator",
    ".claude/agents/project-synthesizer",
    ".claude/agents/portfolio-governor",
    ".claude/skills/audit-asset",
    ".claude/skills/govern-submissions",
    ".claude/skills/self-audit",
    "governance/"
)

# Read stdin JSON
$stdin = $null
try {
    $stdin = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
    # If stdin is not valid JSON, allow silently
    exit 0
}

# Extract the file path from the tool input (field name varies by tool)
$targetPath = $null
if ($stdin.PSObject.Properties["path"]) {
    $targetPath = $stdin.path
} elseif ($stdin.PSObject.Properties["file_path"]) {
    $targetPath = $stdin.file_path
} else {
    exit 0
}

# Normalize to forward slashes for consistent matching
$normalizedPath = $targetPath -replace '\\', '/'

# Check block patterns
foreach ($pattern in $BLOCK_PATTERNS) {
    if ($normalizedPath -like "*$pattern*") {
        [Console]::Error.WriteLine("")
        [Console]::Error.WriteLine("[governance-hook] BLOCKED: Direct edits to '$targetPath' are not permitted.")
        [Console]::Error.WriteLine("")
        [Console]::Error.WriteLine("This file is a single source of truth for the governance framework.")
        [Console]::Error.WriteLine("Required process (governance/CONTRIBUTING.md):")
        [Console]::Error.WriteLine("  1. Run /self-audit to record a baseline score")
        [Console]::Error.WriteLine("  2. Make the change in a branch (not on main)")
        [Console]::Error.WriteLine("  3. Run /self-audit again after the change")
        [Console]::Error.WriteLine("  4. Compare reports and explain score changes in your commit message")
        [Console]::Error.WriteLine("")
        exit 2
    }
}

# Check warn patterns
foreach ($pattern in $WARN_PATTERNS) {
    if ($normalizedPath -like "*$pattern*") {
        [Console]::Error.WriteLine("")
        [Console]::Error.WriteLine("[governance-hook] WARNING: Editing a governance-controlled file: $targetPath")
        [Console]::Error.WriteLine("Recommended: run /self-audit before and after this change.")
        [Console]::Error.WriteLine("See governance/CONTRIBUTING.md for the change process.")
        [Console]::Error.WriteLine("")
        exit 0
    }
}

exit 0
