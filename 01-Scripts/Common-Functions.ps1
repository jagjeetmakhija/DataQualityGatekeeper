Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
  param(
    [Parameter(Mandatory=$true)][string]$Message,
    [ValidateSet("INFO","WARN","ERROR")][string]$Level = "INFO"
  )
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$ts][$Level] $Message"
}

function Write-StepHeader {
  param([Parameter(Mandatory=$true)][string]$Title)
  $line = ("=" * 80)
  Write-Host ""
  Write-Host $line -ForegroundColor Cyan
  Write-Host " $Title" -ForegroundColor Cyan
  Write-Host $line -ForegroundColor Cyan
  Write-Host ""
}

function Ensure-Directory {
  param([Parameter(Mandatory=$true)][string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw "Ensure-Directory received empty Path."
  }
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Get-ProjectRoot {
  # This file lives in: <root>\01-Scripts\
  return (Split-Path -Parent $PSScriptRoot)
}

function Get-ResolvedPathOrDefault {
  param(
    [Parameter(Mandatory=$true)][AllowEmptyString()][string]$Value,
    [Parameter(Mandatory=$true)][string]$DefaultValue
  )
  if (-not [string]::IsNullOrWhiteSpace($Value)) { return $Value }
  return $DefaultValue
}

function New-RunOutputDir {
  param(
    [Parameter(Mandatory=$true)][string]$OutputsRoot,
    [string]$Prefix = "Output_"
  )

  Ensure-Directory -Path $OutputsRoot

  $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $runDir = Join-Path $OutputsRoot "$Prefix$timestamp"

  Ensure-Directory -Path $runDir
  return $runDir
}
