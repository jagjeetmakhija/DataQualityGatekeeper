# ═══════════════════════════════════════════════════════════════
# 📦 COMMON FUNCTIONS FOR PHASE-1 LOCAL INSIGHTS
# ═══════════════════════════════════════════════════════════════
# Purpose: Shared utilities for all Phase-1 PowerShell scripts
# Version: 1.0
# ═══════════════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────────────
# 🎨 CONSOLE FORMATTING
# ───────────────────────────────────────────────────────────────

function Write-StepHeader {
    param(
        [string]$StepNumber,
        [string]$StepName,
        [string]$Icon = "[*]"
    )
    
    $border = "═" * 70
    Write-Host ""
    Write-Host $border -ForegroundColor Cyan
    Write-Host " $Icon STEP $StepNumber : $StepName" -ForegroundColor Yellow
    Write-Host $border -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] SUCCESS: $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[X] ERROR: $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] INFO: $Message" -ForegroundColor Cyan
}

function Write-Progress {
    param([string]$Message)
    Write-Host "[...] $Message..." -ForegroundColor Gray
}

function Write-Metric {
    param(
        [string]$Label,
        [string]$Value,
        [string]$Icon = "[M]"
    )
    Write-Host "  $Icon $Label" -NoNewline -ForegroundColor White
    Write-Host " : $Value" -ForegroundColor Cyan
}

# ───────────────────────────────────────────────────────────────
# 📁 FILE & DIRECTORY OPERATIONS
# ───────────────────────────────────────────────────────────────

function Ensure-Directory {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Info "Created directory: $Path"
    }
}

function Get-TimestampedFilename {
    param(
        [string]$BaseName,
        [string]$Extension = "json",
        [string]$Prefix = ""
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    
    if ($Prefix) {
        return "$Prefix-$BaseName-$timestamp.$Extension"
    } else {
        return "$BaseName-$timestamp.$Extension"
    }
}

function Get-SafeFilePath {
    param(
        [string]$Directory,
        [string]$Filename
    )
    
    Ensure-Directory -Path $Directory
    return Join-Path $Directory $Filename
}

# ───────────────────────────────────────────────────────────────
# 📊 LOGGING & AUDIT TRAIL
# ───────────────────────────────────────────────────────────────

function Initialize-AuditLog {
    param(
        [string]$ScriptName,
        [string]$InputFile = "",
        [string]$OutputDirectory
    )
    
    $log = @{
        scriptName = $ScriptName
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        timestampISO = Get-Date -Format "o"
        inputFile = $InputFile
        outputDirectory = $OutputDirectory
        machineName = $env:COMPUTERNAME
        userName = $env:USERNAME
        pwshVersion = $PSVersionTable.PSVersion.ToString()
        startTime = Get-Date
        events = @()
        metrics = @{}
        status = "running"
    }
    
    return $log
}

function Add-AuditEvent {
    param(
        [hashtable]$AuditLog,
        [string]$EventType,
        [string]$Message,
        [string]$Severity = "info",
        [hashtable]$Details = @{}
    )
    
    $event = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        eventType = $EventType
        message = $Message
        severity = $Severity
        details = $Details
    }
    
    $AuditLog.events += $event
    
    # Also display to console
    switch ($Severity) {
        "error" { Write-Error $Message }
        "warning" { Write-Warning $Message }
        "success" { Write-Success $Message }
        default { Write-Info $Message }
    }
}

function Add-AuditMetric {
    param(
        [hashtable]$AuditLog,
        [string]$MetricName,
        $MetricValue
    )
    
    $AuditLog.metrics[$MetricName] = $MetricValue
    Write-Metric -Label $MetricName -Value $MetricValue
}

