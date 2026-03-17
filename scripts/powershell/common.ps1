# Common functions and variables for SpecForge PowerShell scripts

function Get-RepoRoot {
    try {
        $root = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $root) {
            return $root.Trim()
        }
    } catch {}
    # Fallback to script location
    $scriptDir = Split-Path -Parent $PSScriptRoot
    return (Resolve-Path (Join-Path $scriptDir "../../..")).Path
}

function Get-CurrentBranch {
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $branch) {
            return $branch.Trim()
        }
    } catch {}
    return "main"
}

function Test-GitRepo {
    try {
        git rev-parse --show-toplevel 2>$null | Out-Null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Test-JqAvailable {
    return $null -ne (Get-Command jq -ErrorAction SilentlyContinue)
}

function ConvertTo-JsonEscaped {
    param([string]$Value)
    $Value = $Value -replace '\\', '\\\\'
    $Value = $Value -replace '"', '\"'
    $Value = $Value -replace "`n", '\n'
    $Value = $Value -replace "`t", '\t'
    $Value = $Value -replace "`r", '\r'
    return $Value
}

function Get-RequirementsDir {
    $repoRoot = Get-RepoRoot
    return Join-Path $repoRoot "requirements"
}

function Get-RequirementsPaths {
    $repoRoot = Get-RepoRoot
    $reqDir = Join-Path $repoRoot "requirements"
    return @{
        RepoRoot       = $repoRoot
        RequirementsDir = $reqDir
        InboxDir       = Join-Path $reqDir "inbox"
        SynthesisDir   = Join-Path $reqDir "synthesis"
        UnitsDir       = Join-Path $reqDir "units"
        FeaturesDir    = Join-Path $reqDir "features"
        IndexFile      = Join-Path $reqDir "index.md"
    }
}
