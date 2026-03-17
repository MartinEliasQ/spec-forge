#Requires -Version 7.0
<#
.SYNOPSIS
    Create the requirements/ directory structure if missing.
.PARAMETER Json
    Output results in JSON format.
#>
param(
    [switch]$Json
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\common.ps1"

$repoRoot = Get-RepoRoot
$reqDir = Join-Path $repoRoot "requirements"

$dirsCreated = @()
$indexCreated = $false
$anyCreated = $false

foreach ($subdir in @("inbox", "synthesis", "units", "features")) {
    $target = Join-Path $reqDir $subdir
    if (-not (Test-Path $target -PathType Container)) {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        $dirsCreated += $subdir
        $anyCreated = $true
    }
}

$indexFile = Join-Path $reqDir "index.md"
if (-not (Test-Path $indexFile)) {
    @"
# Requirements Index

**Last updated**: —

## Features

| Feature ID | Name | Status | Units |
|------------|------|--------|-------|

## Statistics

- **Total inbox files**: 0
- **Total units**: 0
- **Total features**: 0
- **Ready**: 0 | **Needs Refinement**: 0 | **Blocked**: 0
"@ | Set-Content -Path $indexFile -Encoding utf8
    $indexCreated = $true
    $anyCreated = $true
}

if ($Json) {
    @{
        created             = $anyCreated
        requirements_dir    = $reqDir
        inbox_dir           = Join-Path $reqDir "inbox"
        directories_created = $dirsCreated
        index_created       = $indexCreated
    } | ConvertTo-Json -Compress
} else {
    if ($anyCreated) {
        Write-Host "Requirements structure created at: $reqDir"
        if ($dirsCreated.Count -gt 0) { Write-Host "  Directories: $($dirsCreated -join ', ')" }
        if ($indexCreated) { Write-Host "  Index: index.md" }
    } else {
        Write-Host "Requirements structure already exists at: $reqDir"
    }
}
