<#
.SYNOPSIS
    12_run_step3_analyze.ps1

.PURPOSE
    Step 3: generate signals/insights (calls Analyze-PursuitData.ps1).

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


# Robust project root detection (matches steps 1 and 2)
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
Write-Host "  STEP 3: Analyze & Generate Signals" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

& (Join-Path $ProjectRoot "Analyze-PursuitData.ps1")

$signalsFile = Join-Path $ProjectRoot "Validation\Validation\Reports\PHASE1_SIGNALS_REPORT.json"
$insightsCsv  = Join-Path $ProjectRoot "outputs\phase1_insights_local.csv"

if(Test-Path $signalsFile) {
    $signals = Get-Content $signalsFile | ConvertFrom-Json
    Write-Host ("✅ Signals report exists: {0} deals" -f $signals.Summary.TotalDeals) -ForegroundColor Green
} else {
    throw "Step 3 failed: signals report not found at $signalsFile"
}

if(Test-Path $insightsCsv) {
    Write-Host "✅ Insights CSV exists: outputs\phase1_insights_local.csv" -ForegroundColor Green
} else {
    Write-Host "⚠️  Insights CSV not found (some implementations may skip this export)." -ForegroundColor Yellow
}
