@echo off
REM Start Phase-1 Local Validation API Server
cd /d "%~dp0"

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7+ from https://www.python.org/
    pause
    exit /b 1
)

REM Check if Flask is installed
python -c "import flask" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing required Python packages...
    pip install flask flask-cors
)

REM Start the API server
echo.
echo ========================================
echo Starting Phase-1 API Server
echo ========================================
echo.
echo API will be available at: http://localhost:8080
echo UI will be available at: http://localhost:5173
echo.
echo Press Ctrl+C to stop the server
echo.

python api.py
