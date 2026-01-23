<#
.SYNOPSIS
    02_verify_prerequisites.ps1

.PURPOSE
    Checks all required folders/files exist before running the pipeline.

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Project root is two levels up from runbook\<area>\<script>.ps1
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $ProjectRoot


Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  SETUP: Verify Prerequisites" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$allOK = $true

# Required folders (created by 03_create_folders.ps1)
$requiredFolders = @(
    "CONFIG\data",
    "outputs",
    "Validation\Reports",
    "runbook\setup",
    "runbook\pipeline",
    "runbook\testing",
    "runbook\audit",
    "runbook\troubleshooting",
    "runbook\reference"
)

Write-Host "Checking folders..." -ForegroundColor Yellow
foreach($folder in $requiredFolders) {
    $full = Join-Path $ProjectRoot $folder
    if(Test-Path $full) {
        Write-Host "  ✅ $folder\" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $folder\ (missing)" -ForegroundColor Red
        $allOK = $false
    }
}

# Required root scripts
$requiredFiles = @(
    "CONFIG.ps1",
    "Generate-DummyData.ps1",
    "E2E-LocalValidationPipeline.ps1",
    "Analyze-PursuitData.ps1",
    "Start-LocalUI.ps1"
)

Write-Host "`nChecking mandatory root files..." -ForegroundColor Yellow
foreach($file in $requiredFiles) {
    $full = Join-Path $ProjectRoot $file
    if(Test-Path $full) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (missing)" -ForegroundColor Red
        $allOK = $false
    }
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
if($allOK) {
    Write-Host "✅ Prerequisites check: PASSED" -ForegroundColor Green
    Write-Host "Next: .\runbook\pipeline\14_run_full_pipeline.ps1" -ForegroundColor Cyan
} else {
    Write-Host "❌ Prerequisites check: FAILED" -ForegroundColor Red
    Write-Host "Fix missing items (shown above) and re-run this script." -ForegroundColor Yellow
    exit 1
}
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
