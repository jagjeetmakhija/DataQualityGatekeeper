# 🚀 EXECUTION FLOW - STEP-BY-STEP GUIDE

## 📋 Overview

This guide walks through executing the Phase-1 Local Insights pipeline from start to finish.

**Total Time**: 5-15 minutes (depending on dataset size)  
**Prerequisites**: Python 3.10+, PowerShell 7+  
**Internet**: NOT REQUIRED (100% offline)

---

## 🔧 Initial Setup (One-Time)

### Step 0: Environment Setup

```powershell
# 1. Navigate to project directory
cd C:\MyCode\Local-AIAgent\Phase1-LocalInsights

# 2. Create Python virtual environment (OPTIONAL but recommended)
python -m venv .venv

# 3. Activate virtual environment
.\.venv\Scripts\Activate.ps1

# 4. Install dependencies
pip install pandas openpyxl flask jsonschema python-dateutil

# 5. Verify installation
python --version
pip list
```

**✅ You should see:**
- Python 3.10 or higher
- All required packages installed

---

## 📂 Prepare Your Data

### Supported Formats
- ✅ CSV (`.csv`)
- ✅ Excel (`.xlsx`, `.xls`)
- ✅ Tab-delimited (`.txt`, `.tsv`)

### Data Location
Place your data file anywhere accessible, e.g.:
```
C:\Data\pursuit-data.csv
```

### Minimum Required Columns
Your data should have AT LEAST:
- AccountName (or similar identifier)
- OpportunityID (unique identifier)
- Stage (opportunity stage)
- CreatedDate (creation date)
- EstimatedValue (deal value)

**Don't worry if your columns don't match exactly** - the auto-fix step will help normalize them!

---

## 🏃 Execution Methods

### Method 1: Run Complete Pipeline (Recommended)

```powershell
# Navigate to scripts folder
cd 01-Scripts

# Run everything in one command
.\RUN-ALL.ps1 -InputFile "C:\Data\pursuit-data.csv"
```

**✅ This will automatically execute:**
1. ✅ Pre-flight checks
2. 🧹 Step 1: Auto-Fix
3. ✅ Step 2: Schema Validation
4. 📊 Step 3: Quality Check
5. 📝 Output Generation

**⏱️ Expected Output:**
```
═══════════════════════════════════════════════════════════════
  🚀 PHASE-1 LOCAL INSIGHTS - COMPLETE PIPELINE
═══════════════════════════════════════════════════════════════

🔍 STEP 0 : PRE-FLIGHT CHECKS
✅ SUCCESS: Input file exists: C:\Data\pursuit-data.csv
✅ SUCCESS: Python environment ready
✅ SUCCESS: Schema files validated

═══════════════════════════════════════════════════════════════
  🧹 STEP 1 : AUTO-FIX DATA CLEANING
═══════════════════════════════════════════════════════════════
⏳ Counting input rows...
📊 InputRowCount : 500
⏳ Executing Python script: 03-Modules\auto_fixer.py...
✅ SUCCESS: Python script completed successfully

  🔍 Auto-Fix Transformations Applied:
     ✅ AUTOFIX-001: Trim Headers and Values
        Rows Affected: 500
     ✅ AUTOFIX-002: Normalize Whitespace
        Rows Affected: 485
     ...

✅ STEP 1 COMPLETED SUCCESSFULLY
```

---

### Method 2: Run Step-by-Step (For Debugging)

#### Step 1: Auto-Fix

```powershell
cd 01-Scripts
.\Step1-AutoFix.ps1 -InputFile "C:\Data\pursuit-data.csv"
```

**📁 Output Files:**
- `05-Outputs\autofix-audit\cleaned-data.csv` - Cleaned data
- `05-Outputs\autofix-audit\autofix-audit-YYYYMMDD-HHMMSS.json` - Transformation log
- `05-Outputs\autofix-audit\traceability-YYYYMMDD-HHMMSS.csv` - Audit trail

**✅ Success Indicators:**
```
✅ STEP 1 COMPLETED SUCCESSFULLY
  📁 Output Files:
     • Cleaned Data: 05-Outputs\autofix-audit\cleaned-data.csv
```

