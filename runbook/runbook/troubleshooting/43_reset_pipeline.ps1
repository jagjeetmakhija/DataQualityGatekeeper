<#
.SYNOPSIS
    43_reset_pipeline.ps1

.PURPOSE
    Deletes generated outputs/reports to restart from a clean state.

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Project root is two levels up from runbook\<area>\<script>.ps1
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $ProjectRoot


Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "     🧹 RESET PIPELINE (DELETE GENERATED FILES)" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Red

Write-Host "This will delete:" -ForegroundColor Yellow
Write-Host "  - CONFIG\data\sample_data.csv" -ForegroundColor Gray
Write-Host "  - outputs\*.csv" -ForegroundColor Gray
Write-Host "  - Validation\Reports\*.json / *.log" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Type YES to confirm"
if($confirm -ne "YES") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Remove-Item (Join-Path $ProjectRoot "CONFIG\data\sample_data.csv") -ErrorAction SilentlyContinue
Remove-Item (Join-Path $ProjectRoot "outputs\*.csv") -ErrorAction SilentlyContinue
Remove-Item (Join-Path $ProjectRoot "Validation\Reports\*.json") -ErrorAction SilentlyContinue
Remove-Item (Join-Path $ProjectRoot "Validation\Reports\*.log") -ErrorAction SilentlyContinue

Write-Host "`n✅ Reset complete." -ForegroundColor Green
Write-Host "Next: .\runbook\pipeline\14_run_full_pipeline.ps1" -ForegroundColor Cyan
Write-Host "`n═══════════════════════════════════════════════════════════════`n" -ForegroundColor Red
