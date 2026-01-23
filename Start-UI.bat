@echo off
REM Change to script directory
cd /d "%~dp0"

REM Start the UI server using PowerShell
echo Starting UI Server...
start powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-LocalUI.ps1"
timeout /t 2 /nobreak >nul
start http://localhost:5173/
echo Server started at http://localhost:5173/
echo Opening browser...
start http://localhost:5175/

echo.
echo Server is running. Close the PowerShell window to stop it.
pause
