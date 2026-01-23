<#
.SYNOPSIS
    21_test_step2_output.ps1

.PURPOSE
    Tests Step 2 output: outputs\converted_phase1.csv + validation report

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
Write-Host "  TEST: Step 2 Output" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$outFile = Join-Path $ProjectRoot "outputs\converted_phase1.csv"
$reportFile = Join-Path $ProjectRoot "Validation\Reports\PHASE1_VALIDATION_REPORT.json"

if(-not (Test-Path $outFile)) { throw "Missing file: outputs\converted_phase1.csv" }
$rows = (Import-Csv $outFile).Count
Write-Host "✅ Cleaned output exists: $rows rows" -ForegroundColor Green

if(Test-Path $reportFile) {
    $report = Get-Content $reportFile | ConvertFrom-Json
    Write-Host ("✅ Status: {0} | Score: {1}/100" -f $report.Summary.OverallStatus, $report.Summary.QualityScore) -ForegroundColor Green
    if($report.Summary.QualityScore -lt 95) { Write-Host "⚠️  Score below 95." -ForegroundColor Yellow }
} else {
    Write-Host "⚠️  Validation report missing: PHASE1_VALIDATION_REPORT.json" -ForegroundColor Yellow
}

Write-Host "`n✅ Step 2 tests passed." -ForegroundColor Green