function Save-AuditLog {
    param(
        [hashtable]$AuditLog,
        [string]$OutputPath
    )
    
    $AuditLog.endTime = Get-Date
    $AuditLog.durationSeconds = ($AuditLog.endTime - $AuditLog.startTime).TotalSeconds
    $AuditLog.status = "completed"
    
    # Remove startTime/endTime objects (not JSON serializable directly)
    $jsonLog = $AuditLog.Clone()
    $jsonLog.startTime = $AuditLog.startTime.ToString("o")
    $jsonLog.endTime = $AuditLog.endTime.ToString("o")
    
    $json = $jsonLog | ConvertTo-Json -Depth 10
    $json | Out-File -FilePath $OutputPath -Encoding UTF8
    
    Write-Success "Audit log saved: $OutputPath"
}

# ───────────────────────────────────────────────────────────────
# 🐍 PYTHON ENVIRONMENT UTILITIES
# ───────────────────────────────────────────────────────────────

function Get-PythonCommand {
    param(
        [string]$VenvPath = ".venv"
    )
    
    # Check if venv exists and use it, otherwise use system Python
    $venvPython = Join-Path $VenvPath "Scripts\python.exe"
    
    if (Test-Path $venvPython) {
        Write-Info "Using Python from virtual environment: $venvPython"
        return $venvPython
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Warning "Virtual environment not found. Using system Python."
        return "python"
    } else {
        throw "❌ Python not found! Install Python 3.10+ or activate virtual environment."
    }
}

function Invoke-PythonScript {
    param(
        [string]$ScriptPath,
        [string[]]$Arguments = @(),
        [string]$VenvPath = ".venv"
    )
    
    $python = Get-PythonCommand -VenvPath $VenvPath
    
    Write-Progress "Executing Python script: $ScriptPath"
    
    $argString = $Arguments -join " "
    $fullCommand = "& '$python' '$ScriptPath' $argString"
    
    Write-Host "  Command: $fullCommand" -ForegroundColor DarkGray
    
    $output = & $python $ScriptPath @Arguments 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Python script completed successfully"
        return $output
    } else {
        Write-Error "Python script failed with exit code: $LASTEXITCODE"
        Write-Host $output -ForegroundColor Red
        throw "Python script execution failed"
    }
}

# ───────────────────────────────────────────────────────────────
# 📋 DATA VALIDATION HELPERS
# ───────────────────────────────────────────────────────────────

function Test-FileExists {
    param(
        [string]$Path,
        [string]$Description = "File"
    )
    
    if (Test-Path $Path) {
        Write-Success "$Description exists: $Path"
        return $true
    } else {
        Write-Error "$Description not found: $Path"
        return $false
    }
}

function Get-FileRowCount {
    param([string]$FilePath)
    
    if ($FilePath -match '\.csv$') {
        $rows = (Get-Content $FilePath | Measure-Object -Line).Lines - 1  # Subtract header
        return $rows
    } elseif ($FilePath -match '\.(xlsx|xls)$') {
        Write-Warning "Excel row count requires Python/pandas - returning estimate"
        return "N/A (Excel)"
    } else {
        $rows = (Get-Content $FilePath | Measure-Object -Line).Lines
        return $rows
    }
}

# ───────────────────────────────────────────────────────────────
# 🎯 TRACEABILITY MATRIX HELPERS
# ───────────────────────────────────────────────────────────────

function New-TraceabilityEntry {
    param(
        [string]$FileName,
        [string]$RuleID,
        [string]$RuleName,
        [string]$RuleCategory,
        [int]$RowsProcessed = 0,
        [int]$RowsPassed = 0,
        [int]$RowsFailed = 0,
        [int]$RowsWarning = 0,
        [string]$Outcome,
        [string]$Details = ""
    )
    
    return [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        FileName = $FileName
        RuleID = $RuleID
        RuleName = $RuleName
        RuleCategory = $RuleCategory
        RowsProcessed = $RowsProcessed
        RowsPassed = $RowsPassed
        RowsFailed = $RowsFailed
        RowsWarning = $RowsWarning
        RowsVoid = $RowsProcessed - $RowsPassed - $RowsFailed - $RowsWarning
        Outcome = $Outcome
        Details = $Details
    }
}

