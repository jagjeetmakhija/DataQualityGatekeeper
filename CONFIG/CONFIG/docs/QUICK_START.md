# Quick Start: PowerShell & Azure AI Foundry Integration

**Print this page or save to desktop for quick reference**

---

## 🚀 QUICK START (5 MINUTES)

### Step 1: Prepare Environment
```powershell
cd C:\MyCode\Local-AIAgent

# Activate Python venv
.\.venv\Scripts\Activate.ps1

# Unblock scripts (one-time)
Unblock-File -Path ".\*.ps1"
```

### Step 2: Generate Sample Data
```powershell
.\Generate-DummyData.ps1
# Output: 250 records in CONFIG/data/sample_data.csv
```

### Step 3: Validate & Clean
```powershell
.\E2E-LocalValidationPipeline.ps1
# Output: PHASE1_VALIDATION_REPORT.json (Status: APPROVED)
```

### Step 4: Generate Signals
```powershell
.\Analyze-PursuitData.ps1
# Output: PHASE1_SIGNALS_REPORT.json (1,500 signals for 250 deals)
```

### Step 5: View Results
```powershell
# Option A: Web Dashboard
.\Start-LocalUI.ps1
# Open browser: http://localhost:5173

# Option B: View JSON
Get-Content "Validation/Reports/PHASE1_SIGNALS_REPORT.json" | ConvertFrom-Json | Format-List

# Option C: View CSV
Import-Csv "outputs/phase1_insights_local.csv" | Format-Table
```

---

## 📍 WHERE POWERSHELL SCRIPTS RUN

```
Location: C:\MyCode\Local-AIAgent\
Environment: Windows PowerShell 5.1+ or PowerShell 7+
Network: FULLY OFFLINE (no cloud)
Execution: Local CPU/GPU only
```

### Scripts Overview

| Script | Purpose | Runtime | Start |
|--------|---------|---------|-------|
| Generate-DummyData.ps1 | Create 250 sample deals | 10 sec | .\Generate-DummyData.ps1 |
| E2E-LocalValidationPipeline.ps1 | Validate + clean data | 30 sec | .\E2E-LocalValidationPipeline.ps1 |
| Analyze-PursuitData.ps1 | Generate 6 signals per deal | 0.847 sec | .\Analyze-PursuitData.ps1 |
| Start-LocalUI.ps1 | Launch web dashboard | Continuous | .\Start-LocalUI.ps1 |

---

## 🤖 AZURE AI FOUNDRY: WHERE & HOW

### Phase-1 (Current)
```
Status: LIVE
Model: Rule-based heuristics (NO AI model needed)
Processing Time: 0.847 sec for 250 deals
Explainability: 100%
Cloud Calls: 0
```

### Phase-2+ (Future)
```
When: Will add local AI model (target Q2 2026)
Model: phi-4 (3.8B parameters)
Endpoint: http://localhost:8001
Installation: Ollama (https://ollama.ai) or Docker
Speed: <100ms per deal (GPU-accelerated)
```

---

## ⚙️ HOW TO CONFIGURE (3 MINUTES)

### 1. Edit CONFIG.ps1
```powershell
# Central configuration file
# Located: C:\MyCode\Local-AIAgent\CONFIG.ps1

# Already configured paths:
$script:ConfigPath = "CONFIG\"
$script:DataPath = "CONFIG\data\"
$script:OutputPath = "outputs\"
$script:ValidationReportsPath = "Validation\Reports\"

# Future (Phase-2) - uncomment when ready:
# $script:AIModelEndpoint = "http://localhost:8001"
# $script:AIModel = "phi-4"
```

### 2. Install Python Dependencies
```powershell
pip install -r requirements.txt
# Installs: Flask, CORS, Requests, python-dotenv
```

### 3. Verify Setup
```powershell
# Test PowerShell config
. .\CONFIG.ps1
Write-Host "✓ CONFIG loaded: $script:ConfigPath"

# Test data generation
.\Generate-DummyData.ps1
# Should create: CONFIG/data/sample_data.csv

# Test validation
.\E2E-LocalValidationPipeline.ps1
# Should show: Quality Score 98/100, Status APPROVED
```

---

## 🔌 HOW TO CONSUME RESULTS (5 WAYS)

### 1️⃣ Web Dashboard
```
URL: http://localhost:5173
Start: .\Start-LocalUI.ps1
Best for: Non-technical users, visual analysis
```

### 2️⃣ REST API
```
Base URL: http://localhost:5175
Endpoint: POST /api/signals
Returns: JSON with all signals and reasoning
```

**Example PowerShell:**
```powershell
$response = Invoke-RestMethod `
    -Uri "http://localhost:5175/api/signals" `
    -Method POST `
    -Body (@{ csv_path = "CONFIG/data/sample_data.csv" } | ConvertTo-Json)

