<#
.SYNOPSIS
    14_run_full_pipeline.ps1

.PURPOSE
    Runs Steps 1-3 in sequence with basic checks and summary.

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Project root is two levels up from runbook\<area>\<script>.ps1
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $ProjectRoot


Write-Host "\n============================================================" -ForegroundColor Cyan
Write-Host "     RUNNING FULL PIPELINE (STEPS 1 to 3)" -ForegroundColor Cyan
Write-Host "============================================================\n" -ForegroundColor Cyan

$start = Get-Date
$errors = @()

function Invoke-Step([string]$stepName, [scriptblock]$action) {
    Write-Host ("--- {0} ---" -f $stepName) -ForegroundColor Yellow
    try {
        & $action
        Write-Host ("[OK] {0}: PASSED\n" -f $stepName) -ForegroundColor Green
        return $true
    } catch {
        $msg = $_.Exception.Message
        Write-Host ("[FAIL] {0} FAILED - {1}\n" -f $stepName, $msg) -ForegroundColor Red
        $script:errors += ("{0} FAILED - {1}" -f $stepName, $msg)
        return $false
    }
}

$ok1 = Invoke-Step "Step 1/3 - Generate" { & (Join-Path $ProjectRoot "runbook\pipeline\10_run_step1_generate.ps1") }
$ok2 = $false
$ok3 = $false

if($ok1) { $ok2 = Invoke-Step "Step 2/3 - Validate & Clean" { & (Join-Path $ProjectRoot "runbook\pipeline\11_run_step2_validate.ps1") } }
if($ok2) { $ok3 = Invoke-Step "Step 3/3 - Analyze" { & (Join-Path $ProjectRoot "runbook\pipeline\12_run_step3_analyze.ps1") } }

$totalTime = (Get-Date) - $start

Write-Host "============================================================" -ForegroundColor Cyan
if($ok1 -and $ok2 -and $ok3) {
    Write-Host "     [OK] FULL PIPELINE COMPLETE" -ForegroundColor Green
    Write-Host ("Total Time: {0} seconds" -f [math]::Round($totalTime.TotalSeconds, 2)) -ForegroundColor White
    Write-Host "Outputs:" -ForegroundColor Cyan
    Write-Host "  - CONFIG\\data\\sample_data.csv" -ForegroundColor Gray
    Write-Host "  - outputs\\converted_phase1.csv" -ForegroundColor Gray
    Write-Host "  - Validation\\Reports\\PHASE1_VALIDATION_REPORT.json" -ForegroundColor Gray
    Write-Host "  - Validation\\Reports\\PHASE1_SIGNALS_REPORT.json" -ForegroundColor Gray
} else {
    Write-Host "     [FAIL] PIPELINE FAILED" -ForegroundColor Red
    Write-Host "Errors:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "============================================================\n" -ForegroundColor Cyan

Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  - Run tests: .\\runbook\\testing\\23_test_full_pipeline.ps1" -ForegroundColor Gray
Write-Host "  - Run audit: .\\runbook\\audit\\30_audit_data_flow.ps1" -ForegroundColor Gray
Write-Host "  - Launch UI: .\\runbook\\pipeline\\13_run_step4_ui.ps1" -ForegroundColor Gray
