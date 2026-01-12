# 🚀 QUICK START GUIDE

## ⚡ Get Running in 5 Minutes

### Prerequisites
- ✅ Windows 10/11
- ✅ PowerShell 7+ (or Windows PowerShell 5.1)
- ✅ Python 3.10 or higher

---

## Step 1️⃣: Setup (One-Time, 2 minutes)

Open PowerShell in the project directory:

```powershell
# Navigate to project
cd C:\MyCode\Local-AIAgent\Phase1-LocalInsights

# Create virtual environment (OPTIONAL)
py -3.11 -m venv .venv311

# Activate it (OPTIONAL)
.\.venv311\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

**Expected output:**
```
Successfully installed pandas-2.1.4 openpyxl-3.1.2 flask-3.0.0 ...
```

---

## Step 2️⃣: Test with Sample Data (30 seconds)

```powershell
cd 01-Scripts
.\RUN-ALL-AND-UI.ps1 -InputFile "..\DataFiles\sample-data.csv"
```

**What happens:**
- Cleans and normalizes your data (auto-fix)
- Validates schema and types
- Launches the Flask UI for results

**Troubleshooting:**
- If you see an error about missing cleaned-data.csv, check that your input file exists and is readable.
- The script now checks and throws a clear error if cleaned-data.csv is not created.
✅ STEP 2 : SCHEMA VALIDATION (GATE)
✅ Overall Status: PASS
✅ STEP 2 COMPLETED SUCCESSFULLY - VALIDATION PASSED

🎉 PIPELINE COMPLETED SUCCESSFULLY
```

---

## Step 3️⃣: View Results (30 seconds)

```powershell
# Start the UI
cd ..\04-UI
python app.py
```

**Open your browser:**
```
http://localhost:5000
```

You'll see:
- 🧹 Auto-fix summary
- ✅ Validation results (PASS/FAIL)
- 📊 Data quality metrics
- 📥 Download buttons for all outputs

---

## Step 4️⃣: Use Your Own Data

```powershell
cd 01-Scripts
.\RUN-ALL.ps1 -InputFile "C:\Your\Path\To\data.csv"
```

**Minimum required columns:**
- AccountName
- OpportunityID
- Stage
- CreatedDate
- EstimatedValue

**Don't worry if column names don't match exactly** - the auto-fix step will help normalize them!

---

## 📁 Where Are My Outputs?

All outputs saved to: **`05-Outputs/`**

```
05-Outputs/
├── autofix-audit/
│   ├── cleaned-data.csv              ← Cleaned data
│   ├── autofix-audit-*.json          ← What was fixed
│   └── traceability-*.csv            ← Audit trail
│
└── validation-reports/
    ├── validation-report-*.json      ← PASS/FAIL status
    └── traceability-*.csv            ← Validation audit
```

---

## ⚠️ Common Issues

### Issue: "Python not found"
```powershell
# Check Python installation
python --version

# If not installed, download from:
# https://www.python.org/downloads/
```

### Issue: "Validation FAILED"
```
❌ VALIDATION FAILED
  🔧 HOW TO FIX:
     • Remove 2 duplicate OpportunityIDs
     • Fix 3 rows with invalid dates
```

**Solution:**
1. Read the error messages
2. Fix your source data
3. Re-run the pipeline

### Issue: "Module not found"
```powershell
# Make sure dependencies are installed
pip install -r requirements.txt

# Or manually:
pip install pandas openpyxl flask jsonschema python-dateutil
```

---

## 🎨 PowerShell Script Reference

| Script | Purpose | Command |
|--------|---------|---------|
| **RUN-ALL.ps1** | Run complete pipeline | `.\RUN-ALL.ps1 -InputFile "path\to\data.csv"` |
| **Step1-AutoFix.ps1** | Clean data only | `.\Step1-AutoFix.ps1 -InputFile "data.csv"` |
| **Step2-Validate.ps1** | Validate only | `.\Step2-Validate.ps1 -InputFile "cleaned-data.csv"` |

---

## 📊 Understanding the Console Output

### Icons Guide

| Icon | Meaning |
|------|---------|
| ✅ | Success - everything OK |
| ❌ | Error - action required |
| ⚠️ | Warning - review recommended |
| ℹ️ | Information - no action needed |
| ⏳ | Processing - please wait |
| 📊 | Metric/statistic |
| 🔍 | Checking/validating |

