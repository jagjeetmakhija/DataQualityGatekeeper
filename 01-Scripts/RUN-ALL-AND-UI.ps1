# =============================================================
# RUN-ALL-AND-UI.ps1: Unified Pipeline and UI Launcher
# =============================================================
# Purpose: Run the full E2E pipeline, then launch the Flask UI
# Usage: .\RUN-ALL-AND-UI.ps1 -InputFile "DataFiles\sample-data.csv"
# =============================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "DataFiles/sample-data.csv",
    [Parameter(Mandatory=$false)]
    [string]$VenvPath = ".venv"
)

# 1. Run the E2E pipeline
Write-Host "\n═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  🚀 Running E2E Pipeline (RUN-ALL.ps1)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════\n" -ForegroundColor Magenta

$pipelineResult = & (Join-Path $PSScriptRoot "RUN-ALL.ps1") -InputFile $InputFile -VenvPath $VenvPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Pipeline failed. UI will not be started." -ForegroundColor Red
    exit 1
}

# 2. Launch the Flask UI
Write-Host "\n═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  🖥️  Launching Flask UI (app.py)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════\n" -ForegroundColor Magenta

$python = & (Join-Path $PSScriptRoot "..\$VenvPath\Scripts\python.exe") --version
$pythonPath = Join-Path $PSScriptRoot "..\$VenvPath\Scripts\python.exe"

Start-Process -NoNewWindow -FilePath $pythonPath -ArgumentList "04-UI/app.py"
Write-Host "\n🌐 Flask UI started. Visit http://127.0.0.1:5000 in your browser.\n" -ForegroundColor Green
