<#
.SYNOPSIS
    03_create_folders.ps1

.PURPOSE
    Creates the full runbook + pipeline folder structure (safe to re-run).

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
Write-Host "  SETUP: Create Folder Structure" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$folders = @(
    "runbook",
    "runbook\setup",
    "runbook\pipeline",
    "runbook\testing",
    "runbook\audit",
    "runbook\troubleshooting",
    "runbook\reference",
    "runbook\reports",
    "CONFIG\data",
    "outputs",
    "Validation\Reports"
)

foreach($folder in $folders) {
    $full = Join-Path $ProjectRoot $folder
    New-Item -ItemType Directory -Path $full -Force | Out-Null
    Write-Host "✅ Created/Verified: $folder" -ForegroundColor Green
}

Write-Host "`n✅ Folder structure ready." -ForegroundColor Green
Write-Host "Next: .\runbook\setup\01_setup_environment.ps1" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