### Example Console Flow

```powershell
═══════════════════════════════════════════════════════════════
  🧹 STEP 1 : AUTO-FIX DATA CLEANING
═══════════════════════════════════════════════════════════════

  📊 InputRowCount : 500

  🔍 Auto-Fix Transformations Applied:
     ✅ AUTOFIX-001: Trim Headers and Values
        Rows Affected: 500
     ✅ AUTOFIX-002: Normalize Whitespace
        Rows Affected: 485
     ⚠️  AUTOFIX-003: Standardize Dates
        Rows Affected: 10
        Details: 10 dates converted from MM/DD/YYYY

✅ STEP 1 COMPLETED SUCCESSFULLY

  📁 Output Files:
     • Cleaned Data: 05-Outputs\autofix-audit\cleaned-data.csv
     • Auto-Fix Audit: 05-Outputs\autofix-audit\autofix-audit-20260110-142315.json
     • Traceability Matrix: 05-Outputs\autofix-audit\traceability-20260110-142315.csv
```

---

## 🔍 Explore the Outputs

### Auto-Fix Audit (JSON)

```powershell
# Open the audit report
code 05-Outputs\autofix-audit\autofix-audit-*.json
```

**Shows:**
- What transformations were applied
- How many rows were affected
- Before/after counts

### Traceability Matrix (CSV)

```powershell
# Open in Excel
start 05-Outputs\autofix-audit\traceability-*.csv
```

**Shows:**
- File processed
- Rule applied
- Rows passed/failed
- Outcome (PASS/FAIL/WARNING)

### Validation Report (JSON)

```powershell
# Open validation results
code 05-Outputs\validation-reports\validation-report-*.json
```

**Shows:**
- Overall status (PASS/FAIL)
- Error count
- Warning count
- Detailed rule results
- Fix instructions (if failed)

---

## 🎯 Next Steps

### ✅ Phase-1 Complete - What's Working:
1. ✅ Data auto-fix and cleaning
2. ✅ Schema validation (GATE)
3. ✅ Complete audit trail
4. ✅ Executive dashboard
5. ✅ Full traceability

### 🚧 Coming in Phase-2:
- AI model integration for scoring
- Predictive insights generation
- Risk/opportunity ranking
- Success metrics

---

## 📚 Full Documentation

| Document | Purpose |
|----------|---------|
| **[README.md](../README.md)** | Complete overview |
| **[ARCHITECTURE.md](../06-Documentation/ARCHITECTURE.md)** | System design |
| **[EXECUTION-FLOW.md](../06-Documentation/EXECUTION-FLOW.md)** | Detailed steps |
| **[TRACEABILITY-MATRIX.md](../06-Documentation/TRACEABILITY-MATRIX.md)** | Audit guide |
| **[CX-TRUST-CHECKLIST.md](../06-Documentation/CX-TRUST-CHECKLIST.md)** | Security validation |

---

## 🔒 Security Reminder

✅ **100% Localhost** - No cloud, no external APIs  
✅ **100% Offline** - Internet not required (after setup)  
✅ **100% Explainable** - Every decision documented  
✅ **0% Cost** - Zero cloud charges

---

## 📞 Need Help?

**Check these in order:**

1. **Error messages in console** - Usually self-explanatory
2. **Audit logs in `05-Outputs/`** - Complete execution details
3. **[EXECUTION-FLOW.md](../06-Documentation/EXECUTION-FLOW.md)** - Step-by-step troubleshooting
4. **[TRACEABILITY-MATRIX.md](../06-Documentation/TRACEABILITY-MATRIX.md)** - Understanding the audit trail

---

## ✅ Success Checklist

After running the pipeline, you should have:

- [ ] ✅ Console shows "PIPELINE COMPLETED SUCCESSFULLY"
- [ ] ✅ Cleaned data file exists
- [ ] ✅ Auto-fix audit report generated
- [ ] ✅ Validation report shows PASS
- [ ] ✅ Traceability matrices created
- [ ] ✅ UI displays results at http://localhost:5000

**If all checked, you're ready to go! 🎉**

---

**Version:** 1.0  
**Last Updated:** 2026-01-10  
**Status:** Ready for Testing
