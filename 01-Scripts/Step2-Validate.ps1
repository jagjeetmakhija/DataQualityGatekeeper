param(
    # Backward compatible parameters (RUN-ALL passes these)
    [Parameter(Mandatory = $false)]
    [int]$StepNumber = 2,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir,

    [Parameter(Mandatory = $false)]
    [string]$DataPath,

    [Parameter(Mandatory = $false)]
    [string]$BasePath,

    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "C:\MyCode\cx-ai-local\LocalAIAgent-Phase1\config.json"
)

# ============================================================
# Step2-Validate.ps1
# Purpose:
#   Deterministic validation of Step1 outputs.
#   Fully local, config-driven, auditable.
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp][$Level] $Message"
}

Write-Log "Step2-Validate started"

# -------------------------------
# Load configuration
# -------------------------------
if (!(Test-Path $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

# Resolve BasePath
if ([string]::IsNullOrWhiteSpace($BasePath)) {
    $BasePath = $config.paths.base_path
}

# Resolve DataPath
if ([string]::IsNullOrWhiteSpace($DataPath)) {
    $DataPath = $config.paths.data_files_path
}

# Validate OutputDir
if (!(Test-Path $OutputDir)) {
    throw "OutputDir does not exist: $OutputDir"
}

# -------------------------------
# Log resolved paths
# -------------------------------
Write-Log "OutputDir  : $OutputDir"
Write-Log "BasePath  : $BasePath"
Write-Log "DataPath  : $DataPath"
Write-Log "ConfigPath: $ConfigPath"

# -------------------------------
# Initialize log file
# -------------------------------
$LogFile = Join-Path $OutputDir "step2_validate.log"
"Step2-Validate started: $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')" |
    Out-File $LogFile -Encoding utf8

# -------------------------------
# Validation logic
# -------------------------------

# 1. Find cleaned CSV
$CleanedFile = Get-ChildItem $OutputDir -File -Filter "*.csv" |
               Where-Object { $_.Name -match "clean" } |
               Select-Object -First 1

if (-not $CleanedFile) {
    $msg = "No cleaned CSV file found in OutputDir: $OutputDir"
    Write-Log $msg "ERROR"
    $msg | Out-File $LogFile -Append
    throw $msg
}

Write-Log "Found cleaned file: $($CleanedFile.FullName)"

# 2. Check file is not empty
if ($CleanedFile.Length -eq 0) {
    $msg = "Cleaned file is empty: $($CleanedFile.FullName)"
    Write-Log $msg "ERROR"
    $msg | Out-File $LogFile -Append
    throw $msg
}

# -------------------------------
# 3. Run Python validation (pandas)
# -------------------------------
$pythonCmd = @"
import pandas as pd
import sys

file_path = r"$($CleanedFile.FullName)"

try:
    df = pd.read_csv(file_path)
except Exception as e:
    print(f"ERROR: Failed to read cleaned CSV: {e}")
    sys.exit(1)

if df.empty:
    print("ERROR: Cleaned file contains no rows")
    sys.exit(1)

print(f"Rows: {len(df)}")
print(f"Columns: {len(df.columns)}")

nulls = df.isnull().sum().sum()
print(f"Total Null Values: {nulls}")

print("Basic validation passed")
"@

$TempPyFile = Join-Path $OutputDir "step2_validate_temp.py"
$pythonCmd | Out-File $TempPyFile -Encoding utf8

Write-Log "Running Python validation..."

try {
    $pythonOutput = python $TempPyFile 2>&1
    foreach ($line in $pythonOutput) {
        Write-Log $line
        $line | Out-File $LogFile -Append
    }
}
catch {
    Write-Log "Python validation failed" "ERROR"
    $_ | Out-File $LogFile -Append
    throw
}
finally {
    if (Test-Path $TempPyFile) {
        Remove-Item $TempPyFile -Force
    }
}

# -------------------------------
# Success
# -------------------------------
"Step2-Validate completed: $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')" |
    Out-File $LogFile -Append

Write-Log "Step2-Validate completed"
