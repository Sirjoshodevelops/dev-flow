#!/usr/bin/env pwsh
<#!
.SYNOPSIS
Generate or refresh the Product Requirements Prompt (PRP) for the active feature.

.DESCRIPTION
Creates `prps/<feature-branch>.md` based on `.specify/templates/prp-template.md`,
embedding absolute paths to existing artifacts so agents (including Factory Droid)
can align implementation with the PRP workflow.

.PARAMETER Json
Optional switch to emit machine-readable output.
#>
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

$envData       = Get-FeaturePathsEnv
$REPO_ROOT     = $envData.REPO_ROOT
$CURRENT_BRANCH = $envData.CURRENT_BRANCH
$HAS_GIT       = $envData.HAS_GIT
$FEATURE_SPEC  = $envData.FEATURE_SPEC
$IMPL_PLAN     = $envData.IMPL_PLAN
$TASKS         = $envData.TASKS
$RESEARCH      = $envData.RESEARCH
$DATA_MODEL    = $envData.DATA_MODEL
$CONTRACTS_DIR = $envData.CONTRACTS_DIR
$QUICKSTART    = $envData.QUICKSTART

if (-not $CURRENT_BRANCH) {
    Write-Error 'Unable to determine current feature branch. Set SPECIFY_FEATURE or run from a feature branch.'
}

if ($HAS_GIT -eq 'true' -and $CURRENT_BRANCH -notmatch '^[0-9]{3}-') {
    Write-Error "Not on a feature branch (expected 'NNN-feature-name'): $CURRENT_BRANCH"
}

$TemplatePath = Join-Path $REPO_ROOT '.specify/templates/prp-template.md'
if (-not (Test-Path $TemplatePath)) {
    Write-Error "PRP template not found at $TemplatePath"
}

$prpDir = Join-Path $REPO_ROOT 'prps'
if (-not (Test-Path $prpDir)) { New-Item -ItemType Directory -Path $prpDir | Out-Null }
$prpFile = Join-Path $prpDir "$CURRENT_BRANCH.md"

function Normalize-PathDisplay {
    param(
        [string]$Path,
        [string]$Label
    )
    if (-not $Path) { return "$Label missing" }
    if ((Test-Path $Path)) { return $Path }
    return "$Path (missing)"
}

$specPath      = Normalize-PathDisplay -Path $FEATURE_SPEC -Label 'Specification'
$planPath      = Normalize-PathDisplay -Path $IMPL_PLAN   -Label 'Implementation plan'
$tasksPath     = Normalize-PathDisplay -Path $TASKS       -Label 'Tasks backlog'
$researchPath  = Normalize-PathDisplay -Path $RESEARCH    -Label 'Research'
$dataModelPath = Normalize-PathDisplay -Path $DATA_MODEL  -Label 'Data model'
$contractsPath = Normalize-PathDisplay -Path $CONTRACTS_DIR -Label 'Contracts directory'
$quickstartPath= Normalize-PathDisplay -Path $QUICKSTART  -Label 'Quickstart guide'

$content = Get-Content -LiteralPath $TemplatePath -Raw

$replacements = @{
    '{{FEATURE_BRANCH}}' = $CURRENT_BRANCH
    '{{CURRENT_DATE}}'   = (Get-Date -Format 'yyyy-MM-dd')
    '{{SPEC_PATH}}'      = $specPath
    '{{PLAN_PATH}}'      = $planPath
    '{{TASKS_PATH}}'     = $tasksPath
    '{{RESEARCH_PATH}}'  = $researchPath
    '{{DATA_MODEL_PATH}}'= $dataModelPath
    '{{CONTRACTS_PATH}}' = $contractsPath
    '{{QUICKSTART_PATH}}'= $quickstartPath
}

foreach ($pair in $replacements.GetEnumerator()) {
    $content = $content.Replace($pair.Key, $pair.Value)
}

Set-Content -LiteralPath $prpFile -Value $content

if ($Json) {
    $obj = [PSCustomObject]@{ PRP_FILE = $prpFile; FEATURE_BRANCH = $CURRENT_BRANCH }
    $obj | ConvertTo-Json -Compress
} else {
    Write-Host "PRP_FILE: $prpFile"
    Write-Host "FEATURE_BRANCH: $CURRENT_BRANCH"
}
