<#
.SYNOPSIS
    42_fix_missing_files.ps1

.PURPOSE
    Lists missing mandatory root scripts (does not download them).

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
Write-Host "  CHECK: Missing Mandatory Files" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$mandatory = @("CONFIG.ps1","Generate-DummyData.ps1","E2E-LocalValidationPipeline.ps1","Analyze-PursuitData.ps1","Start-LocalUI.ps1")

$missing = @()
foreach($f in $mandatory){
    if(-not (Test-Path (Join-Path $ProjectRoot $f))) { $missing += $f }
}

if($missing.Count -eq 0){
    Write-Host "✅ All mandatory root files are present." -ForegroundColor Green
} else {
    Write-Host "❌ Missing files in project root:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "`nPlace them in: $($ProjectRoot.Path)" -ForegroundColor Yellow
    exit 1
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
