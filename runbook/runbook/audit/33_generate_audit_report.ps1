<#
.SYNOPSIS
    33_generate_audit_report.ps1

.PURPOSE
    Generates a simple audit summary file under runbook\reports\

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
Write-Host "     🧾 GENERATE AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$reportDir = Join-Path $ProjectRoot "runbook\reports"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

# Gather facts
$summary = [ordered]@{
    generated_at = (Get-Date).ToString("s")
    sample_data_exists = (Test-Path (Join-Path $ProjectRoot "CONFIG\data\sample_data.csv"))
    converted_exists   = (Test-Path (Join-Path $ProjectRoot "outputs\converted_phase1.csv"))
    validation_report  = (Test-Path (Join-Path $ProjectRoot "Validation\Reports\PHASE1_VALIDATION_REPORT.json"))
    signals_report     = (Test-Path (Join-Path $ProjectRoot "Validation\Reports\PHASE1_SIGNALS_REPORT.json"))
}

# Attach row counts if possible
try { $summary.sample_data_rows = (Import-Csv (Join-Path $ProjectRoot "CONFIG\data\sample_data.csv")).Count } catch {}
try { $summary.converted_rows   = (Import-Csv (Join-Path $ProjectRoot "outputs\converted_phase1.csv")).Count } catch {}

# Attach scores if possible
try {
    $r = Get-Content (Join-Path $ProjectRoot "Validation\Reports\PHASE1_VALIDATION_REPORT.json") | ConvertFrom-Json
    $summary.validation_status = $r.Summary.OverallStatus
    $summary.quality_score     = $r.Summary.QualityScore
} catch {}

try {
    $s = Get-Content (Join-Path $ProjectRoot "Validation\Reports\PHASE1_SIGNALS_REPORT.json") | ConvertFrom-Json
    $summary.total_deals   = $s.Summary.TotalDeals
    $summary.high_priority = $s.Summary.HighPriority
    $summary.high_risk     = $s.Summary.HighRisk
} catch {}

$out = Join-Path $reportDir "AUDIT_SUMMARY.json"
$summary | ConvertTo-Json -Depth 6 | Out-File -FilePath $out -Encoding UTF8

Write-Host "✅ Generated: runbook\reports\AUDIT_SUMMARY.json" -ForegroundColor Green
Write-Host "`nTip: Run these too:" -ForegroundColor Cyan
Write-Host "  • .\runbook\audit\30_audit_data_flow.ps1" -ForegroundColor Gray
Write-Host "  • .\runbook\audit\31_audit_rule_application.ps1" -ForegroundColor Gray
Write-Host "  • .\runbook\audit\32_audit_output_quality.ps1" -ForegroundColor Gray
Write-Host "`n═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
