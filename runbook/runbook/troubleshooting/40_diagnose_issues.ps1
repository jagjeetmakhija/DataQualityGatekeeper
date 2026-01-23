<#
.SYNOPSIS
    40_diagnose_issues.ps1

.PURPOSE
    Diagnose common issues: missing files, execution policy, port conflicts.

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
Write-Host "     🩺 DIAGNOSTICS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Missing mandatory files
$mandatory = @("CONFIG.ps1","Generate-DummyData.ps1","E2E-LocalValidationPipeline.ps1","Analyze-PursuitData.ps1","Start-LocalUI.ps1")
Write-Host "Mandatory root files:" -ForegroundColor Yellow
$missing = @()
foreach($f in $mandatory){
    if(Test-Path (Join-Path $ProjectRoot $f)) { Write-Host "  ✅ $f" -ForegroundColor Green }
    else { Write-Host "  ❌ $f" -ForegroundColor Red; $missing += $f }
}

# Execution policy
Write-Host "`nExecution policy (CurrentUser):" -ForegroundColor Yellow
$policy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "  $policy" -ForegroundColor White
if($policy -notin @("RemoteSigned","Unrestricted","Bypass")){
    Write-Host "  ⚠️  Consider: .\runbook\troubleshooting\41_fix_execution_policy.ps1" -ForegroundColor Yellow
}

# Port checks for UI
function Test-Port($port){
    try { return (Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet) } catch { return $false }
}
Write-Host "`nPorts (UI optional):" -ForegroundColor Yellow
foreach($p in 5173,5175){
    $open = Test-Port $p
    if($open){ Write-Host "  ⚠️  Port $p in use (UI may already be running)" -ForegroundColor Yellow }
    else { Write-Host "  ✅ Port $p available" -ForegroundColor Green }
}

Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
if($missing.Count -eq 0){
    Write-Host "✅ Diagnostics complete: no blocking issues found." -ForegroundColor Green
} else {
    Write-Host "⚠️  Diagnostics complete: missing $($missing.Count) file(s)." -ForegroundColor Yellow
}
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
