$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

$Branch = if ($env:GIT_BRANCH) { $env:GIT_BRANCH } else { git branch --show-current }
$Paths = @("daily-report", "journal")
$LockFile = Join-Path $RepoRoot ".sync-to-github.lock"

if (Test-Path $LockFile) {
    Write-Host "sync already running, skipping"
    exit 0
}

try {
    Set-Content -Path $LockFile -Value $PID -NoNewline

    $status = git status --porcelain @Paths 2>&1 | Out-String
    if ($status -notmatch "\S") {
        exit 0
    }

    git add @Paths

    git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        exit 0
    }

    git rev-parse --abbrev-ref "@{u}" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        git pull --rebase origin $Branch
    }

    $msg = "auto: sync $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $msg
    git push origin $Branch

    Write-Host "pushed to origin/$Branch at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
finally {
    if (Test-Path $LockFile) {
        Remove-Item $LockFile -Force
    }
}
