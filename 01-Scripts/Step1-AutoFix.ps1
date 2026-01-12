[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [int]$StepNumber = 1,

  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$OutputDir,

  [Parameter(Mandatory=$false)]
  [string]$BasePath,

  [Parameter(Mandatory=$false)]
  [string]$DataPath,

  [Parameter(Mandatory=$false)]
  [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "$PSScriptRoot\Common-Functions.ps1"

# Resolve defaults
$ProjectRoot = Get-ProjectRoot
if (-not $BasePath)   { $BasePath = $ProjectRoot }
if (-not $DataPath)   { $DataPath = Join-Path $BasePath "DataFiles" }
if (-not $ConfigPath) { $ConfigPath = Join-Path $BasePath "config.json" }

Ensure-Directory -Path $OutputDir

# 🔑 Make Python write into THIS run folder
$env:OUTPUT_RUN_DIR = $OutputDir
$env:OUTPUT_PATH    = Join-Path $BasePath "05-Outputs"

$stepLog = Join-Path $OutputDir "step1_autofix.log"
"Step1-AutoFix started: $(Get-Date)" | Out-File -FilePath $stepLog -Encoding utf8
"OutputDir: $OutputDir" | Out-File -FilePath $stepLog -Append -Encoding utf8
"DataPath: $DataPath" | Out-File -FilePath $stepLog -Append -Encoding utf8
"ConfigPath: $ConfigPath" | Out-File -FilePath $stepLog -Append -Encoding utf8


$python = "python"
$inputCsv = Get-ChildItem -Path $DataPath -Filter *.csv | Select-Object -First 1
if (-not $inputCsv) { throw "No CSV found in $DataPath" }

"Calling Python auto_fixer.py on $($inputCsv.FullName)" |
    Out-File -FilePath $stepLog -Append -Encoding utf8

& $python (Join-Path $BasePath "03-Modules\auto_fixer.py") $inputCsv.FullName

"Step1-AutoFix completed: $(Get-Date)" | Out-File -FilePath $stepLog -Append -Encoding utf8
