<#
.SYNOPSIS
    10_run_step1_generate.ps1

.PURPOSE
    Step 1: generate sample data (calls Generate-DummyData.ps1).

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Project root is two levels up from runbook\<area>\<script>.ps1
function Get-ProjectRoot {
    $dir = $PSScriptRoot
    while ($dir -and -not (Test-Path (Join-Path $dir 'Generate-DummyData.ps1'))) {
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return $dir
}
$ProjectRoot = Get-ProjectRoot

Write-Host ("[DEBUG] ProjectRoot is: {0}" -f $ProjectRoot) -ForegroundColor Cyan
Set-Location $ProjectRoot


Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "  STEP 1: Generate Sample Data" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

& (Join-Path $ProjectRoot "Generate-DummyData.ps1")

$outFile = Join-Path $ProjectRoot "CONFIG\CONFIG\data\sample_data.csv"
if(Test-Path $outFile) {
    $rows = (Import-Csv $outFile).Count
    Write-Host "✅ Step 1 complete: $rows rows written to CONFIG\data\sample_data.csv" -ForegroundColor Green
} else {
    throw "Step 1 failed: output not found at $outFile"
}
