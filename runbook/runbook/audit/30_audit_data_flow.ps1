<#
.SYNOPSIS
    30_audit_data_flow.ps1

.PURPOSE
    Audits data lineage and row counts across steps (0→250→250→signals).

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
Write-Host "     📊 DATA FLOW AUDIT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

function Get-RowCount([string]$path) {
    if(Test-Path $path) { return (Import-Csv $path).Count }
    return $null
}

$step1 = Join-Path $ProjectRoot "CONFIG\data\sample_data.csv"
$step2 = Join-Path $ProjectRoot "outputs\converted_phase1.csv"
$signals = Join-Path $ProjectRoot "Validation\Reports\PHASE1_SIGNALS_REPORT.json"

$rows1 = Get-RowCount $step1
$rows2 = Get-RowCount $step2

Write-Host ("Step 1 Output (sample_data.csv): {0}" -f ($(if($rows1 -ne $null){"$rows1 rows"}else{"MISSING"}))) -ForegroundColor White
Write-Host ("Step 2 Output (converted_phase1.csv): {0}" -f ($(if($rows2 -ne $null){"$rows2 rows"}else{"MISSING"}))) -ForegroundColor White

if(($rows1 -ne $null) -and ($rows2 -ne $null)) {
    $loss = $rows1 - $rows2
    Write-Host ("Row loss Step1→Step2: {0}" -f $loss) -ForegroundColor (if($loss -eq 0){"Green"}else{"Yellow"})
}

if(Test-Path $signals) {
    $obj = Get-Content $signals | ConvertFrom-Json
    Write-Host ("Signals report: {0} deals | HighPriority={1} | HighRisk={2}" -f $obj.Summary.TotalDeals, $obj.Summary.HighPriority, $obj.Summary.HighRisk) -ForegroundColor Green
} else {
    Write-Host "Signals report: MISSING (Validation\Reports\PHASE1_SIGNALS_REPORT.json)" -ForegroundColor Yellow
}

Write-Host "`nFiles:" -ForegroundColor Cyan
@($step1,$step2,$signals) | ForEach-Object {
    if(Test-Path $_) {
        $fi = Get-Item $_
        Write-Host ("  ✅ {0}  ({1} KB)" -f ($fi.FullName.Replace($ProjectRoot.Path + "\", "")), [math]::Round($fi.Length/1KB,1)) -ForegroundColor Green
    } else {
        Write-Host ("  ❌ {0}" -f $_.Replace($ProjectRoot.Path + "\", "")) -ForegroundColor Red
    }
}

Write-Host "`n═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
