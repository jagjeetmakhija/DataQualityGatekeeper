<#
.SYNOPSIS
    01_setup_environment.ps1

.PURPOSE
    One-time environment setup (execution policy, unblock scripts, sanity checks).

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
Write-Host "  SETUP: Environment" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

# 1) PowerShell version check
$psMajor = $PSVersionTable.PSVersion.Major
if($psMajor -lt 5) {
    throw "PowerShell 5.1+ required. Current: $($PSVersionTable.PSVersion)"
}
Write-Host "✅ PowerShell version OK ($($PSVersionTable.PSVersion))" -ForegroundColor Green

# 2) Execution policy (CurrentUser)
try {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if($currentPolicy -notin @("RemoteSigned","Unrestricted","Bypass")) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "✅ Execution policy set to RemoteSigned (CurrentUser)" -ForegroundColor Green
    } else {
        Write-Host "✅ Execution policy OK ($currentPolicy)" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Could not set execution policy. Try running PowerShell as Administrator." -ForegroundColor Yellow
}

# 3) Unblock runbook scripts (helps when files were downloaded from the internet)
$runbookPath = Join-Path $ProjectRoot "runbook"
if(Test-Path $runbookPath) {
    Get-ChildItem -Path $runbookPath -Recurse -Filter *.ps1 | ForEach-Object {
        try { Unblock-File -Path $_.FullName -ErrorAction Stop } catch {}
    }
    Write-Host "✅ Runbook scripts unblocked" -ForegroundColor Green
} else {
    Write-Host "⚠️  runbook folder not found yet. You can run 03_create_folders.ps1 first." -ForegroundColor Yellow
}

# 4) Validate required root scripts exist (these are your actual pipeline scripts)
$mandatoryRootScripts = @(
    "CONFIG.ps1",
    "Generate-DummyData.ps1",
    "E2E-LocalValidationPipeline.ps1",
    "Analyze-PursuitData.ps1"
)

$missing = @()
foreach($s in $mandatoryRootScripts) {
    if(-not (Test-Path (Join-Path $ProjectRoot $s))) { $missing += $s }
}

if($missing.Count -gt 0) {
    Write-Host "`n⚠️  Missing mandatory files in project root:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    Write-Host "You can still continue setup, but the pipeline won't run until these exist." -ForegroundColor Gray
} else {
    Write-Host "✅ Mandatory root scripts present" -ForegroundColor Green
}

# 5) Load CONFIG.ps1 (if present) so downstream scripts have the same config
if(Test-Path (Join-Path $ProjectRoot "CONFIG.ps1")) {
    . (Join-Path $ProjectRoot "CONFIG.ps1")
    Write-Host "✅ CONFIG.ps1 loaded" -ForegroundColor Green
}

Write-Host "`n✅ Environment setup complete." -ForegroundColor Green
Write-Host "Next: .\runbook\setup\02_verify_prerequisites.ps1" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
