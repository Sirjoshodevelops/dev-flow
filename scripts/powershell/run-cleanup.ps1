#!/usr/bin/env pwsh

param(
    [switch]$Json,
    [string]$Type = "all",
    [switch]$Execute,
    [switch]$ArchiveOnly,
    [switch]$Help
)

if ($Help) {
    Write-Output "Usage: ./run-cleanup.ps1 [-Json] [-Type <type>] [-Execute] [-ArchiveOnly]"
    Write-Output "  -Json          Output in JSON format"
    Write-Output "  -Type          Cleanup type (dead-code|duplicates|unused-files|outdated-docs|all)"
    Write-Output "  -Execute       Execute cleanup (default is dry-run)"
    Write-Output "  -ArchiveOnly   Move to archive instead of deleting"
    exit 0
}

# Find repository root
function Find-RepoRoot {
    param([string]$StartPath)
    
    $dir = $StartPath
    while ($dir -ne "" -and $dir -ne "/" -and $dir -ne [System.IO.Path]::GetPathRoot($dir)) {
        if ((Test-Path (Join-Path $dir ".git")) -or (Test-Path (Join-Path $dir ".specify"))) {
            return $dir
        }
        $dir = Split-Path $dir -Parent
    }
    return $null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    $repoRoot = $gitRoot
    $hasGit = $true
} catch {
    $repoRoot = Find-RepoRoot $scriptDir
    if (-not $repoRoot) {
        Write-Error "Error: Could not determine repository root."
        exit 1
    }
    $hasGit = $false
}

Set-Location $repoRoot

# Safety checks
if ($hasGit) {
    # Check for uncommitted changes
    $gitStatus = git status --porcelain 2>$null
    if ($gitStatus) {
        Write-Error "Error: You have uncommitted changes. Please commit or stash them before running cleanup."
        exit 1
    }
    
    # Get current branch
    $currentBranch = git branch --show-current
    
    # Create backup branch
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupBranch = "cleanup-backup-$timestamp"
    git branch $backupBranch | Out-Null
} else {
    $currentBranch = if ($env:SPECIFY_FEATURE) { $env:SPECIFY_FEATURE } else { "main" }
    $backupBranch = "manual-backup-required"
}

# Create cleanup directory
$cleanupDir = Join-Path $repoRoot ".specify/cleanup"
if (-not (Test-Path $cleanupDir)) {
    New-Item -ItemType Directory -Path $cleanupDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$cleanupReport = Join-Path $cleanupDir "cleanup-report-$timestamp.md"

# Create archive directory
$archiveDir = Join-Path $repoRoot ".archived"
$monthDir = Join-Path $archiveDir (Get-Date -Format "yyyy-MM")
if (-not (Test-Path $monthDir)) {
    New-Item -ItemType Directory -Path $monthDir -Force | Out-Null
}

# Load cleanup config if exists
$configFile = Join-Path $repoRoot ".specify/cleanup-config.json"
$hasConfig = Test-Path $configFile

# Check available tools
function Test-CommandAvailable {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# Detect language and tools
$pythonAvailable = Test-CommandAvailable "python3" -or Test-CommandAvailable "python"
$nodeAvailable = Test-CommandAvailable "node"
$vultureAvailable = Test-CommandAvailable "vulture"
$tspruneAvailable = Test-CommandAvailable "ts-prune"
$pylintAvailable = Test-CommandAvailable "pylint"

# Detect project languages
function Get-ProjectLanguages {
    $langs = @()
    if (Get-ChildItem -Path . -Filter "*.py" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $langs += "python"
    }
    if (Get-ChildItem -Path . -Filter "*.js" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $langs += "javascript"
    }
    if (Get-ChildItem -Path . -Filter "*.ts" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $langs += "typescript"
    }
    if (Get-ChildItem -Path . -Filter "*.go" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $langs += "go"
    }
    if (Get-ChildItem -Path . -Filter "*.rs" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $langs += "rust"
    }
    return $langs
}

$projectLanguages = Get-ProjectLanguages

$dryRun = -not $Execute

# Output in JSON format
if ($Json) {
    $output = @{
        REPO_ROOT = $repoRoot
        CURRENT_BRANCH = $currentBranch
        BACKUP_BRANCH = $backupBranch
        CLEANUP_REPORT = $cleanupReport
        ARCHIVE_DIR = $archiveDir
        HAS_GIT = $hasGit
        HAS_CONFIG = $hasConfig
        CLEANUP_TYPE = $Type
        DRY_RUN = $dryRun
        ARCHIVE_ONLY = $ArchiveOnly.IsPresent
        PROJECT_LANGUAGES = ($projectLanguages -join ",")
        TOOLS = @{
            python = $pythonAvailable
            node = $nodeAvailable
            vulture = $vultureAvailable
            "ts-prune" = $tspruneAvailable
            pylint = $pylintAvailable
        }
    }
    $output | ConvertTo-Json -Depth 10
} else {
    Write-Output "REPO_ROOT: $repoRoot"
    Write-Output "CURRENT_BRANCH: $currentBranch"
    Write-Output "BACKUP_BRANCH: $backupBranch"
    Write-Output "CLEANUP_REPORT: $cleanupReport"
    Write-Output "ARCHIVE_DIR: $archiveDir"
    Write-Output "HAS_GIT: $hasGit"
    Write-Output "CLEANUP_TYPE: $Type"
    Write-Output "DRY_RUN: $dryRun"
    Write-Output "ARCHIVE_ONLY: $($ArchiveOnly.IsPresent)"
    Write-Output ""
    Write-Output "Project languages detected: $($projectLanguages -join ', ')"
    Write-Output ""
    Write-Output "Available cleanup tools:"
    Write-Output "  Python: $pythonAvailable"
    Write-Output "  Node: $nodeAvailable"
    Write-Output "  vulture: $vultureAvailable"
    Write-Output "  ts-prune: $tspruneAvailable"
    Write-Output "  pylint: $pylintAvailable"
    Write-Output ""
    Write-Output "⚠️  SAFETY: Backup branch created: $backupBranch"
    if ($hasGit) {
        Write-Output "   Rollback command: git reset --hard $backupBranch"
    } else {
        Write-Output "   Please create manual backup before proceeding"
    }
}
