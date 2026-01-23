<#
.SYNOPSIS
    11_run_step2_validate.ps1

.PURPOSE
    Step 2: validate & clean data (calls E2E-LocalValidationPipeline.ps1).

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


# Robust project root detection (matches step 1)
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
Write-Host "  STEP 2: Validate & Clean" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

& (Join-Path $ProjectRoot "E2E-LocalValidationPipeline.ps1")

$outFile = Join-Path $ProjectRoot "outputs\outputs\converted_phase1.csv"
$reportFile = Join-Path $ProjectRoot "Validation\Validation\Reports\PHASE1_VALIDATION_REPORT.json"

if(Test-Path $outFile) {
    $rows = (Import-Csv $outFile).Count
    Write-Host "✅ Cleaned output exists: $rows rows (outputs\converted_phase1.csv)" -ForegroundColor Green
} else {
    throw "Step 2 failed: cleaned output not found at $outFile"
}

if(Test-Path $reportFile) {
    $report = Get-Content $reportFile | ConvertFrom-Json
    Write-Host ("✅ Validation status: {0} | Score: {1}/100" -f $report.Status, $report.DataQuality.Score) -ForegroundColor Green
} else {
    Write-Host "⚠️  Validation report not found at Validation\\Validation\\Reports\\PHASE1_VALIDATION_REPORT.json" -ForegroundColor Yellow
}
