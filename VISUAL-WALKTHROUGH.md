# 🎨 VISUAL EXECUTION WALKTHROUGH

## 📋 What You'll See When Running the Pipeline

This guide shows exactly what appears in your PowerShell console when executing the Phase-1 pipeline.

---

## 🚀 Running RUN-ALL.ps1

### Command
```powershell
cd 01-Scripts
.\RUN-ALL.ps1 -InputFile "..\sample-data.csv"
```

### Expected Console Output

```
═══════════════════════════════════════════════════════════════
  🚀 PHASE-1 LOCAL INSIGHTS - COMPLETE PIPELINE
═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
  🔍 STEP 0 : PRE-FLIGHT CHECKS
═══════════════════════════════════════════════════════════════

✅ SUCCESS: Input file exists: ..\sample-data.csv
✅ SUCCESS: Python environment ready: C:\...\python.exe
✅ SUCCESS: Schema files validated
ℹ️  INFO: All pre-flight checks passed

═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
  🧹 STEP 1 : AUTO-FIX DATA CLEANING
═══════════════════════════════════════════════════════════════

✅ SUCCESS: Input file exists: ..\sample-data.csv
  📊 InputFileSize_MB : 0.01
  📊 InputRowCount : 15

⏳ Running auto-fix transformations...
  Command: & 'python.exe' '03-Modules\auto_fixer.py' ...

📂 Loading data from: ..\sample-data.csv
📊 Input rows: 15
⏳ Applying: Trim Headers and Values...
✅ Trim Headers and Values: 15 rows affected
⏳ Applying: Normalize Casing...
✅ Normalize Casing: 15 rows affected
⏳ Applying: Standardize Dates...
✅ Standardize Dates: 15 rows affected
⏳ Applying: Coerce Numeric Fields...
✅ Coerce Numeric Fields: 15 rows affected
⏳ Applying: Normalize Categorical Values...
✅ Normalize Categorical Values: 15 rows affected
⏳ Applying: Remove Empty Rows...
✅ Remove Empty Rows: 0 rows affected
⏳ Applying: De-duplicate Rows...
✅ De-duplicate Rows: 0 rows affected

💾 Saving cleaned data to: 05-Outputs\autofix-audit\cleaned-data.csv
📝 Saving audit log to: 05-Outputs\autofix-audit\autofix-audit-20260110-142315.json
✅ Auto-fix completed: 15 → 15 rows

  🔍 Auto-Fix Transformations Applied:

     ✅ AUTOFIX-001: Trim Headers and Values
        Rows Affected: 15

     ✅ AUTOFIX-002: Normalize Casing
        Rows Affected: 15
        Details: 15 rows affected

     ✅ AUTOFIX-003: Standardize Dates
        Rows Affected: 15
        Details: 15 rows affected

     ✅ AUTOFIX-004: Coerce Numeric Fields
        Rows Affected: 15
        Details: 15 rows affected

     ✅ AUTOFIX-005: Normalize Categorical Values
        Rows Affected: 15
        Details: 15 rows affected

     ✅ AUTOFIX-006: Remove Empty Rows
        Rows Affected: 0
        Details: 0 rows affected

     ✅ AUTOFIX-007: De-duplicate Rows
        Rows Affected: 0
        Details: 0 rows affected

✅ SUCCESS: Traceability matrix exported: 05-Outputs\autofix-audit\traceability-20260110-142315.csv

═══════════════════════════════════════════════════════════════
  📊 EXECUTION SUMMARY
═══════════════════════════════════════════════════════════════

  📝 Script : Step1-AutoFix
  ⏱️  Duration : 2.45 seconds
  🎯 Status : completed
  📂 Input File : ..\sample-data.csv

  📊 Metrics:
     • InputFileSize_MB: 0.01
     • InputRowCount: 15
     • OutputRowCount: 15
     • RowsRemoved: 0
     • TransformationsApplied: 7

  🔍 Traceability Summary:
     ✅ Passed: 90
     ❌ Failed: 0
     ⚠️  Warnings: 0

═══════════════════════════════════════════════════════════════

✅ STEP 1 COMPLETED SUCCESSFULLY

  📁 Output Files:
     • Cleaned Data: 05-Outputs\autofix-audit\cleaned-data.csv
     • Auto-Fix Audit: 05-Outputs\autofix-audit\autofix-audit-20260110-142315.json
     • Traceability Matrix: 05-Outputs\autofix-audit\traceability-20260110-142315.csv
     • Execution Log: 05-Outputs\autofix-audit\step1-audit-20260110-142315.json

  ▶️  Next Step: Run Step2-Validate.ps1 to validate the cleaned data

═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
  ✅ STEP 2 : SCHEMA VALIDATION (GATE)
═══════════════════════════════════════════════════════════════

✅ SUCCESS: Input file exists: 05-Outputs\autofix-audit\cleaned-data.csv
✅ SUCCESS: Schema file exists: 02-Schema\schema.json
  📊 InputRowCount : 15

⏳ Running schema validation...
  Command: & 'python.exe' '03-Modules\validator.py' ...

📂 Loading data from: 05-Outputs\autofix-audit\cleaned-data.csv
📋 Loading schema from: 02-Schema\schema.json
📊 Validating 15 rows...

⏳ Validating: Required Columns Check...
✅ Required Columns Check: All required columns present
⏳ Validating: Data Type Validation...
✅ Data Type Validation: All data types valid
⏳ Validating: Null Threshold Check...
✅ Null Threshold Check: All null thresholds met
⏳ Validating: Allowed Values Check...
✅ Allowed Values Check: All categorical values valid

📝 Saving validation report to: 05-Outputs\validation-reports\validation-report-20260110-142320.json
✅ Validation PASS: 0 errors, 0 warnings

  🔍 Validation Results:

     ✅ Overall Status: PASS

  📊 ValidationStatus : PASS
  ❌ ErrorCount : 0
  ⚠️  WarningCount : 0
  ℹ️  Info : 0

     ✅ VAL-001: Required Columns Check
        Status: PASS
        Rows Checked: 15
        Rows Passed: 15
        Rows Failed: 0
        Message: All required columns present

     ✅ VAL-002: Data Type Validation
        Status: PASS
        Rows Checked: 15
        Rows Passed: 15
        Rows Failed: 0
        Message: All data types valid

     ✅ VAL-003: Null Threshold Check
        Status: PASS
        Rows Checked: 11
        Rows Passed: 11
        Rows Failed: 0
        Message: All null thresholds met

     ✅ VAL-004: Allowed Values Check
        Status: PASS
        Rows Checked: 15
        Rows Passed: 15
        Rows Failed: 0
        Message: All categorical values valid

✅ SUCCESS: Traceability matrix exported: 05-Outputs\validation-reports\traceability-20260110-142320.csv

═══════════════════════════════════════════════════════════════
  📊 EXECUTION SUMMARY
═══════════════════════════════════════════════════════════════

  📝 Script : Step2-Validate
  ⏱️  Duration : 1.23 seconds
  🎯 Status : completed
  📂 Input File : 05-Outputs\autofix-audit\cleaned-data.csv

  📊 Metrics:
     • InputRowCount: 15
     • ValidationStatus: PASS
     • ErrorCount: 0
     • WarningCount: 0

  🔍 Traceability Summary:
     ✅ Passed: 56
     ❌ Failed: 0
     ⚠️  Warnings: 0

═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
  ✅ STEP 2 COMPLETED SUCCESSFULLY - VALIDATION PASSED
═══════════════════════════════════════════════════════════════

  📁 Output Files:
     • Validation Report: 05-Outputs\validation-reports\validation-report-20260110-142320.json
     • Traceability Matrix: 05-Outputs\validation-reports\traceability-20260110-142320.csv
     • Execution Log: 05-Outputs\validation-reports\step2-audit-20260110-142320.json

  ▶️  Next Step: Run Step3-QualityCheck.ps1 for data quality analysis

═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
  📊 STEP 3 : DATA QUALITY CHECK
═══════════════════════════════════════════════════════════════

ℹ️  INFO: Quality check step would run here (Step3-QualityCheck.ps1)
ℹ️  INFO: This step analyzes data completeness, ranges, and anomalies

═══════════════════════════════════════════════════════════════
  🎉 PIPELINE COMPLETED SUCCESSFULLY
═══════════════════════════════════════════════════════════════

  ⏱️  Total Duration : 5.12 seconds
  📂 Input File : ..\sample-data.csv
  📁 Output Directory : 05-Outputs\

  📋 Generated Outputs:
     ✅ Cleaned Data
     ✅ Auto-Fix Audit Report
     ✅ Validation Report
     ✅ Traceability Matrix

  🖥️  Next Step: Start the UI to view results
     Command: cd 04-UI ; python app.py
```

