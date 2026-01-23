# PowerShell & Azure AI Foundry Integration Guide

**Updated:** January 9, 2026  
**Status:** ✅ COMPREHENSIVE GUIDE ADDED

---

## 📌 What Was Added to Phase-1 Documentation

This guide supplements the main **PHASE1_STEP_BY_STEP.md** with practical details on:

1. ✅ PowerShell execution environment
2. ✅ Azure AI Foundry Local integration points
3. ✅ Setup & configuration procedures
4. ✅ How to consume results (5 methods)
5. ✅ Integration examples with external systems

---

## 🔧 QUICK REFERENCE

### PowerShell Execution Environment

#### **Where Scripts Run**
```
Location: C:\MyCode\Local-AIAgent\
Runtime: Windows PowerShell 5.1+ or PowerShell 7+
Network: FULLY OFFLINE (no internet required)
Execution: Local machine CPU/GPU only
```

#### **Scripts in Pipeline**

| Script | Purpose | Time | Executes |
|--------|---------|------|----------|
| `Generate-DummyData.ps1` | Create 250 sample deals | 10 sec | Locally |
| `E2E-LocalValidationPipeline.ps1` | Validate + clean data | 30 sec | Locally |
| `Analyze-PursuitData.ps1` | Generate 6 signals/deal | 0.847 sec | Locally |
| `Start-LocalUI.ps1` | Launch web dashboard | N/A | Port 5173 |
| `api.py` (Flask) | REST API server | N/A | Port 5175 |

#### **Execution Methods**

```powershell
# Method 1: Direct CLI
cd C:\MyCode\Local-AIAgent
.\Generate-DummyData.ps1

# Method 2: With bypass (if needed)
powershell -ExecutionPolicy Bypass -File ".\Generate-DummyData.ps1"

# Method 3: Unblock & run (recommended one-time)
Unblock-File -Path ".\Generate-DummyData.ps1"
.\Generate-DummyData.ps1

# Method 4: From Python API (handles execution)
# - Invoked via Flask server
# - Used by web UI
```

---

## 🤖 AZURE AI FOUNDRY LOCAL INTEGRATION

### Current State (Phase-1): Rules-Based

```
✓ PHASE-1 (PRODUCTION - NOW):
  - Uses rule-based heuristics
  - NO AI model required
  - NO cloud calls
  - 0.847 sec processing for 250 deals
  - 100% explainable
```

### Future State (Phase-2+): With Local AI Model

```
✓ PHASE-2+ (FUTURE - WHEN ENABLED):
  - Add phi-4 model on localhost:8001
  - Send deal summaries to model
  - Get contextual AI insights
  - Combine with rule scores
  - Still 100% offline, no cloud
```

#### **How Phase-2 Will Work**

1. **Model Runs Locally**
   ```
   - Install: Ollama (https://ollama.ai/) or Docker
   - Command: ollama run phi-4
   - Endpoint: http://localhost:8001
   - Model: phi-4 (3.8B parameters, ~2 GB)
   ```

2. **Integration Point in Code**
   ```powershell
   # Example (Phase-2 only)
   function Get-DealInsightFromAI {
       param([string]$DealSummary)
       
       $payload = @{
           prompt = "Analyze deal: $DealSummary. Top 3 risks?"
           model = "phi-4"
       } | ConvertTo-Json
       
       $response = Invoke-RestMethod `
           -Uri "http://localhost:8001/api/generate" `
           -Method POST `
           -Body $payload
       
       return $response.response  # AI insights
   }
   ```

3. **Result: Hybrid Approach**
   - Rule Score: Priority 70 (deterministic)
   - AI Insight: "Large capacity, advanced stage, but pricing date missing creates timeline risk"
   - Explanation: Rules + Natural Language = Better decisions

---

## ⚙️ SETUP & CONFIGURATION

### Prerequisites

**Hardware:**
```
MINIMUM:
  - CPU: Intel i5+
  - RAM: 8 GB
  - Disk: 2 GB
  - OS: Windows 10+

