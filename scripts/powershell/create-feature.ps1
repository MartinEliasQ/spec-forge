#Requires -Version 7.0
<#
.SYNOPSIS
    Create a feature directory structure under requirements/features/.
.PARAMETER Name
    Feature name (will be kebab-cased).
.PARAMETER Number
    Feature number (zero-padded to 3 digits).
.PARAMETER Json
    Output results in JSON format.
#>
param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [int]$Number,

    [switch]$Json
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\common.ps1"

$repoRoot = Get-RepoRoot
$reqDir = Join-Path $repoRoot "requirements"
$templatesDir = Join-Path $repoRoot ".specforge" "templates"

# Convert name to kebab-case
$kebabName = ($Name.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-').Trim('-')
$paddedNumber = $Number.ToString("D3")
$featureId = "FEAT-$paddedNumber-$kebabName"
$featureDir = Join-Path $reqDir "features" $featureId

if (Test-Path $featureDir) {
    Write-Error "Feature directory already exists: $featureDir"
    exit 1
}

New-Item -ItemType Directory -Path $featureDir -Force | Out-Null

$templateMap = @{
    "feature-requirement.md" = "requirement.md"
    "feature-includes.md"    = "includes.md"
    "feature-sources.md"     = "sources.md"
    "feature-readiness.md"   = "readiness.md"
}

$filesCreated = @()
foreach ($entry in $templateMap.GetEnumerator()) {
    $src = Join-Path $templatesDir $entry.Key
    $dst = Join-Path $featureDir $entry.Value
    if (Test-Path $src) {
        Copy-Item $src $dst
    } else {
        New-Item -ItemType File -Path $dst | Out-Null
    }
    $filesCreated += $entry.Value
}

if ($Json) {
    @{
        feature_id    = $featureId
        feature_dir   = $featureDir
        files_created = $filesCreated
    } | ConvertTo-Json -Compress
} else {
    Write-Host "Feature created: $featureId"
    Write-Host "Directory: $featureDir"
    Write-Host "Files: $($filesCreated -join ', ')"
}