---

## 📊 What Each Section Means

### 🔍 Pre-Flight Checks
```
✅ SUCCESS: Input file exists
✅ SUCCESS: Python environment ready
✅ SUCCESS: Schema files validated
```
**Meaning:** All prerequisites are met. Safe to proceed.

---

### 🧹 Auto-Fix Transformations
```
✅ AUTOFIX-001: Trim Headers and Values
   Rows Affected: 15
```
**Meaning:** This rule was applied to 15 rows. All succeeded.

---

### 📊 Execution Summary
```
  📝 Script : Step1-AutoFix
  ⏱️  Duration : 2.45 seconds
  🎯 Status : completed
```
**Meaning:** Step completed in 2.45 seconds with no errors.

---

### ✅ Validation Results
```
✅ Overall Status: PASS
❌ ErrorCount : 0
⚠️  WarningCount : 0
```
**Meaning:** All validation checks passed. No errors. Safe to continue.

---

### 🎯 Rule-by-Rule Breakdown
```
✅ VAL-001: Required Columns Check
   Status: PASS
   Rows Checked: 15
   Rows Passed: 15
   Rows Failed: 0
```
**Meaning:** This specific rule checked 15 rows. All 15 passed.

---

## ❌ What FAILURE Looks Like

### If Validation Fails

