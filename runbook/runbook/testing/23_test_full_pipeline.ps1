<#
.SYNOPSIS
    23_test_full_pipeline.ps1

.PURPOSE
    Runs all tests (Steps 1-3) and reports pass/fail.

.NOTES
    - Auto-detects the project root based on this script location.
    - Safe to run multiple times.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Project root is two levels up from runbook\<area>\<script>.ps1
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $ProjectRoot


Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "     ✅ FULL PIPELINE TEST SUITE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$tests = @(
    "runbook\testing\20_test_step1_output.ps1",
    "runbook\testing\21_test_step2_output.ps1",
    "runbook\testing\22_test_step3_output.ps1"
)

$passed = 0
$failed = 0
$errors = @()

foreach($t in $tests) {
    $full = Join-Path $ProjectRoot $t
    Write-Host "Running: $t" -ForegroundColor Yellow
    try {
        & $full
        $passed++
        Write-Host "✅ PASS: $t`n" -ForegroundColor Green
    } catch {
        $failed++
        $msg = $_.Exception.Message
        $errors += "$t => $msg"
        Write-Host "❌ FAIL: $t - $msg`n" -ForegroundColor Red
    }
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ("Passed: {0} | Failed: {1}" -f $passed, $failed) -ForegroundColor White

if($failed -gt 0) {
    Write-Host "`nErrors:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  • $_" -ForegroundColor Red }
    exit 1
}

Write-Host "`n✅ ALL TESTS PASSED" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
