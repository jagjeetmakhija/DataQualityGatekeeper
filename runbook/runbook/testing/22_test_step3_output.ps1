<#
.SYNOPSIS
    22_test_step3_output.ps1

.PURPOSE
    Tests Step 3 output: signals report + insights csv

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
Write-Host "  TEST: Step 3 Output" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$signalsFile = Join-Path $ProjectRoot "Validation\Reports\PHASE1_SIGNALS_REPORT.json"
$insightsCsv = Join-Path $ProjectRoot "outputs\phase1_insights_local.csv"

if(-not (Test-Path $signalsFile)) { throw "Missing file: Validation\Reports\PHASE1_SIGNALS_REPORT.json" }
$signals = Get-Content $signalsFile | ConvertFrom-Json

Write-Host ("✅ Signals report: {0} deals" -f $signals.Summary.TotalDeals) -ForegroundColor Green

if(Test-Path $insightsCsv) {
    $rows = (Import-Csv $insightsCsv).Count
    Write-Host "✅ Insights CSV: $rows rows" -ForegroundColor Green
} else {
    Write-Host "⚠️  Insights CSV not found (optional)." -ForegroundColor Yellow
}

Write-Host "`n✅ Step 3 tests passed." -ForegroundColor Green
