<#
.SYNOPSIS
    31_audit_rule_application.ps1

.PURPOSE
    Summarizes rule application using available reports (best-effort).

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
Write-Host "     🧾 RULE APPLICATION AUDIT (Best-Effort)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$validationReport = Join-Path $ProjectRoot "Validation\Reports\PHASE1_VALIDATION_REPORT.json"
$signalsReport    = Join-Path $ProjectRoot "Validation\Reports\PHASE1_SIGNALS_REPORT.json"

if(Test-Path $validationReport) {
    $r = Get-Content $validationReport | ConvertFrom-Json
    Write-Host "Validation (Step 2) summary:" -ForegroundColor Yellow
    Write-Host ("  Status: {0}" -f $r.Summary.OverallStatus) -ForegroundColor White
    Write-Host ("  Score:  {0}/100" -f $r.Summary.QualityScore) -ForegroundColor White

    if($r.Rules) {
        $total = $r.Rules.Count
        $failed = ($r.Rules | Where-Object { $_.Result -in @("FAIL","FAILED") }).Count
        Write-Host ("  Rules:  {0} total | {1} failed" -f $total, $failed) -ForegroundColor White
    } else {
        Write-Host "  (No per-rule list found in this report format.)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Missing validation report: Validation\Reports\PHASE1_VALIDATION_REPORT.json" -ForegroundColor Red
}

Write-Host ""
if(Test-Path $signalsReport) {
    $s = Get-Content $signalsReport | ConvertFrom-Json
    Write-Host "Signals (Step 3) summary:" -ForegroundColor Yellow
    Write-Host ("  Deals:  {0}" -f $s.Summary.TotalDeals) -ForegroundColor White
    Write-Host ("  High priority: {0}" -f $s.Summary.HighPriority) -ForegroundColor White
    Write-Host ("  High risk:     {0}" -f $s.Summary.HighRisk) -ForegroundColor White
} else {
    Write-Host "❌ Missing signals report: Validation\Reports\PHASE1_SIGNALS_REPORT.json" -ForegroundColor Red
}

Write-Host "`n═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
