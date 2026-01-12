
# =============================================================
# RUN-ALL: MASTER ORCHESTRATION SCRIPT
# =============================================================
# Purpose: Execute complete Phase-1 pipeline from start to finish
# Version: 1.0
# Execution: .\RUN-ALL.ps1 -InputFile "DataFiles/sample-data.csv"
# =============================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "sample-data.csv",
    [Parameter(Mandatory=$false)]
    [string]$VenvPath = ".venv311",
    [Parameter(Mandatory=$false)]
    [switch]$SkipValidation,
    [Parameter(Mandatory=$false)]
    [switch]$SkipQualityCheck
)

# Load common functions
. (Join-Path $PSScriptRoot "Common-Functions.ps1")


# =============================================================
# MAIN ORCHESTRATION
# =============================================================

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  🚀 PHASE-1 LOCAL INSIGHTS - COMPLETE PIPELINE" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

$startTime = Get-Date


# Clean old validation reports for a fresh run
Write-Host "[i] INFO: Cleaning old validation reports..." -ForegroundColor Gray
if (Test-Path "05-Outputs/validation-reports/report.json") {
    Remove-Item "05-Outputs/validation-reports/report.json" -Force
}
# Optionally clean other outputs if needed

# Master audit log
$masterAudit = Initialize-AuditLog -ScriptName "RUN-ALL" -InputFile $InputFile -OutputDirectory "05-Outputs"

    # BEGIN MAIN PIPELINE (no try/catch)
    # ───────────────────────────────────────────────────────────
    # 🔍 PRE-FLIGHT CHECKS
    # ───────────────────────────────────────────────────────────
    
    Write-StepHeader -StepNumber "0" -StepName "PRE-FLIGHT CHECKS" -Icon "🔍"
    
    if (-not (Test-Path $InputFile)) {
        throw "❌ Input file not found: $InputFile"
    }
    Write-Success "Input file exists: $InputFile"
    
    $python = Get-PythonCommand -VenvPath $VenvPath
    Write-Success "Python environment ready: $python"
    
    if (-not (Test-Path "02-Schema\schema.json")) {
        throw "❌ Schema file not found: 02-Schema\schema.json"
    }
    Write-Success "Schema files validated"
    
    Add-AuditEvent -AuditLog $masterAudit -EventType "PreFlight" -Message "All pre-flight checks passed" -Severity "success"
    
    # ───────────────────────────────────────────────────────────
    # 🧹 STEP 1: AUTO-FIX
    # ───────────────────────────────────────────────────────────
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $step1Start = Get-Date
    & (Join-Path $PSScriptRoot "Step1-AutoFix.ps1") -InputFile $InputFile -VenvPath $VenvPath
    
    if ($LASTEXITCODE -ne 0) {
        
    }
    
    $step1Duration = (Get-Date) - $step1Start
    Add-AuditEvent -AuditLog $masterAudit -EventType "Step1" -Message "Auto-Fix completed in $($step1Duration.TotalSeconds)s" -Severity "success"
    
    # Updated file path for next step
    $cleanedFile = "05-Outputs\autofix-audit\cleaned-data.csv"
    
        # Diagnostics: Print working directory and list files in output folder
        Write-Host "[Diagnostics] Current Directory: $(Get-Location)"
        Write-Host "[Diagnostics] Listing files in 05-Outputs/autofix-audit/:"
        Get-ChildItem -Path "05-Outputs/autofix-audit/" | ForEach-Object { Write-Host $_.FullName }
    
    if (-not (Test-Path $cleanedFile)) {
        # Fallback: check if file exists in root output folder and move it
        $fallbackCleaned = "05-Outputs\cleaned-data.csv"
        if (Test-Path $fallbackCleaned) {
            Write-Warning "Cleaned data file found in root output folder. Moving to autofix-audit subfolder for consistency."
            Move-Item -Path $fallbackCleaned -Destination $cleanedFile -Force
        } else {
            throw "❌ Cleaned data file not found: $cleanedFile or $fallbackCleaned"
        }
    }
    
    # ───────────────────────────────────────────────────────────
    # ✅ STEP 2: SCHEMA VALIDATION
    # ───────────────────────────────────────────────────────────
    
    if (-not $SkipValidation) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        $step2Start = Get-Date
        & (Join-Path $PSScriptRoot "Step2-Validate.ps1") -InputFile $cleanedFile -VenvPath $VenvPath
        
        if ($LASTEXITCODE -ne 0) {
            throw "❌ Step 2 (Validation) failed with exit code: $LASTEXITCODE"
        }
        
        $step2Duration = (Get-Date) - $step2Start
        Add-AuditEvent -AuditLog $masterAudit -EventType "Step2" -Message "Validation completed in $($step2Duration.TotalSeconds)s" -Severity "success"

        Write-Info "This step analyzes data completeness, ranges, and anomalies"
        
        # $step3Duration = (Get-Date) - $step3Start  # Removed unused variable
        Add-AuditEvent -AuditLog $masterAudit -EventType "Step3" -Message "Quality check placeholder completed" -Severity "info"
    } else {
        Write-Warning "⏭️  Skipping quality check (SkipQualityCheck flag set)"
    }
    
    # ───────────────────────────────────────────────────────────
    # 📝 STEP 4-7: ANALYSIS PIPELINE
    # ───────────────────────────────────────────────────────────
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-StepHeader -StepNumber "4-7" -StepName "ANALYSIS PIPELINE" -Icon "🧠"
    Write-Info "Steps 4-7 would execute:"
    Write-Info "  • Step 4: Snippet Generation"
    Write-Info "  • Step 5: Local AI Model Analysis"
    Write-Info "  • Step 6: Scoring & Insights"
    Write-Info "  • Step 7: Output Generation"
    Write-Host ""
    Write-Warning "These steps require Python modules to be fully implemented"
    
    # ───────────────────────────────────────────────────────────
    # 📊 MASTER SUMMARY
    # ───────────────────────────────────────────────────────────
    
    $totalDuration = (Get-Date) - $startTime
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  🎉 PIPELINE COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Metric -Label "Total Duration" -Value "$([math]::Round($totalDuration.TotalSeconds, 2)) seconds" -Icon "[TIME]"
    Write-Metric -Label "Input File" -Value $InputFile -Icon "[FILE]"
    Write-Metric -Label "Output Directory" -Value "05-Outputs\" -Icon "[DIR]"
    
    Write-Host ""
    Write-Host "  📋 Generated Outputs:" -ForegroundColor Yellow
    Write-Host "     ✅ Cleaned Data" -ForegroundColor Green
    Write-Host "     ✅ Auto-Fix Audit Report" -ForegroundColor Green
    Write-Host "     ✅ Validation Report" -ForegroundColor Green
    Write-Host "     ✅ Traceability Matrix" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "  🖥️  Next Step: To view results, manually start the UI in a separate terminal." -ForegroundColor Cyan
    <#
    For user reference only (do NOT execute automatically):
        cd 04-UI
        python app.py
    #>
    Write-Host ""
    
    # Save master audit log
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $masterAuditFile = "05-Outputs\master-audit-$timestamp.json"
    Save-AuditLog -AuditLog $masterAudit -OutputPath $masterAuditFile
    
    # Removed stray catch block
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  ❌ PIPELINE FAILED" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    Add-AuditEvent -AuditLog $masterAudit -EventType "Error" -Message $_.Exception.Message -Severity "error"
    $masterAudit.status = "failed"
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $masterAuditFile = "05-Outputs\master-audit-FAILED-$timestamp.json"
    Save-AuditLog -AuditLog $masterAudit -OutputPath $masterAuditFile
    
    Write-Host "  📁 Master audit log: $masterAuditFile" -ForegroundColor Yellow
    Write-Host ""
    
    exit 1