**❌ If Failed:**
- Check the error message
- Review the audit log JSON file
- Ensure input file is readable

---

#### Step 2: Schema Validation

```powershell
.\Step2-Validate.ps1 -InputFile "05-Outputs\autofix-audit\cleaned-data.csv"
```

**📁 Output Files:**
- `05-Outputs\validation-reports\validation-report-YYYYMMDD-HHMMSS.json` - Validation results
- `05-Outputs\validation-reports\traceability-YYYYMMDD-HHMMSS.csv` - Rule outcomes

**✅ Success Indicators (PASS):**
```
═══════════════════════════════════════════════════════════════
  ✅ STEP 2 COMPLETED SUCCESSFULLY - VALIDATION PASSED
═══════════════════════════════════════════════════════════════

  🔍 Validation Results:
     ✅ Overall Status: PASS
     ❌ Errors: 0
     ⚠️  Warnings: 2
```

**❌ If FAILED:**
```
═══════════════════════════════════════════════════════════════
  ❌ VALIDATION FAILED - PROCESSING STOPPED
═══════════════════════════════════════════════════════════════

  🔧 HOW TO FIX:
     • Remove 2 duplicate OpportunityIDs
     • Fix 5 rows with invalid date formats
     • Ensure EstimatedValue > 0 for all active opportunities

  📁 Validation Report: 05-Outputs\validation-reports\validation-report-...
```

**What to do:**
1. Open the validation report JSON file
2. Follow the fix instructions
3. Correct your source data
4. Re-run from Step 1

---

## 📊 Understanding Outputs

### Auto-Fix Audit Report

```json
{
  "transformations": [
    {
      "ruleID": "AUTOFIX-001",
      "ruleName": "Trim Headers and Values",
      "status": "applied",
      "rowsAffected": 500,
      "details": "Trimmed whitespace from all columns"
    }
  ]
}
```

### Validation Report

```json
{
  "overallStatus": "PASS",
  "summary": {
    "errorCount": 0,
    "warningCount": 2,
    "infoCount": 1
  },
  "rules": [
    {
      "ruleID": "VAL-001",
      "ruleName": "Required Columns Check",
      "passed": true,
      "rowsChecked": 495,
      "rowsPassed": 495,
      "rowsFailed": 0
    }
  ]
}
```

### Traceability Matrix (CSV)

```csv
Timestamp,FileName,RuleID,RuleName,RowsProcessed,RowsPassed,RowsFailed,Outcome
2026-01-10 14:23:15,pursuit-data.csv,AUTOFIX-001,Trim Headers,500,500,0,PASS
2026-01-10 14:23:22,cleaned-data.csv,VAL-002,Data Type Check,495,490,5,WARNING
```

---

## 🎨 Understanding Console Icons

| Icon | Meaning | Action Required |
|------|---------|-----------------|
| ✅ | Success | None - continue |
| ❌ | Error/Failure | Fix issue before proceeding |
| ⚠️ | Warning | Review but can continue |
| ℹ️ | Information | No action needed |
| ⏳ | In Progress | Wait for completion |
| 📊 | Metric/Statistic | Review for insights |
| 🔍 | Checking/Validating | Wait for result |
| 🧹 | Cleaning/Fixing | Auto-fix in progress |
| 🐍 | Python Execution | Python module running |
| 📁 | File Reference | Output file location |

---

## 🔧 Common Issues & Solutions

### Issue 1: "Python not found"

**Symptom:**
```
❌ ERROR: Python not found! Install Python 3.10+
```

**Solution:**
```powershell
# Option 1: Install Python
# Download from https://www.python.org/downloads/

# Option 2: Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Verify
python --version
```

---

### Issue 2: "Input file not found"

**Symptom:**
```
❌ ERROR: Input file not found: C:\Data\pursuit-data.csv
```

**Solution:**
```powershell
# Check file path (use absolute path)
Test-Path "C:\Data\pursuit-data.csv"

# Or use relative path from project root
.\RUN-ALL.ps1 -InputFile "..\..\Data\pursuit-data.csv"
```

---

### Issue 3: "Validation FAILED"

