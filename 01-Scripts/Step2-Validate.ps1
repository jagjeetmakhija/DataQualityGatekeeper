# ═══════════════════════════════════════════════════════════════
# ✅ STEP 2: SCHEMA VALIDATION (GATE)
# ═══════════════════════════════════════════════════════════════
# Purpose: Validate cleaned data against schema - STOP if FAIL
# Version: 1.0
# Execution: .\Step2-Validate.ps1 -InputFile "path\to\cleaned-data.csv"
# ═══════════════════════════════════════════════════════════════

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$SchemaFile = "02-Schema\schema.json",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDirectory = "05-Outputs\validation-reports",
    
    [Parameter(Mandatory=$false)]
    [string]$VenvPath = ".venv"
)

# Load common functions
. (Join-Path $PSScriptRoot "Common-Functions.ps1")

# ───────────────────────────────────────────────────────────────
# 🎯 MAIN EXECUTION
# ───────────────────────────────────────────────────────────────

Write-StepHeader -StepNumber "2" -StepName "SCHEMA VALIDATION (GATE)" -Icon "✅"

# Initialize audit log
$auditLog = Initialize-AuditLog -ScriptName "Step2-Validate" -InputFile $InputFile -OutputDirectory $OutputDirectory

try {
    # ───────────────────────────────────────────────────────────
    # 🔍 VALIDATE INPUT FILES
    # ───────────────────────────────────────────────────────────
    
    if (-not (Test-FileExists -Path $InputFile -Description "Input file")) {
        throw "Input file not found: $InputFile"
    }
    
    if (-not (Test-FileExists -Path $SchemaFile -Description "Schema file")) {
        throw "Schema file not found: $SchemaFile"
    }
    
    Add-AuditEvent -AuditLog $auditLog -EventType "FileValidation" -Message "Input and schema files validated" -Severity "success"
    
    # ───────────────────────────────────────────────────────────
    # 📊 COUNT INPUT ROWS
    # ───────────────────────────────────────────────────────────
    
    $inputRows = Get-FileRowCount -FilePath $InputFile
    Add-AuditMetric -AuditLog $auditLog -MetricName "InputRowCount" -MetricValue $inputRows
    
    # ───────────────────────────────────────────────────────────
    # 🐍 EXECUTE PYTHON VALIDATION MODULE
    # ───────────────────────────────────────────────────────────
    
    Write-Progress "Running schema validation"
    
    $pythonScript = "03-Modules\validator.py"
    $validationReport = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "validation-report" -Extension "json")
    
    Ensure-Directory -Path $OutputDirectory
    
    $pythonArgs = @(
        $InputFile,
        $SchemaFile,
        $validationReport
    )
    
    Add-AuditEvent -AuditLog $auditLog -EventType "Processing" -Message "Starting schema validation" -Severity "info"
    
    try {
        $pythonOutput = Invoke-PythonScript -ScriptPath $pythonScript -Arguments $pythonArgs -VenvPath $VenvPath
        Add-AuditEvent -AuditLog $auditLog -EventType "Processing" -Message "Validation module completed" -Severity "success"
    } catch {
        Add-AuditEvent -AuditLog $auditLog -EventType "Processing" -Message "Validation module failed: $_" -Severity "error"
        throw
    }
    
    # ───────────────────────────────────────────────────────────
    # 📋 PARSE VALIDATION REPORT
    # ───────────────────────────────────────────────────────────
    
    if (-not (Test-Path $validationReport)) {
        throw "Validation report not generated: $validationReport"
    }
    
    $validation = Get-Content $validationReport | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "  🔍 Validation Results:" -ForegroundColor Yellow
    Write-Host ""
    
    # Overall status
    $statusIcon = if ($validation.overallStatus -eq "PASS") { "✅" } else { "❌" }
    Write-Host "     $statusIcon Overall Status: " -NoNewline -ForegroundColor White
    
    if ($validation.overallStatus -eq "PASS") {
        Write-Host "PASS" -ForegroundColor Green
    } else {
        Write-Host "FAIL" -ForegroundColor Red
    }
    
    Write-Host ""
    
    # Metrics
    Add-AuditMetric -AuditLog $auditLog -MetricName "ValidationStatus" -MetricValue $validation.overallStatus
    Add-AuditMetric -AuditLog $auditLog -MetricName "ErrorCount" -MetricValue $validation.summary.errorCount
    Add-AuditMetric -AuditLog $auditLog -MetricName "WarningCount" -MetricValue $validation.summary.warningCount
    
    Write-Metric -Label "Errors" -Value $validation.summary.errorCount -Icon "❌"
    Write-Metric -Label "Warnings" -Value $validation.summary.warningCount -Icon "⚠️ "
    Write-Metric -Label "Info" -Value $validation.summary.infoCount -Icon "ℹ️ "
    Write-Host ""
    
    # ───────────────────────────────────────────────────────────
    # 📊 BUILD TRACEABILITY MATRIX
    # ───────────────────────────────────────────────────────────
    
    $traceabilityEntries = @()
    
    # Process each validation rule
    foreach ($rule in $validation.rules) {
        $outcome = if ($rule.passed) { "PASS" } else { "FAIL" }
        $icon = if ($rule.passed) { "✅" } else { "❌" }
        
        Write-Host "     $icon $($rule.ruleID): $($rule.ruleName)" -ForegroundColor White
        Write-Host "        Status: $outcome" -ForegroundColor $(if ($rule.passed) { "Green" } else { "Red" })
        Write-Host "        Rows Checked: $($rule.rowsChecked)" -ForegroundColor Cyan
        Write-Host "        Rows Passed: $($rule.rowsPassed)" -ForegroundColor Green
        Write-Host "        Rows Failed: $($rule.rowsFailed)" -ForegroundColor Red
        
        if ($rule.message) {
            Write-Host "        Message: $($rule.message)" -ForegroundColor Gray
        }
        
        Write-Host ""
        
        # Create traceability entry
        $entry = New-TraceabilityEntry `
            -FileName (Split-Path $InputFile -Leaf) `
            -RuleID $rule.ruleID `
            -RuleName $rule.ruleName `
            -RuleCategory $rule.category `
            -RowsProcessed $rule.rowsChecked `
            -RowsPassed $rule.rowsPassed `
            -RowsFailed $rule.rowsFailed `
            -RowsWarning $rule.rowsWarning `
            -Outcome $outcome `
            -Details $rule.message
        
        $traceabilityEntries += $entry
    }
    
    # Export traceability matrix
    $traceabilityFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "traceability" -Extension "csv")
    Export-TraceabilityMatrix -Entries $traceabilityEntries -OutputPath $traceabilityFile
    
    # ───────────────────────────────────────────────────────────
    # 🚦 GATE DECISION: PASS OR FAIL
    # ───────────────────────────────────────────────────────────
    
    if ($validation.overallStatus -eq "FAIL") {
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host "  ❌ VALIDATION FAILED - PROCESSING STOPPED" -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host ""
        Write-Host "  🔧 HOW TO FIX:" -ForegroundColor Yellow
        Write-Host ""
        
        foreach ($fix in $validation.fixInstructions) {
            Write-Host "     • $fix" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "  📁 Validation Report: $validationReport" -ForegroundColor Cyan
        Write-Host "  📊 Traceability Matrix: $traceabilityFile" -ForegroundColor Cyan
        Write-Host ""
        
        Add-AuditEvent -AuditLog $auditLog -EventType "GateDecision" -Message "Validation FAILED - Processing STOPPED" -Severity "error"
        $auditLog.status = "failed"
        
        $auditLogFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "step2-audit-FAILED" -Extension "json")
        Save-AuditLog -AuditLog $auditLog -OutputPath $auditLogFile
        
        exit 1
    }
    
    # ───────────────────────────────────────────────────────────
    # ✅ VALIDATION PASSED
    # ───────────────────────────────────────────────────────────
    
    Add-AuditEvent -AuditLog $auditLog -EventType "GateDecision" -Message "Validation PASSED - Proceeding to next step" -Severity "success"
    
    # ───────────────────────────────────────────────────────────
    # 📝 SAVE AUDIT LOG
    # ───────────────────────────────────────────────────────────
    
    $auditLogFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "step2-audit" -Extension "json")
    Save-AuditLog -AuditLog $auditLog -OutputPath $auditLogFile
    
    # ───────────────────────────────────────────────────────────
    # 📊 SHOW SUMMARY
    # ───────────────────────────────────────────────────────────
    
    Show-ExecutionSummary -AuditLog $auditLog -TraceabilityEntries $traceabilityEntries
    
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ STEP 2 COMPLETED SUCCESSFULLY - VALIDATION PASSED" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "  📁 Output Files:" -ForegroundColor Yellow
    Write-Host "     • Validation Report: $validationReport" -ForegroundColor Cyan
    Write-Host "     • Traceability Matrix: $traceabilityFile" -ForegroundColor Cyan
    Write-Host "     • Execution Log: $auditLogFile" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ▶️  Next Step: Run Step3-QualityCheck.ps1 for data quality analysis" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Add-AuditEvent -AuditLog $auditLog -EventType "Error" -Message $_.Exception.Message -Severity "error"
    $auditLog.status = "failed"
    
    $auditLogFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "step2-audit-ERROR" -Extension "json")
    Save-AuditLog -AuditLog $auditLog -OutputPath $auditLogFile
    
    Write-Error "❌ STEP 2 FAILED WITH ERROR"
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Audit log saved: $auditLogFile" -ForegroundColor Yellow
    
    exit 1
}
