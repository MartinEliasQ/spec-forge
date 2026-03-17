#Requires -Version 7.0
<#
.SYNOPSIS
    Validate that prerequisites for a given phase are met.
.PARAMETER Phase
    Phase to validate: distill, compose, or status.
.PARAMETER Json
    Output results in JSON format.
#>
param(
    [Parameter(Mandatory)]
    [ValidateSet("distill", "compose", "status")]
    [string]$Phase,

    [switch]$Json
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\common.ps1"

$repoRoot = Get-RepoRoot
$reqDir = Join-Path $repoRoot "requirements"
$missing = @()
$validBranch = $true

# Check branch format (warning only)
if (Test-GitRepo) {
    $branch = Get-CurrentBranch
    if ($branch -notmatch '^\d{3}-') {
        $validBranch = $false
        Write-Warning "[specforge] Branch '$branch' does not follow NNN-feature-name convention"
    }
}

# Check requirements directory
if (-not (Test-Path $reqDir -PathType Container)) {
    Write-Error "requirements/ directory does not exist. Run setup-requirements.ps1 first."
    exit 2
}

switch ($Phase) {
    "distill" {
        $inboxDir = Join-Path $reqDir "inbox"
        if (-not (Test-Path $inboxDir -PathType Container)) {
            $missing += "requirements/inbox/ (directory missing)"
        } else {
            $files = Get-ChildItem -Path $inboxDir -File -ErrorAction SilentlyContinue
            if ($files.Count -eq 0) {
                $missing += "requirements/inbox/ (no files found)"
            }
        }
    }
    "compose" {
        $unitsDir = Join-Path $reqDir "units"
        if (-not (Test-Path $unitsDir -PathType Container)) {
            $missing += "requirements/units/ (directory missing)"
        } else {
            $units = Get-ChildItem -Path $unitsDir -Filter "UNIT-*.md" -File -ErrorAction SilentlyContinue
            if ($units.Count -eq 0) {
                $missing += "requirements/units/ (empty)"
            }
        }
        $overview = Join-Path $reqDir "synthesis" "overview.md"
        if (-not (Test-Path $overview)) {
            $missing += "requirements/synthesis/overview.md"
        }
    }
    "status" {
        $featuresDir = Join-Path $reqDir "features"
        if (-not (Test-Path $featuresDir -PathType Container)) {
            $missing += "requirements/features/ (directory missing)"
        } else {
            $hasFeatures = $false
            foreach ($d in (Get-ChildItem -Path $featuresDir -Directory -Filter "FEAT-*")) {
                if (Test-Path (Join-Path $d.FullName "requirement.md")) {
                    $hasFeatures = $true
                    break
                }
            }
            if (-not $hasFeatures) {
                $missing += "requirements/features/ (no feature directories with requirement.md)"
            }
        }
    }
}

$ready = $missing.Count -eq 0

if ($Json) {
    @{
        phase            = $Phase
        valid_branch     = $validBranch
        requirements_dir = $reqDir
        missing          = $missing
        ready            = $ready
    } | ConvertTo-Json -Compress
} else {
    Write-Host "Phase: $Phase"
    Write-Host "Requirements dir: $reqDir"
    Write-Host "Valid branch: $validBranch"
    if ($ready) {
        Write-Host "Status: READY"
    } else {
        Write-Host "Status: NOT READY"
        Write-Host "Missing:"
        foreach ($m in $missing) { Write-Host "  - $m" }
        exit 1
    }
}
