<#
.SYNOPSIS
    32_audit_output_quality.ps1

.PURPOSE
    Checks output file formats, row counts, and basic completeness (best-effort).

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
Write-Host "     🧪 OUTPUT QUALITY AUDIT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

function Assert-File([string]$path, [string]$label) {
    if(Test-Path $path) {
        $fi = Get-Item $path
        Write-Host ("✅ {0}: OK ({1} KB)" -f $label, [math]::Round($fi.Length/1KB,1)) -ForegroundColor Green
        return $true
    } else {
        Write-Host ("❌ {0}: MISSING" -f $label) -ForegroundColor Red
        return $false
    }
}

$ok = $true
$ok = (Assert-File (Join-Path $ProjectRoot "CONFIG\data\sample_data.csv") "sample_data.csv") -and $ok
$ok = (Assert-File (Join-Path $ProjectRoot "outputs\converted_phase1.csv") "converted_phase1.csv") -and $ok
$ok = (Assert-File (Join-Path $ProjectRoot "Validation\Reports\PHASE1_VALIDATION_REPORT.json") "PHASE1_VALIDATION_REPORT.json") -and $ok
$ok = (Assert-File (Join-Path $ProjectRoot "Validation\Reports\PHASE1_SIGNALS_REPORT.json") "PHASE1_SIGNALS_REPORT.json") -and $ok

Write-Host ""
if(Test-Path (Join-Path $ProjectRoot "outputs\converted_phase1.csv")) {
    $data = Import-Csv (Join-Path $ProjectRoot "outputs\converted_phase1.csv")
    $rows = $data.Count
    $nulls = 0
    foreach($row in $data) {
        foreach($p in $row.PSObject.Properties) {
            if($p.Value -eq $null -or "$($p.Value)".Trim() -eq "") { $nulls++; break }
        }
    }
    Write-Host ("converted_phase1.csv: {0} rows | rows with at least one blank field: {1}" -f $rows, $nulls) -ForegroundColor White
}

Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
if($ok) {
    Write-Host "✅ OUTPUT QUALITY: BASIC CHECKS PASSED" -ForegroundColor Green
} else {
    Write-Host "⚠️  OUTPUT QUALITY: ISSUES FOUND" -ForegroundColor Yellow
    exit 1
}
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
