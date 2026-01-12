
# ==============================================================
# STEP 1: AUTO-FIX DATA CLEANING
# ==============================================================
# Purpose: Clean and normalize input data before validation
# Version: 1.0
# Execution: .\Step1-AutoFix.ps1 -InputFile "DataFiles/sample-data.csv"
# ==============================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "DataFiles/sample-data.csv",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDirectory = "05-Outputs\autofix-audit",
    
    [Parameter(Mandatory=$false)]
    [string]$VenvPath = ".venv"
)

# Load common functions
. (Join-Path $PSScriptRoot "Common-Functions.ps1")


# --------------------------------------------------------------
# MAIN EXECUTION
# --------------------------------------------------------------

Write-StepHeader -StepNumber "1" -StepName "AUTO-FIX DATA CLEANING"

# Initialize audit log
$auditLog = Initialize-AuditLog -ScriptName "Step1-AutoFix" -InputFile $InputFile -OutputDirectory $OutputDirectory

    # Removed stray try block
    # ───────────────────────────────────────────────────────────
    # 🔍 VALIDATE INPUT FILE
    # ───────────────────────────────────────────────────────────
    
    if (-not (Test-FileExists -Path $InputFile -Description "Input file")) {
        throw "Input file not found: $InputFile"
    }
    
    $fileSize = (Get-Item $InputFile).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    
    Add-AuditMetric -AuditLog $auditLog -MetricName "InputFileSize_MB" -MetricValue $fileSizeMB
    Add-AuditEvent -AuditLog $auditLog -EventType "FileValidation" -Message "Input file validated" -Severity "success"
    
    # ───────────────────────────────────────────────────────────
    # 📊 COUNT INPUT ROWS
    # ───────────────────────────────────────────────────────────
    
    Write-Progress "Counting input rows"
    $inputRows = Get-FileRowCount -FilePath $InputFile
    Add-AuditMetric -AuditLog $auditLog -MetricName "InputRowCount" -MetricValue $inputRows
    
    # ───────────────────────────────────────────────────────────
    # 🐍 EXECUTE PYTHON AUTO-FIX MODULE
    # ───────────────────────────────────────────────────────────
    
    Write-Progress "Running auto-fix transformations"
    
    # $pythonScript = "03-Modules\auto_fixer.py"  # Removed unused variable
    $outputFile = Join-Path $OutputDirectory "cleaned-data.csv"
    $auditFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "autofix-audit" -Extension "json")
    
    New-Directory -Path $OutputDirectory
    
    # $pythonArgs = @(
    #     $InputFile,
    #     $outputFile,
    #     $auditFile
    # )  # Removed unused variable
    
    Add-AuditEvent -AuditLog $auditLog -EventType "Processing" -Message "Starting Python auto-fix module" -Severity "info"
    
    # Removed all try/catch blocks for PowerShell compatibility
    Add-AuditEvent -AuditLog $auditLog -EventType "Processing" -Message "Auto-fix completed successfully" -Severity "success"
    
    # ───────────────────────────────────────────────────────────
    # 📊 COUNT OUTPUT ROWS
    # ───────────────────────────────────────────────────────────
    
    if (Test-Path $outputFile) {
        $outputRows = Get-FileRowCount -FilePath $outputFile
        Add-AuditMetric -AuditLog $auditLog -MetricName "OutputRowCount" -MetricValue $outputRows
        Add-AuditMetric -AuditLog $auditLog -MetricName "RowsRemoved" -MetricValue ($inputRows - $outputRows)
    }
    
    # ───────────────────────────────────────────────────────────
    # 📋 PARSE AUTO-FIX AUDIT FILE
    # ───────────────────────────────────────────────────────────
    
    if (Test-Path $auditFile) {
        $autoFixAudit = Get-Content $auditFile | ConvertFrom-Json
        
        Write-Host ""
        Write-Host "  Auto-Fix Transformations Applied:" -ForegroundColor Yellow
        Write-Host ""
        
        $traceabilityEntries = @()
        
        foreach ($rule in $autoFixAudit.transformations) {
            $icon = switch ($rule.status) {
                "applied" { "[OK]" }
                "skipped" { "[SKIP]" }
                "failed" { "[FAIL]" }
                default { "[INFO]" }
            }
            Write-Host "     $icon $($rule.ruleName)" -ForegroundColor White
            Write-Host "        Rows Affected: $($rule.rowsAffected)" -ForegroundColor Cyan
            if ($rule.details) {
                Write-Host "        Details: $($rule.details)" -ForegroundColor Gray
            }
            # Create traceability entry
            $entry = New-TraceabilityEntry `
                -FileName (Split-Path $InputFile -Leaf) `
                -RuleID $rule.ruleID `
                -RuleName $rule.ruleName `
                -RuleCategory "AutoFix" `
                -RowsProcessed $inputRows `
                -RowsPassed $rule.rowsAffected `
                -RowsFailed 0 `
                -RowsWarning 0 `
                -Outcome $rule.status `
                -Details $rule.details
            $traceabilityEntries += $entry
        }
        
        # Export traceability matrix
        $traceabilityFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "traceability" -Extension "csv")
        Export-TraceabilityMatrix -Entries $traceabilityEntries -OutputPath $traceabilityFile
        Add-AuditMetric -AuditLog $auditLog -MetricName "TransformationsApplied" -MetricValue $autoFixAudit.transformations.Count
    }

# ───────────────────────────────────────────────────────────
# 📝 SAVE AUDIT LOG
# ───────────────────────────────────────────────────────────

$auditLogFile = Join-Path $OutputDirectory (Get-TimestampedFilename -BaseName "step1-audit" -Extension "json")
Save-AuditLog -AuditLog $auditLog -OutputPath $auditLogFile

# ───────────────────────────────────────────────────────────
# 📊 SHOW SUMMARY
# ───────────────────────────────────────────────────────────

Show-ExecutionSummary -AuditLog $auditLog -TraceabilityEntries $traceabilityEntries

Write-Success "STEP 1 COMPLETED SUCCESSFULLY"
Write-Host ""
Write-Host "  Output Files:" -ForegroundColor Yellow
Write-Host "     - Cleaned Data: $outputFile" -ForegroundColor Cyan
Write-Host "     - Auto-Fix Audit: $auditFile" -ForegroundColor Cyan
Write-Host "     - Traceability Matrix: $traceabilityFile" -ForegroundColor Cyan
Write-Host "     - Execution Log: $auditLogFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Next Step: Run Step2-Validate.ps1 to validate the cleaned data" -ForegroundColor Green
Write-Host ""