```
═══════════════════════════════════════════════════════════════
  ❌ VALIDATION FAILED - PROCESSING STOPPED
═══════════════════════════════════════════════════════════════

  🔧 HOW TO FIX:

     • Remove 2 duplicate OpportunityIDs in rows 5 and 12
     • Fix 3 rows with invalid date format (expected YYYY-MM-DD)
     • Ensure EstimatedValue > 0 for all Active opportunities

  📁 Validation Report: 05-Outputs\validation-reports\validation-report-20260110-142320.json
  📊 Traceability Matrix: 05-Outputs\validation-reports\traceability-20260110-142320.csv
```

**What to do:**
1. Read the "HOW TO FIX" section
2. Open your source data file
3. Fix the issues listed
4. Re-run Step 1 from the beginning

---

## 🖥️ Starting the UI

### Command
```powershell
cd 04-UI
python app.py
```

### Expected Console Output
```
═══════════════════════════════════════════════════════════════
  🖥️  PHASE-1 LOCAL INSIGHTS DASHBOARD
═══════════════════════════════════════════════════════════════

  🌐 Running on: http://localhost:5000
  🔒 Localhost only - NO external connections
  📊 Displaying results from: ../05-Outputs/

  ⚠️  Do NOT share this URL publicly!
  ✅ Safe to view on your local machine only

  Press Ctrl+C to stop the server

═══════════════════════════════════════════════════════════════

 * Serving Flask app 'app'
 * Debug mode: off
 * Running on http://127.0.0.1:5000
 * Press CTRL+C to quit
```

### Opening the Browser

Navigate to: **http://localhost:5000**

You'll see:
- 🧹 **Auto-Fix Summary** card showing transformations
- ✅ **Validation Results** card with PASS/FAIL status
- 📊 **Rule breakdown** with color-coded indicators
- 📥 **Download buttons** for all outputs

