# 📦 Phase-1 Local Insights System

## 🎯 Overview

**Complete Phase-1 solution for generating explainable, directional predictive insights using Azure AI Foundry Local (localhost model).**

✅ **Simple to understand**  
✅ **Easy to maintain**  
✅ **Fully local (offline-capable)**  
✅ **Secure, explainable, and auditable**

---

## 🚀 Quick Start (5 Minutes)
### Step 1: Setup Environment (One-Time)

```powershell
# Navigate to project directory
cd LocalAIAgent-Phase1

# Create virtual environment (recommended)
py -3.11 -m venv .venv311
.\.venv311\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Prepare Your Data

Place your CSV/Excel file in the DataFiles folder:
```
DataFiles\sample-data.csv
```

**Minimum columns required:**
- AccountName, OpportunityID, Stage, CreatedDate, EstimatedValue

### Step 3: Run the Unified Pipeline & UI

```powershell
cd 01-Scripts
.\RUN-ALL-AND-UI.ps1 -InputFile "..\DataFiles\sample-data.csv"
```

**What happens:**
- Step 1: Cleans and normalizes your data (auto-fix)
- Step 2: Validates schema and types
- Step 3: Launches the Flask UI for results

**Troubleshooting:**
- If you see an error about missing cleaned-data.csv, check that your input file exists and is readable.
- The script now checks and throws a clear error if cleaned-data.csv is not created.

### Step 4: View Results

```powershell
cd 04-UI
python app.py
```

Open browser: **http://localhost:5000**

---

## 📁 Project Structure

```
Phase1-LocalInsights/
├── 01-Scripts/           # PowerShell execution scripts
│   ├── RUN-ALL.ps1       # ⭐ Master script (run this!)
│   ├── Step1-AutoFix.ps1
│   ├── Step2-Validate.ps1
│   └── Common-Functions.ps1
│
├── 02-Schema/            # Data validation rules
│   ├── schema.json
│   ├── allowed-values.json
│   └── validation-rules.json
│
├── 03-Modules/           # Python processing modules
│   ├── auto_fixer.py
│   └── validator.py
│
├── 04-UI/                # Localhost dashboard
│   ├── app.py            # Flask app (run this to view results)
│   └── templates/
│       └── dashboard.html
│
├── 05-Outputs/           # All generated reports
│   ├── autofix-audit/
│   ├── validation-reports/
│   └── traceability/
│
└── 06-Documentation/     # Complete documentation
    ├── ARCHITECTURE.md   # System design
    ├── EXECUTION-FLOW.md # Step-by-step guide
    ├── TRACEABILITY-MATRIX.md
    └── CX-TRUST-CHECKLIST.md
```

---

## 📊 What Gets Generated?

### After Running the Pipeline

| Output | Location | Format | Purpose |
|--------|----------|--------|---------|
| **Cleaned Data** | `05-Outputs/autofix-audit/cleaned-data.csv` | CSV | Data after auto-fix |
| **Auto-Fix Audit** | `05-Outputs/autofix-audit/autofix-audit-*.json` | JSON | All transformations applied |
| **Validation Report** | `05-Outputs/validation-reports/validation-*.json` | JSON | PASS/FAIL status + details |
| **Traceability Matrix** | `05-Outputs/*/traceability-*.csv` | CSV | Complete audit trail |
| **Execution Logs** | `05-Outputs/*/step*-audit-*.json` | JSON | Detailed run metadata |

---

## 🎨 Pipeline Flow

```
📂 Input Data (CSV/Excel)
    ↓
🧹 Step 1: Auto-Fix
    • Trim whitespace
    • Normalize casing
    • Standardize dates
    • Coerce numeric fields
    • Remove empty rows
    ↓
✅ Step 2: Validation (GATE)
    • Check required columns
    • Validate data types
    • Enforce allowed values
    • Check null thresholds
    • ❌ FAIL → STOP with fix instructions
    • ✅ PASS → Continue
    ↓
📊 Step 3: Quality Check
    • Analyze completeness
    • Detect anomalies
    • Identify outliers
    ↓
💾 All outputs saved locally
    ↓
🖥️ View in localhost UI
```

---

## 🔧 Key Features

### ✅ Fully Offline
- No cloud APIs
- No external connections
- No telemetry
- Internet not required after setup

### ✅ Explainable & Auditable
- Every transformation documented
- Complete traceability matrix
- Clear "why" for every decision
- No black-box logic

### ✅ Security & Trust
- 100% localhost execution
- No data leakage
- No cost surprises (zero cloud charges)
- CX data stays confidential

### ✅ Easy to Use
- Simple PowerShell scripts
- Executive-friendly UI
- Clear error messages
- Step-by-step documentation

---

## 📋 Example Usage

### Scenario 1: New Dataset

```powershell
# First time with a new dataset
cd 01-Scripts
.\RUN-ALL.ps1 -InputFile "C:\Data\new-opportunities.csv"

