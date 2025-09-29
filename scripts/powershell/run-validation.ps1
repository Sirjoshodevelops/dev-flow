#!/usr/bin/env pwsh

param(
    [switch]$Json,
    [string]$Focus = "",
    [switch]$Help
)

if ($Help) {
    Write-Output "Usage: ./run-validation.ps1 [-Json] [-Focus <phase>]"
    Write-Output "  -Json        Output in JSON format"
    Write-Output "  -Focus       Focus on specific validation phase (requirements|budget|consistency|constitution|practices)"
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

# Get current branch/feature
if ($hasGit) {
    $currentBranch = git branch --show-current 2>$null
    if (-not $currentBranch) {
        $currentBranch = "main"
    }
} else {
    $currentBranch = if ($env:SPECIFY_FEATURE) { $env:SPECIFY_FEATURE } else { "unknown" }
}

# Determine specs directory
$specsDir = Join-Path $repoRoot "specs"
$featureDir = ""

# Try to find feature directory
if ($currentBranch -notin @("main", "master", "unknown")) {
    $featureDir = Join-Path $specsDir $currentBranch
}

# If feature dir doesn't exist, try to find most recent
if (-not (Test-Path $featureDir)) {
    if (Test-Path $specsDir) {
        $featureDir = Get-ChildItem $specsDir -Directory | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { $_.FullName }
    }
}

# Validation output directory
$validationDir = Join-Path $repoRoot ".specify/validation"
if (-not (Test-Path $validationDir)) {
    New-Item -ItemType Directory -Path $validationDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$validationReport = Join-Path $validationDir "validation-report-$timestamp.md"

# Load validation config if exists
$configFile = Join-Path $repoRoot ".specify/validation-config.json"
$hasConfig = Test-Path $configFile

# Check if common utilities are available
function Test-CommandAvailable {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# Detect language and available tools
$pythonAvailable = Test-CommandAvailable "python3" -or Test-CommandAvailable "python"
$nodeAvailable = Test-CommandAvailable "node"
$markdownlintAvailable = Test-CommandAvailable "markdownlint"

# Output in JSON format
if ($Json) {
    $output = @{
        REPO_ROOT = $repoRoot
        CURRENT_BRANCH = $currentBranch
        SPECS_DIR = $specsDir
        FEATURE_DIR = $featureDir
        VALIDATION_REPORT = $validationReport
        HAS_GIT = $hasGit
        HAS_CONFIG = $hasConfig
        FOCUS = $Focus
        TOOLS = @{
            python = $pythonAvailable
            node = $nodeAvailable
            markdownlint = $markdownlintAvailable
        }
    }
    $output | ConvertTo-Json -Depth 10
} else {
    Write-Output "REPO_ROOT: $repoRoot"
    Write-Output "CURRENT_BRANCH: $currentBranch"
    Write-Output "SPECS_DIR: $specsDir"
    Write-Output "FEATURE_DIR: $featureDir"
    Write-Output "VALIDATION_REPORT: $validationReport"
    Write-Output "HAS_GIT: $hasGit"
    Write-Output "HAS_CONFIG: $hasConfig"
    Write-Output "FOCUS: $Focus"
    Write-Output ""
    Write-Output "Available validation tools:"
    Write-Output "  Python: $pythonAvailable"
    Write-Output "  Node: $nodeAvailable"
    Write-Output "  markdownlint: $markdownlintAvailable"
}