---

## 📁 Output Files Generated

After a successful run, you'll have these files:

```
05-Outputs/
├── autofix-audit/
│   ├── cleaned-data.csv                          ← Your cleaned data
│   ├── autofix-audit-20260110-142315.json        ← What was fixed
│   ├── traceability-20260110-142315.csv          ← Audit trail
│   └── step1-audit-20260110-142315.json          ← Execution log
│
└── validation-reports/
    ├── validation-report-20260110-142320.json    ← PASS/FAIL status
    ├── traceability-20260110-142320.csv          ← Rule outcomes
    └── step2-audit-20260110-142320.json          ← Execution log
```

---

## 🎨 Color Legend

In the console, you'll see different colors:

| Color | Icon | Meaning |
|-------|------|---------|
| **Green** | ✅ | Success - everything OK |
| **Red** | ❌ | Error - action required |
| **Yellow** | ⚠️ | Warning - review recommended |
| **Cyan** | ℹ️ | Information - no action needed |
| **Gray** | ⏳ | Processing - please wait |
| **White** | 📊 | Metric or data point |

---

## 🔍 Understanding Traceability Matrix

Open any `traceability-*.csv` file in Excel:

```
Timestamp              | FileName        | RuleID       | RuleName           | RowsProcessed | RowsPassed | RowsFailed | Outcome
----------------------|-----------------|--------------|--------------------|--------------|-----------|-----------|---------
2026-01-10 14:23:15   | sample-data.csv | AUTOFIX-001  | Trim Headers       | 15           | 15        | 0         | PASS
2026-01-10 14:23:16   | sample-data.csv | AUTOFIX-002  | Normalize Casing   | 15           | 15        | 0         | PASS
2026-01-10 14:23:17   | sample-data.csv | AUTOFIX-003  | Standardize Dates  | 15           | 15        | 0         | PASS
```

**Shows:**
- ✅ Which file was processed
- 🔧 Which transformation was applied
- 📊 How many rows were affected
- 🎯 Whether it passed or failed

---

## 💡 Pro Tips

### Tip 1: Save Console Output
```powershell
.\RUN-ALL.ps1 -InputFile "data.csv" | Tee-Object -FilePath "run-log.txt"
```
This saves the console output to a file for later review.

### Tip 2: Check Exit Codes
```powershell
.\RUN-ALL.ps1 -InputFile "data.csv"
echo $LASTEXITCODE
```
- `0` = Success
- `1` = Failure

### Tip 3: Skip Steps for Testing
```powershell
.\RUN-ALL.ps1 -InputFile "data.csv" -SkipValidation
```
Useful when debugging specific steps.

---

## ✅ Success Indicators

### You'll know it worked if you see:

1. ✅ **Green checkmarks** for all steps
2. ✅ **"VALIDATION PASSED"** message
3. ✅ **"PIPELINE COMPLETED SUCCESSFULLY"** banner
4. ✅ **Files generated** in `05-Outputs/`
5. ✅ **UI loads** at http://localhost:5000

---

## ❌ Failure Indicators

### You'll know something failed if you see:

1. ❌ **Red X marks** and error messages
2. ❌ **"VALIDATION FAILED"** message
3. ❌ **"PIPELINE FAILED"** banner
4. ❌ **Exit code 1** when checking `$LASTEXITCODE`
5. ❌ **Missing output files**

**What to do:**
- Read the error messages carefully
- Check the audit logs in `05-Outputs/`
- Follow the "HOW TO FIX" instructions
- Fix your source data
- Re-run from Step 1

---

## 📞 Need More Help?

If the console output doesn't match these examples:

1. **Check your Python version:** `python --version` (need 3.10+)
2. **Check dependencies:** `pip list`
3. **Review audit logs:** `code 05-Outputs\*\*-audit-*.json`
4. **Read EXECUTION-FLOW.md:** Detailed troubleshooting guide

---

**🎉 You're ready to run the pipeline! Follow the console output and you'll know exactly what's happening at each step.**
