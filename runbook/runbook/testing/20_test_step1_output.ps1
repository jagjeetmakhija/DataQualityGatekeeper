<#
.SYNOPSIS
    20_test_step1_output.ps1

.PURPOSE
    Tests Step 1 output: CONFIG\data\sample_data.csv

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
Write-Host "  TEST: Step 1 Output" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$file = Join-Path $ProjectRoot "CONFIG\data\sample_data.csv"
if(-not (Test-Path $file)) { throw "Missing file: CONFIG\data\sample_data.csv" }

$data = Import-Csv $file
$rows = $data.Count
$cols = ($data[0].PSObject.Properties).Count

Write-Host "✅ File exists" -ForegroundColor Green
Write-Host "Rows: $rows (expected 250)" -ForegroundColor (if($rows -eq 250){"Green"}else{"Yellow"})
Write-Host "Cols: $cols (expected 15)" -ForegroundColor (if($cols -eq 15){"Green"}else{"Yellow"})

if($rows -lt 1) { throw "No rows found." }
Write-Host "`n✅ Step 1 tests passed." -ForegroundColor Green
