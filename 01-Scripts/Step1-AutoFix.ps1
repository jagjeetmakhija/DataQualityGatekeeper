param(
    [Parameter(Mandatory = $false)]
    [int]$StepNumber = 1,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir,

    [Parameter(Mandatory = $false)]
    [string]$DataPath,

    [Parameter(Mandatory = $false)]
    [string]$BasePath,

    [Parameter(Mandatory = $false)]
    [string]$ConfigPath
)

# ============================================================
# Step1-AutoFix.ps1 (Phase-1)
# - Config-driven input folder (02-Inputs)
# - Calls auto_fixer.py with single positional arg: <inputfile>
# - Forces python to run with WorkingDirectory = OutputDir
# - Standardizes whatever CSV python produced -> OutputDir\cleaned-data.csv
# - If python writes elsewhere, searches known folders and pulls it back
# ============================================================

$ErrorActionPreference = "Stop"

function Write-HostLog {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts][$Level] $Message"
}

# Resolve BasePath (project root)
if ([string]::IsNullOrWhiteSpace($BasePath)) {
    $BasePath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

# Resolve ConfigPath
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $BasePath "config.json"
}
if (!(Test-Path $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

# Load config
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

# Resolve DataPath
if ([string]::IsNullOrWhiteSpace($DataPath)) {
    $DataPath = $config.paths.data_files_path
}
if ([string]::IsNullOrWhiteSpace($DataPath)) {
    throw "config.paths.data_files_path is missing/empty in config.json"
}
if (!(Test-Path $DataPath)) {
    throw "Input folder not found: $DataPath"
}

# Validate OutputDir
if (!(Test-Path $OutputDir)) {
    throw "OutputDir does not exist: $OutputDir"
}

# Log file (UTF-8)
$LogFile = Join-Path $OutputDir "step1_autofix.log"
"Step1-AutoFix started: $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')" | Out-File $LogFile -Encoding utf8
"OutputDir: $OutputDir" | Out-File $LogFile -Append -Encoding utf8
"DataPath: $DataPath"   | Out-File $LogFile -Append -Encoding utf8
"ConfigPath: $ConfigPath" | Out-File $LogFile -Append -Encoding utf8

# Pick newest CSV from input folder
$inputFile = Get-ChildItem $DataPath -File -Filter "*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $inputFile) {
    $msg = "No CSV files found in input folder: $DataPath"
    $msg | Out-File $LogFile -Append -Encoding utf8
    throw $msg
}

# Locate auto_fixer.py
$autoFixerCandidates = @(
    (Join-Path $BasePath "03-Modules\auto_fixer.py"),
    (Join-Path $BasePath "04-Source\auto_fixer.py"),
    (Join-Path $BasePath "03-Modules\phase1_auto_fixer.py"),
    (Join-Path $BasePath "04-Source\phase1_auto_fixer.py")
)
$autoFixerPy = $autoFixerCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $autoFixerPy) {
    $msg = "auto_fixer.py not found. Checked:`n - " + ($autoFixerCandidates -join "`n - ")
    $msg | Out-File $LogFile -Append -Encoding utf8
    throw $msg
}

# Required artifacts expected by Step2
$cleanedOut = Join-Path $OutputDir "cleaned-data.csv"
$auditDir   = Join-Path $OutputDir "autofix-audit"
if (!(Test-Path $auditDir)) { New-Item -ItemType Directory -Path $auditDir | Out-Null }

$callMsg = "Calling Python auto_fixer.py on $($inputFile.FullName)"
Write-HostLog $callMsg
$callMsg | Out-File $LogFile -Append -Encoding utf8

# Track start time for discovering "newest" outputs
$runStart = Get-Date

# ---- Run python in OutputDir (CRITICAL FIX) ----
try {
    Push-Location $OutputDir
    $pyOut = python $autoFixerPy "$($inputFile.FullName)" 2>&1
    foreach ($line in $pyOut) { $line | Out-File $LogFile -Append -Encoding utf8 }
}
finally {
    Pop-Location
}

# Detect python failure
if ($LASTEXITCODE -ne 0) {
    $msg = "ERROR: Python autofix failed (exit code $LASTEXITCODE). See: $LogFile"
    $msg | Out-File $LogFile -Append -Encoding utf8
    throw $msg
}

# ------------------------------------------------------------
# Find output CSV (python may write to different folders)
# Strategy:
# 1) Check OutputDir
# 2) Check common known output roots under this repo
# 3) Pick newest CSV created/updated after runStart, then standardize it
# ------------------------------------------------------------

function Get-NewCsvCandidates {
    param([string]$PathRoot)

    if (!(Test-Path $PathRoot)) { return @() }

    Get-ChildItem -Path $PathRoot -Recurse -File -Filter "*.csv" -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -ne $inputFile.FullName -and
            $_.LastWriteTime -ge $runStart.AddSeconds(-5)
        } |
        Sort-Object LastWriteTime -Descending
}

# First: OutputDir only
$candidates = Get-NewCsvCandidates -PathRoot $OutputDir

# If nothing, search common output locations inside repo (fast + targeted)
if (-not $candidates -or $candidates.Count -eq 0) {
    $commonRoots = @(
        (Join-Path $BasePath "05-Outputs"),
        (Join-Path $BasePath "06-Documentation\05-Outputs"),
        (Join-Path $BasePath "04-UI\05-Outputs"),
        (Join-Path $BasePath "04-UI")
    )

    foreach ($root in $commonRoots) {
        $more = Get-NewCsvCandidates -PathRoot $root
        if ($more -and $more.Count -gt 0) {
            $candidates = $more
            break
        }
    }
}

# Prefer files that look cleaned/fixed/output
$preferred = $null
if ($candidates -and $candidates.Count -gt 0) {
    $preferred = $candidates | Where-Object { $_.Name -match "clean|fix|output" } | Select-Object -First 1
}

$picked = if ($preferred) { $preferred } elseif ($candidates -and $candidates.Count -gt 0) { $candidates | Select-Object -First 1 } else { $null }

if (-not $picked) {
    $msg = "ERROR: No output CSV found after python run. Checked OutputDir and common repo output roots. OutputDir: $OutputDir"
    $msg | Out-File $LogFile -Append -Encoding utf8
    throw $msg
}

# Standardize to cleaned-data.csv in OutputDir
Copy-Item -Path $picked.FullName -Destination $cleanedOut -Force
"INFO: Standardized output CSV -> cleaned-data.csv (from: $($picked.FullName))" | Out-File $LogFile -Append -Encoding utf8

# Final assert
if (!(Test-Path $cleanedOut)) {
    $msg = "ERROR: cleaned-data.csv still not present after standardization. Expected: $cleanedOut"
    $msg | Out-File $LogFile -Append -Encoding utf8
    throw $msg
}

"Step1-AutoFix completed: $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')" | Out-File $LogFile -Append -Encoding utf8

@{
    status       = "success"
    output_dir   = $OutputDir
    cleaned_data = $cleanedOut
    audit_dir    = $auditDir
} | ConvertTo-Json -Depth 3