function Export-TraceabilityMatrix {
    param(
        [array]$Entries,
        [string]$OutputPath
    )
    
    if ($Entries.Count -eq 0) {
        Write-Warning "No traceability entries to export"
        return
    }
    
    $Entries | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Success "Traceability matrix exported: $OutputPath"
}

# ───────────────────────────────────────────────────────────────
# 📈 SUMMARY REPORT GENERATION
# ───────────────────────────────────────────────────────────────

function Show-ExecutionSummary {
    param(
        [hashtable]$AuditLog,
        [array]$TraceabilityEntries = @()
    )
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  [SUMMARY] EXECUTION SUMMARY" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Metric -Label "Script" -Value $AuditLog.scriptName -Icon "[S]"
    Write-Metric -Label "Duration" -Value "$([math]::Round($AuditLog.durationSeconds, 2)) seconds" -Icon "[T]"
    Write-Metric -Label "Status" -Value $AuditLog.status -Icon "[*]"
    
    if ($AuditLog.inputFile) {
        Write-Metric -Label "Input File" -Value $AuditLog.inputFile -Icon "[F]"
    }
    
    Write-Host ""
    Write-Host "  [M] Metrics:" -ForegroundColor White
    foreach ($metric in $AuditLog.metrics.GetEnumerator()) {
        Write-Host "     • $($metric.Key): " -NoNewline -ForegroundColor Gray
        Write-Host $metric.Value -ForegroundColor Cyan
    }
    
    if ($TraceabilityEntries.Count -gt 0) {
        Write-Host ""
        Write-Host "  [?] Traceability Summary:" -ForegroundColor White
        
        $totalPassed = ($TraceabilityEntries | Measure-Object -Property RowsPassed -Sum).Sum
        $totalFailed = ($TraceabilityEntries | Measure-Object -Property RowsFailed -Sum).Sum
        $totalWarning = ($TraceabilityEntries | Measure-Object -Property RowsWarning -Sum).Sum
        
        Write-Host "     ✅ Passed: " -NoNewline -ForegroundColor Green
        Write-Host $totalPassed
        Write-Host "     ❌ Failed: " -NoNewline -ForegroundColor Red
        Write-Host $totalFailed
        Write-Host "     ⚠️  Warnings: " -NoNewline -ForegroundColor Yellow
        Write-Host $totalWarning
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

# ───────────────────────────────────────────────────────────────
# 🔧 CONFIGURATION LOADING
# ───────────────────────────────────────────────────────────────

function Get-Configuration {
    param(
        [string]$ConfigPath = "config.json"
    )
    
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        Write-Success "Configuration loaded: $ConfigPath"
        return $config
    } else {
        Write-Warning "Configuration file not found: $ConfigPath. Using defaults."
        return @{
            venvPath = ".venv"
            modulesPath = "03-Modules"
            outputsPath = "05-Outputs"
            schemaPath = "02-Schema"
        }
    }
}

# ───────────────────────────────────────────────────────────────
# 🚀 INITIALIZATION
# ───────────────────────────────────────────────────────────────

Write-Host "✅ Common functions loaded successfully" -ForegroundColor Green
Write-Host "   Available functions:" -ForegroundColor Gray
Write-Host "   • Write-StepHeader, Write-Success, Write-Error, Write-Warning" -ForegroundColor DarkGray
Write-Host "   • Initialize-AuditLog, Add-AuditEvent, Save-AuditLog" -ForegroundColor DarkGray
Write-Host "   • New-TraceabilityEntry, Export-TraceabilityMatrix" -ForegroundColor DarkGray
Write-Host "   • Invoke-PythonScript, Get-PythonCommand" -ForegroundColor DarkGray
Write-Host ""