$response.summary  # Shows: high_priority, medium_priority, low_priority
```

### 3️⃣ JSON Reports
```
File 1: Validation/Reports/PHASE1_SIGNALS_REPORT.json (6.2 MB)
        Contains: 250 deals × 6 signals + reasoning

File 2: Validation/Reports/PHASE1_VALIDATION_REPORT.json (15 KB)
        Contains: Quality metrics, schema validation

Usage:
$signals = Get-Content "Validation/Reports/PHASE1_SIGNALS_REPORT.json" | ConvertFrom-Json
```

### 4️⃣ CSV for Excel
```
File: outputs/phase1_insights_local.csv (52 KB)
Columns: Rank, Client, Market, Priority_Score, Likelihood, Risk, Completeness, Actions

Usage:
Import-Csv "outputs/phase1_insights_local.csv" | Format-Table
# Then open in Excel
```

### 5️⃣ Command-Line / Automation
```powershell
# Scheduled daily analysis
Register-ScheduledTask -TaskName "Daily-Analysis" `
    -Action (New-ScheduledTaskAction -Execute powershell `
             -Argument "-File C:\MyCode\Local-AIAgent\Analyze-PursuitData.ps1") `
    -Trigger (New-ScheduledTaskTrigger -Daily -At 8:00AM)
```

---

## 📊 OUTPUT FILES LOCATION

```
C:\MyCode\Local-AIAgent\
│
├── Validation/Reports/
│   ├── PHASE1_VALIDATION_REPORT.json      ← Schema validation + quality
│   ├── PHASE1_SIGNALS_REPORT.json         ← All signals (6.2 MB)
│   ├── validation_audit.log               ← Complete audit trail
│   └── UI_*.json                          ← UI snapshots
│
└── outputs/
    ├── phase1_insights_local.csv          ← Ranked deals (CSV)
    ├── converted_phase1.csv               ← Cleaned data
    └── phase1_insights_testdata.csv       ← Test variant
```

---

## 🚨 COMMON ISSUES & FIXES

| Issue | Fix |
|-------|-----|
| "Script execution disabled" | `Unblock-File -Path ".\*.ps1"` |
| "Port 5173 already in use" | `Stop-Process -Id (Get-NetTCPConnection -LocalPort 5173 \| % OwningProcess) -Force` |
| "Python not found" | Install from https://python.org, add to PATH |
| "Validation fails" | Re-run `.\Generate-DummyData.ps1` to refresh sample data |
| "No signals generated" | Check `CONFIG/data/sample_data.csv` exists |
| "API connection refused" | Ensure Flask server running: `.\Start-LocalUI.ps1` |

---

## 🔐 SECURITY CHECKLIST

```
✅ Offline Execution
   - No internet required
   - No cloud API calls
   - No telemetry

✅ Data Residency
   - All files in: C:\MyCode\Local-AIAgent\
   - Nothing uploaded to cloud
   - Local machine only

✅ No Cost Surprises
   - CPU-based execution
   - No per-API charges
   - Fully predictable

✅ Explainable
   - Every signal has reasoning
   - No black-box logic
   - Fully auditable
```

---

## 📞 KEY COMMANDS

```powershell
# Setup
cd C:\MyCode\Local-AIAgent
.\.venv\Scripts\Activate.ps1
Unblock-File -Path ".\*.ps1"
pip install -r requirements.txt

# Generate Data
.\Generate-DummyData.ps1

# Validate
.\E2E-LocalValidationPipeline.ps1

# Analyze
.\Analyze-PursuitData.ps1

# View Results
Get-Content "Validation/Reports/PHASE1_SIGNALS_REPORT.json" | ConvertFrom-Json | Format-List

# Start UI
.\Start-LocalUI.ps1

# Test API
Invoke-RestMethod -Uri "http://localhost:5175/api/health"

# Stop UI (in Terminal)
Ctrl+C
```

---

## 📖 FULL DOCUMENTATION

For comprehensive details, see:

1. **PHASE1_STEP_BY_STEP.md**
   - Complete flow with inputs/process/outputs
   - Signal definitions & scoring logic
   - Example calculations

2. **POWERSHELL_AND_FOUNDRY_INTEGRATION.md**
   - PowerShell execution details
   - Azure AI Foundry setup (Phase-2+)
   - Integration examples

3. **PHASE1_SUMMARY.md**
   - Technical implementation overview
   - Architecture details
   - Feature list

---

## ✅ YOU'RE READY!

```
Environment: ✅ Configured
Scripts: ✅ Unblocked
Data: ✅ Sample ready
Dependencies: ✅ Installed
Results: ✅ Ready to generate

Next: Run .\Analyze-PursuitData.ps1
```

---

**Last Updated:** January 9, 2026  
**Status:** ✅ PRODUCTION READY