# If validation fails, fix the data and re-run
.\Step1-AutoFix.ps1 -InputFile "C:\Data\new-opportunities.csv"
.\Step2-Validate.ps1 -InputFile "05-Outputs\autofix-audit\cleaned-data.csv"
```

### Scenario 2: View Previous Results

```powershell
# Start UI to view existing results
cd 04-UI
python app.py
# Open: http://localhost:5000
```

### Scenario 3: Debugging a Failure

```powershell
# Check the audit logs
code 05-Outputs\validation-reports\validation-report-*.json

# Review traceability matrix
code 05-Outputs\validation-reports\traceability-*.csv

# Fix data and re-run
.\RUN-ALL.ps1 -InputFile "C:\Data\fixed-data.csv"
```

---

## 🔍 Understanding Outputs

### Traceability Matrix (CSV)

```csv
Timestamp,FileName,RuleID,RuleName,RowsProcessed,RowsPassed,RowsFailed,Outcome
2026-01-10 14:23:15,data.csv,AUTOFIX-001,Trim Headers,500,500,0,PASS
2026-01-10 14:23:22,data.csv,VAL-002,Data Types,495,490,5,WARNING
```

**What this shows:**
- ✅ Which file was processed
- 🔧 Which rules were applied
- 📊 How many rows passed/failed
- 🎯 Final outcome (PASS/FAIL/WARNING)

### Validation Report (JSON)

```json
{
  "overallStatus": "PASS",
  "summary": {
    "errorCount": 0,
    "warningCount": 2
  },
  "rules": [...]
}
```

**Key fields:**
- `overallStatus`: PASS or FAIL (determines if processing continues)
- `errorCount`: Critical issues (must be 0 to proceed)
- `warningCount`: Non-critical issues (review but can continue)

---

## ⚠️ Troubleshooting

### "Python not found"
```powershell
# Activate virtual environment
.\.venv311\Scripts\Activate.ps1

# Or install Python 3.10+
# Download from: https://www.python.org/downloads/
```

### "Validation FAILED"
```
❌ VALIDATION FAILED - PROCESSING STOPPED
  🔧 HOW TO FIX:
     • Remove 2 duplicate OpportunityIDs
```
**Solution:** Fix the source data based on instructions, then re-run Step 1.

### "Input file not found"
```powershell
# Use absolute path
.\RUN-ALL.ps1 -InputFile "C:\Full\Path\To\data.csv"
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[ARCHITECTURE.md](06-Documentation/ARCHITECTURE.md)** | System design and components |
| **[EXECUTION-FLOW.md](06-Documentation/EXECUTION-FLOW.md)** | Step-by-step execution guide |
| **[TRACEABILITY-MATRIX.md](06-Documentation/TRACEABILITY-MATRIX.md)** | Audit trail documentation |
| **[CX-TRUST-CHECKLIST.md](06-Documentation/CX-TRUST-CHECKLIST.md)** | Security & trust validation |

---

## 🎯 Success Criteria

### ✅ Pipeline Succeeded If:
1. All PowerShell scripts show: `✅ STEP X COMPLETED SUCCESSFULLY`
2. Validation status = **PASS**
3. All outputs generated in `05-Outputs/`
4. UI shows results at http://localhost:5000

### ❌ Pipeline Failed If:
1. Console shows: `❌ STEP X FAILED`
2. Validation status = **FAIL**
3. Missing output files

**In case of failure:**
- Review error messages in console
- Check audit logs in `05-Outputs/`
- Follow fix instructions in validation report

---

## 🔐 Trust Guarantees

✅ **100% Offline** - No cloud, no external APIs  
✅ **100% Explainable** - Every decision documented  
✅ **0% Cost** - No cloud charges, free Python/PowerShell  
✅ **Full Auditability** - Complete traceability matrix  
✅ **Data Confidentiality** - Everything stays on localhost

---

## 📞 Support

**Need help?**

1. Check **[EXECUTION-FLOW.md](06-Documentation/EXECUTION-FLOW.md)** for step-by-step guidance
2. Review audit logs in `05-Outputs/`
3. Open traceability matrix to see what failed
4. Consult **[ARCHITECTURE.md](06-Documentation/ARCHITECTURE.md)** for system design

---

## 🚦 Quick Commands Reference

```powershell
# Run complete pipeline
cd 01-Scripts
.\RUN-ALL.ps1 -InputFile "C:\Data\data.csv"  # Uses .venv311

# Run individual steps
.\Step1-AutoFix.ps1 -InputFile "C:\Data\data.csv"
.\Step2-Validate.ps1 -InputFile "05-Outputs\autofix-audit\cleaned-data.csv"

# Start UI
cd 04-UI
python app.py

# View outputs
explorer 05-Outputs\
```

---

**🔒 REMINDER: This is a Phase-1 proof-of-value system. All processing is local, explainable, and auditable.**

**Version:** 1.0  
**Last Updated:** 2026-01-10  
**Status:** Ready for CX Testing
