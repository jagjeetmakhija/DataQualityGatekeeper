# Master orchestration script
param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile
)

# Load common functions
. (Join-Path $PSScriptRoot "Common-Functions.ps1")

Write-Host ""
Write-Host "======================================" -ForegroundColor Magenta
Write-Host "  PHASE-1 PIPELINE - COMPLETE RUN" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Magenta
Write-Host ""

$startTime = Get-Date
$masterAudit = Initialize-AuditLog -ScriptName "RUN-ALL" -InputFile $InputFile -OutputDirectory "05-Outputs"

try {
    # Pre-flight checks
    Write-StepHeader -StepNumber "0" -StepName "PRE-FLIGHT CHECKS" -Icon "[CHECK]"
    
    # Create output directory if missing
    if (-not (Test-Path "..\05-Outputs")) {
        New-Item -ItemType Directory -Path "..\05-Outputs" -Force | Out-Null
    }
    
    if (-not (Test-Path $InputFile)) {
        throw "Input file not found: $InputFile"
    }
    Write-Success "Input file exists: $InputFile"
    
    if (-not (Test-Path "..\02-Schema\schema.json")) {
        throw "Schema file not found"
    }
    Write-Success "Schema files validated"
    
    # Step 1: Auto-Fix
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    
    $step1Start = Get-Date
    & (Join-Path $PSScriptRoot "Step1-AutoFix.ps1") -InputFile $InputFile
    
    if ($LASTEXITCODE -ne 0) {
        throw "Step 1 (Auto-Fix) failed with exit code: $LASTEXITCODE"
    }
    
    $step1Duration = (Get-Date) - $step1Start
    Add-AuditEvent -AuditLog $masterAudit -EventType "Step1" -Message "Auto-Fix completed in $($step1Duration.TotalSeconds)s" -Severity "success"
    
    $cleanedFile = "..\05-Outputs\autofix-audit\cleaned-data.csv"
    if (-not (Test-Path $cleanedFile)) {
        throw "Cleaned data file not found: $cleanedFile"
    }
    
    # Step 2: Validation
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    
    $step2Start = Get-Date
    & (Join-Path $PSScriptRoot "Step2-Validate.ps1") -InputFile $cleanedFile
    
    if ($LASTEXITCODE -ne 0) {
        throw "Step 2 (Validation) failed with exit code: $LASTEXITCODE"
    }
    
    $step2Duration = (Get-Date) - $step2Start
    Add-AuditEvent -AuditLog $masterAudit -EventType "Step2" -Message "Validation completed in $($step2Duration.TotalSeconds)s" -Severity "success"
    
    # Summary
    $totalDuration = (Get-Date) - $startTime
    
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host "  PIPELINE COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Metric -Label "Total Duration" -Value "$([math]::Round($totalDuration.TotalSeconds, 2)) seconds" -Icon "[TIME]"
    Write-Metric -Label "Input File" -Value $InputFile -Icon "[FILE]"
    Write-Metric -Label "Output Directory" -Value "..\05-Outputs\" -Icon "[DIR]"
    
    Write-Host ""
    Write-Host "  Generated Outputs:" -ForegroundColor Yellow
    Write-Host "     [OK] Cleaned Data" -ForegroundColor Green
    Write-Host "     [OK] Auto-Fix Audit Report" -ForegroundColor Green
    Write-Host "     [OK] Validation Report" -ForegroundColor Green
    Write-Host "     [OK] Traceability Matrix" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "  Next: Start UI to view results" -ForegroundColor Cyan
    Write-Host "  Command: cd 04-UI ; python app.py" -ForegroundColor Gray
    Write-Host ""
    
    # Save master audit log
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $masterAuditFile = "..\05-Outputs\master-audit-$timestamp.json"
    Save-AuditLog -AuditLog $masterAudit -OutputPath $masterAuditFile
    
} catch {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Red
    Write-Host "  PIPELINE FAILED" -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    Add-AuditEvent -AuditLog $masterAudit -EventType "Error" -Message $_.Exception.Message -Severity "error"
    $masterAudit.status = "failed"
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $masterAuditFile = "..\05-Outputs\master-audit-FAILED-$timestamp.json"
    Save-AuditLog -AuditLog $masterAudit -OutputPath $masterAuditFile
    
    Write-Host "  Master audit log: $masterAuditFile" -ForegroundColor Yellow
    Write-Host ""
    
    exit 1
}
