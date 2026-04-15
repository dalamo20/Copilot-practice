# PostToolUse hook: append a log entry when a governance-controlled file is edited.
#
# Claude Code passes the tool input as JSON on stdin.
# Always exits 0 — post-use hooks must never block flow.
#
# Appends a timestamped entry to governance/output/.change-log.txt

param()

$TRACKED_PATTERNS = @(
    ".claude/agents/",
    ".claude/skills/",
    "governance/"
)

$LOG_FILE = "governance/output/.change-log.txt"

# Read stdin JSON
$stdin = $null
try {
    $stdin = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
    exit 0
}

# Extract the file path
$targetPath = $null
if ($stdin.PSObject.Properties["path"]) {
    $targetPath = $stdin.path
} elseif ($stdin.PSObject.Properties["file_path"]) {
    $targetPath = $stdin.file_path
} else {
    exit 0
}

$normalizedPath = $targetPath -replace '\\', '/'

# Check if this path is tracked
$isTracked = $false
foreach ($pattern in $TRACKED_PATTERNS) {
    if ($normalizedPath -like "*$pattern*") {
        $isTracked = $true
        break
    }
}

if ($isTracked) {
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $entry = "$timestamp  EDITED  $targetPath"
    try {
        # Ensure the output directory exists
        $logDir = Split-Path $LOG_FILE -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        Add-Content -Path $LOG_FILE -Value $entry -Encoding UTF8
    } catch {
        # Non-fatal: log failure should never block the engineer
    }
}

exit 0