**Symptom:**
```
❌ VALIDATION FAILED - PROCESSING STOPPED
  🔧 HOW TO FIX:
     • Remove 2 duplicate OpportunityIDs
```

**Solution:**
1. Open the validation report:
   ```powershell
   code 05-Outputs\validation-reports\validation-report-*.json
   ```

2. Find the failed rules and details

3. Fix your source data

4. Re-run from Step 1:
   ```powershell
   .\Step1-AutoFix.ps1 -InputFile "C:\Data\pursuit-data.csv"
   ```

---

### Issue 4: "Module not found"

**Symptom:**
```
ModuleNotFoundError: No module named 'pandas'
```

**Solution:**
```powershell
# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install pandas openpyxl flask jsonschema python-dateutil

# Verify
pip list
```

---

## 📋 Execution Checklist

### Before Running

- [ ] Python 3.10+ installed
- [ ] Virtual environment activated (optional but recommended)
- [ ] Dependencies installed (`pandas`, `openpyxl`, etc.)
- [ ] Input data file ready (CSV/Excel/TXT)
- [ ] Input file has minimum required columns

### After Step 1 (Auto-Fix)

- [ ] ✅ Step 1 completed successfully
- [ ] Cleaned data file exists: `05-Outputs\autofix-audit\cleaned-data.csv`
- [ ] Auto-fix audit report generated
- [ ] Traceability matrix created

### After Step 2 (Validation)

- [ ] ✅ Step 2 completed with status = PASS
- [ ] Validation report shows 0 errors
- [ ] Warnings reviewed (if any)
- [ ] Traceability matrix updated

### After Complete Pipeline

- [ ] All steps completed successfully
- [ ] All output files generated in `05-Outputs\`
- [ ] Traceability matrices available
- [ ] Audit logs saved

---

## 🖥️ View Results in UI (Step 8)

### Start the Localhost UI

```powershell
# Navigate to UI folder
cd 04-UI

# Start Flask app
python app.py
```

**Expected Output:**
```
 * Running on http://localhost:5000
 * Do not share this URL publicly - localhost only!
```

### Open in Browser

```
http://localhost:5000
```

### UI Features

- 📂 Dataset selection
- 🧹 Auto-fix summary
- ✅ Validation status (PASS/FAIL)
- 📊 Data quality metrics
- 🧠 Insights and rankings
- 📥 Download all outputs

---

## 🎯 Expected Timeline

| Step | Duration | Depends On |
|------|----------|------------|
| Setup (one-time) | 5-10 min | Python installation |
| Step 1: Auto-Fix | 10-30 sec | Dataset size |
| Step 2: Validation | 5-15 sec | Dataset size |
| Step 3: Quality Check | 10-20 sec | Dataset size |
| Steps 4-7: Analysis | 1-5 min | Model speed |
| **TOTAL** | **2-7 min** | (after setup) |

---

## 📞 Getting Help

**Check these files for details:**

1. **Audit Logs** (JSON files)
   - Location: `05-Outputs\*\*-audit-*.json`
   - Contains: Detailed execution logs

2. **Traceability Matrix** (CSV files)
   - Location: `05-Outputs\*\traceability-*.csv`
   - Contains: Rule-by-rule outcomes

3. **Validation Reports** (JSON files)
   - Location: `05-Outputs\validation-reports\validation-*.json`
   - Contains: Validation details and fix instructions

4. **Architecture Doc**
   - File: `06-Documentation\ARCHITECTURE.md`
   - Contains: System design and component descriptions

---

## ✅ Success Criteria

### ✅ Pipeline Succeeded If:

1. All PowerShell scripts exit with code 0
2. Console shows: `✅ STEP X COMPLETED SUCCESSFULLY`
3. All output files created in `05-Outputs\`
4. Validation status = PASS
5. Traceability matrices generated

### ❌ Pipeline Failed If:

1. PowerShell script exits with code 1
2. Console shows: `❌ STEP X FAILED`
3. Validation status = FAIL
4. Missing output files

**In case of failure:**
- Review the error message
- Check the audit log
- Follow fix instructions
- Re-run the failed step

---

**🔒 REMINDER: All execution is local. No data leaves your machine.**