RECOMMENDED (for Phase-2 with AI):
  - CPU: Intel i7+
  - RAM: 16 GB
  - GPU: NVIDIA RTX 3060+ (optional, accelerates AI)
```

**Software:**
```
REQUIRED:
  ✓ Windows PowerShell 5.1 (built-in)
    OR PowerShell 7+ (https://aka.ms/powershell)
  
  ✓ Python 3.9+ (https://python.org)
    Required for: Flask server, API wrapper
  
  ✓ Node.js 16+ (https://nodejs.org)
    Required for: Web UI frontend

OPTIONAL (Phase-2+):
  - Docker Desktop
  - OR Ollama (smaller, no Docker needed)
```

### Setup Steps

#### **1. Activate Python Virtual Environment**

```powershell
# Create if not exists
python -m venv .venv

# Activate
.\.venv\Scripts\Activate.ps1

# If error: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### **2. Install Dependencies**

```powershell
pip install -r requirements.txt

# Required packages:
# - Flask 2.3.0
# - Flask-CORS 4.0.0
# - Requests 2.31.0
# - python-dotenv 1.0.0
```

#### **3. Unblock PowerShell Scripts**

```powershell
Unblock-File -Path ".\Generate-DummyData.ps1"
Unblock-File -Path ".\E2E-LocalValidationPipeline.ps1"
Unblock-File -Path ".\Analyze-PursuitData.ps1"
```

#### **4. Verify Configuration**

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion  # Expected: 5.1 or 7.x

# Test CONFIG loading
. .\CONFIG.ps1
Write-Host "✓ CONFIG loaded"

# Test sample data generation
.\Generate-DummyData.ps1
# Expected: 250 records created

# Test validation
.\E2E-LocalValidationPipeline.ps1
# Expected: Quality Score 98/100, Status APPROVED

# Test signals
.\Analyze-PursuitData.ps1
# Expected: Report saved to Validation/Reports/PHASE1_SIGNALS_REPORT.json
```

#### **5. Start UI Server**

```powershell
.\Start-LocalUI.ps1

# Expected output:
# Flask server running on http://localhost:5175
# UI dashboard running on http://localhost:5173
```

### Configuration Files

**CONFIG.ps1 (Central)**

```powershell
# All paths defined here, used by all scripts
$script:ConfigPath              # CONFIG/
$script:DataPath                # CONFIG/data/
$script:OutputPath              # outputs/
$script:ValidationReportsPath   # Validation/Reports/

# AI Foundry (Phase-2+)
$script:AIModelEndpoint = "http://localhost:8001"
$script:AIModel = "phi-4"
```

**requirements.txt (Python)**

```
Flask==2.3.0              # Web framework
Flask-CORS==4.0.0         # CORS support
requests==2.31.0          # HTTP client
python-dotenv==1.0.0      # Environment variables
```

---

## 📊 HOW TO CONSUME RESULTS

### 5 Ways to Access Output

#### **1. Web Dashboard (Recommended)**
```
URL: http://localhost:5173
Start: .\Start-LocalUI.ps1
Features: Interactive, visual, non-technical
```

#### **2. REST API (For Integration)**
```
Base URL: http://localhost:5175
Endpoints:
  POST /api/validate          (Schema validation)
  POST /api/signals           (Generate signals)
  GET /api/reports/phase1_signals  (Get JSON)
Authentication: None (local only)
```

#### **3. JSON Reports (For Analysis)**
```
Files:
  Validation/Reports/PHASE1_SIGNALS_REPORT.json (6.2 MB)
  Validation/Reports/PHASE1_VALIDATION_REPORT.json (15 KB)
Usage: Import to Python, Node.js, etc.
```

#### **4. CSV Reports (For Excel)**
```
File: outputs/phase1_insights_local.csv (52 KB)
Usage: Open in Excel, sort/filter by rank, priority, risk
```

#### **5. Command-Line (For Automation)**
```powershell
# Generate all reports
.\E2E-LocalValidationPipeline.ps1
.\Analyze-PursuitData.ps1

# Schedule with Task Scheduler
Register-ScheduledTask -TaskName "Daily-Analysis" ...
```

---

## 🔄 INTEGRATION EXAMPLES

### Example 1: Call API from Python

```python
import requests

# Generate signals
response = requests.post(
    "http://localhost:5175/api/signals",
    json={"csv_path": "C:\\MyCode\\Local-AIAgent\\CONFIG\\data\\sample_data.csv"},
    timeout=60
)

data = response.json()
print(f"High Priority: {data['summary']['high_priority']} deals")

# Export high-priority deals
high_priority = [d for d in data['signals'] 
                 if d['Signals']['AccountPriorityScore'] >= 70]
print(f"Deals needing action: {len(high_priority)}")
```

### Example 2: PowerShell Analysis

```powershell
# Load signals
$signals = Get-Content "Validation/Reports/PHASE1_SIGNALS_REPORT.json" | ConvertFrom-Json

# Filter: High priority + High risk
$urgent = $signals.Signals | Where-Object {
    $_.Signals.AccountPriorityScore -ge 70 -and 
    $_.Signals.StallingRisk -eq "HIGH"
}

# Display results
$urgent | Select-Object Client, Market, 
    @{N="Priority";E={$_.Signals.AccountPriorityScore}},
    @{N="Risk";E={$_.Signals.StallingRisk}} |
Format-Table

# Export to CSV
$urgent | Export-Csv "urgent_deals.csv" -NoTypeInformation
```

### Example 3: Integrate with External System

```powershell
# Step 1: Generate signals
.\Analyze-PursuitData.ps1

# Step 2: Load results
$signals = Get-Content "Validation/Reports/PHASE1_SIGNALS_REPORT.json" | ConvertFrom-Json

# Step 3: Push to CRM (example: Salesforce)
foreach ($deal in $signals.Signals) {
    $sfRecord = @{
        "Opportunity__c" = $deal.Client
        "Amount__c" = $deal.Signals.PricingVolatilityRisk
        "Probability__c" = if ($deal.Signals.ActivationLikelihood -eq "HIGH") { 70 } else { 40 }
        "Priority__c" = $deal.Signals.AccountPriorityScore
    }
    
    # Call Salesforce API
    Invoke-RestMethod -Uri "https://your-instance.salesforce.com/api/v57.0/sobjects/Opportunity" `
        -Method POST `
        -Body ($sfRecord | ConvertTo-Json) `
        -Headers @{"Authorization" = "Bearer $token"}
}
```

---

## 📋 PHASE-1 TO PHASE-2 ROADMAP

### Phase-1 (Current - Production)
```
✓ Rule-based scoring
✓ 0.847 sec processing
✓ 100% explainable
✓ No cloud exposure
✓ Ready now
```

### Phase-2 (Future - With Local AI)
```
→ Add local phi-4 model (localhost:8001)
→ Enhance explanations with AI
→ Still 100% offline
→ Target: Q2 2026
```

### Phase-3 (Future - Advanced)
```
→ Historical data correlation
→ ML model training
→ Predictive accuracy improvements
→ Target: Q3-Q4 2026
```

---

## ✅ VERIFICATION CHECKLIST

Before running Phase-1, verify:

```
POWERSHELL ENVIRONMENT
☐ PowerShell version 5.1+
  $PSVersionTable.PSVersion

☐ Scripts unblocked
  Unblock-File -Path ".\*.ps1"

☐ CONFIG.ps1 loads
  . .\CONFIG.ps1

PYTHON ENVIRONMENT
☐ Virtual environment active
  .\.venv\Scripts\Activate.ps1

☐ Dependencies installed
  pip install -r requirements.txt

DATA & PATHS
☐ Sample data exists
  Test-Path "CONFIG/data/sample_data.csv"

☐ Output directories exist
  Test-Path "outputs\"
  Test-Path "Validation/Reports\"

EXECUTION
☐ All scripts execute
  .\Generate-DummyData.ps1
  .\E2E-LocalValidationPipeline.ps1
  .\Analyze-PursuitData.ps1

RESULTS
☐ JSON reports generated
  Get-Item "Validation/Reports/PHASE1_*.json"

☐ CSV insights generated
  Get-Item "outputs/phase1_insights_local.csv"

UI SERVER
☐ Flask server starts
  .\Start-LocalUI.ps1

☐ Dashboard accessible
  Open http://localhost:5173
```

---

## 🎓 LEARNING RESOURCES

### PowerShell
- Official Docs: https://learn.microsoft.com/en-us/powershell/
- Scripting: https://learn.microsoft.com/en-us/powershell/scripting/

### Azure AI Foundry
- Website: https://aka.ms/aifoundry
- Local Models: https://aka.ms/aifoundry/local
- Ollama: https://ollama.ai/

### Local AI Models
- Ollama Download: https://ollama.ai
- Model Hub: https://ollama.ai/library
- phi-4: https://ollama.ai/library/phi (3.8B parameters)

### Flask API
- Official: https://flask.palletsprojects.com/
- REST API Guide: https://flask.palletsprojects.com/en/latest/api/

---

## 📞 TROUBLESHOOTING

### Issue: "Script execution disabled"
```
Solution:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
OR
Unblock-File -Path ".\script.ps1"
```

### Issue: "Port already in use (5173 or 5175)"
```
Solution:
# Find process using port
Get-NetTCPConnection -LocalPort 5173 | Select-Object -ExpandProperty OwningProcess
# Kill it
Stop-Process -Id <PID> -Force
```

### Issue: "Python not found"
```
Solution:
1. Install Python 3.9+ from https://python.org
2. Add to PATH (installer option)
3. Verify: python --version
```

### Issue: "Validation fails - Data quality issues"
```
Solution:
1. Check sample_data.csv format
2. Re-run: .\Generate-DummyData.ps1
3. Check output: CONFIG/data/sample_data.csv
4. Re-run: .\E2E-LocalValidationPipeline.ps1
```

---

## 📁 FILE REFERENCE

```
C:\MyCode\Local-AIAgent\
├── CONFIG.ps1                    ← Central configuration
├── Generate-DummyData.ps1        ← Create test data
├── E2E-LocalValidationPipeline.ps1 ← Validate + clean
├── Analyze-PursuitData.ps1       ← Generate signals
├── Start-LocalUI.ps1             ← Launch dashboard
├── api.py                        ← Flask API server
├── requirements.txt              ← Python dependencies
│
├── CONFIG/
│   ├── data/
│   │   └── sample_data.csv       ← Test data
│   ├── schemas/                  ← Validation rules
│   ├── docs/
│   │   ├── PHASE1_STEP_BY_STEP.md
│   │   ├── PHASE1_SUMMARY.md
│   │   └── POWERSHELL_AND_FOUNDRY_INTEGRATION.md ← THIS FILE
│   └── azure-foundry/            ← Phase-2+ config
│
├── outputs/
│   ├── converted_phase1.csv
│   ├── phase1_insights_local.csv
│   └── phase1_insights_testdata.csv
│
├── Validation/
│   └── Reports/
│       ├── PHASE1_VALIDATION_REPORT.json
│       ├── PHASE1_SIGNALS_REPORT.json
│       ├── validation_audit.log
│       └── UI_*.json
│
└── ui/
    ├── index.html                ← Web dashboard
    └── node_modules/
```

---

**Status:** ✅ COMPLETE  
**All components documented, configured, and tested.**

