# ============================================================
# RUN-ALL.ps1  (Phase-1 E2E)
# Step1 (AutoFix) -> Step2 (Validate)
# Uses config.json as the single source of truth for DataPath
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts][$Level] $Message"
}

Write-Host ""
Write-Host "================================================================================"
Write-Host " Phase-1 E2E Pipeline (RUN-ALL)"
Write-Host "================================================================================"
Write-Host ""

# Resolve BASE_PATH (project root)
$BasePath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# Resolve CONFIG_PATH
$ConfigPath = Join-Path $BasePath "config.json"
if (!(Test-Path $ConfigPath)) { throw "Config file not found: $ConfigPath" }

# Load config
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

# Resolve DATA_PATH + OUTPUT_ROOT from config (NO hardcoding DataFiles)
$DataPath   = $config.paths.data_files_path
$OutputRoot = $config.paths.output_root

if ([string]::IsNullOrWhiteSpace($DataPath))   { throw "config.paths.data_files_path is missing/empty in config.json" }
if ([string]::IsNullOrWhiteSpace($OutputRoot)) { $OutputRoot = Join-Path $BasePath "05-Outputs" }

if (!(Test-Path $OutputRoot)) { New-Item -ItemType Directory -Path $OutputRoot | Out-Null }

# Create a new run output folder
$RunOutputDir = Join-Path $OutputRoot ("Output_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
New-Item -ItemType Directory -Path $RunOutputDir | Out-Null

Write-Log "Starting E2E pipeline..."
Write-Log "BASE_PATH   : $BasePath"
Write-Log "DATA_PATH   : $DataPath"
Write-Log "CONFIG_PATH : $ConfigPath"
Write-Log "Run OutputDir: $RunOutputDir"

# ---------------------------
# STEP 1 - AutoFix
# ---------------------------
Write-Host ""
Write-Host "================================================================================"
Write-Host " Step 1 - AutoFix"
Write-Host "================================================================================"
Write-Host ""

$Step1Script = Join-Path $PSScriptRoot "Step1-AutoFix.ps1"
if (!(Test-Path $Step1Script)) { throw "Missing Step1 script: $Step1Script" }

& $Step1Script -StepNumber 1 -OutputDir $RunOutputDir -BasePath $BasePath -DataPath $DataPath -ConfigPath $ConfigPath

# ---------------------------
# STEP 2 - Validate
# ---------------------------
Write-Host ""
Write-Host "================================================================================"
Write-Host " Step 2 - Validate"
Write-Host "================================================================================"
Write-Host ""

$Step2Script = Join-Path $PSScriptRoot "Step2-Validate.ps1"
if (!(Test-Path $Step2Script)) { throw "Missing Step2 script: $Step2Script" }

& $Step2Script -StepNumber 2 -OutputDir $RunOutputDir -BasePath $BasePath -DataPath $DataPath -ConfigPath $ConfigPath

Write-Log "E2E pipeline completed."
Write-Log "Outputs saved to: $RunOutputDir"
