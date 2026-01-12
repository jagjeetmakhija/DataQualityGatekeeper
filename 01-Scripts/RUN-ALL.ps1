Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "$PSScriptRoot\Common-Functions.ps1"

Write-Log "Starting E2E pipeline..."

$ProjectRoot = Get-ProjectRoot

# Central paths (env overrides allow flexibility)
$BasePath   = Get-ResolvedPathOrDefault $env:BASE_PATH   $ProjectRoot
$DataPath   = Get-ResolvedPathOrDefault $env:DATA_PATH   (Join-Path $BasePath "DataFiles")
$ConfigPath = Get-ResolvedPathOrDefault $env:CONFIG_PATH (Join-Path $BasePath "config.json")

$OutputsRoot = Join-Path $BasePath "05-Outputs"
$RunOutputDir = New-RunOutputDir -OutputsRoot $OutputsRoot -Prefix "Output_"

Write-Log "BASE_PATH   : $BasePath"
Write-Log "DATA_PATH   : $DataPath"
Write-Log "CONFIG_PATH : $ConfigPath"
Write-Log "Run OutputDir: $RunOutputDir"

# Make run folder available to anything launched in this session (optional)
$env:OUTPUT_RUN_DIR = $RunOutputDir

Write-StepHeader "Step 1 - AutoFix"
& "$PSScriptRoot\Step1-AutoFix.ps1" -StepNumber 1 -OutputDir $RunOutputDir -BasePath $BasePath -DataPath $DataPath -ConfigPath $ConfigPath

Write-StepHeader "Step 2 - Validate"
& "$PSScriptRoot\Step2-Validate.ps1" -StepNumber 2 -OutputDir $RunOutputDir -BasePath $BasePath -DataPath $DataPath -ConfigPath $ConfigPath

Write-Log "E2E pipeline completed."
Write-Log "Outputs saved to: $RunOutputDir"
