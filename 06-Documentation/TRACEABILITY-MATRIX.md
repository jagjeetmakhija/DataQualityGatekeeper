# 📊 TRACEABILITY MATRIX DOCUMENTATION

## 🎯 Purpose

The Traceability Matrix provides complete audit trail linking:
- **Input Files** processed
- **Rules** applied (auto-fix, validation, scoring)
- **Row Counts** (processed, passed, failed, warnings)
- **Outcomes** (PASS/FAIL/WARNING/VOID)
- **Explanations** for each decision

This ensures full transparency and auditability for CX stakeholders.

---

## 📋 Matrix Structure

### Standard Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| **Timestamp** | DateTime | When rule was executed | 2026-01-10 14:23:15 |
| **FileName** | String | Input file processed | pursuit-data.csv |
| **RuleID** | String | Unique rule identifier | VAL-001, AUTOFIX-003 |
| **RuleName** | String | Human-readable rule name | Trim whitespace |
| **RuleCategory** | String | Category of rule | AutoFix, Validation, Scoring |
| **RowsProcessed** | Integer | Total rows checked | 500 |
| **RowsPassed** | Integer | Rows that passed rule | 485 ✅ |
| **RowsFailed** | Integer | Rows that failed rule | 15 ❌ |
| **RowsWarning** | Integer | Rows with warnings | 10 ⚠️ |
| **RowsVoid** | Integer | Rows not applicable | 0 ⏭️ |
| **Outcome** | String | Overall rule outcome | PASS / FAIL / WARNING |
| **Details** | String | Explanation/reason | "15 dates in future" |

### Icon Legend

- ✅ **PASS**: Rule executed successfully, all criteria met
- ❌ **FAIL**: Rule failed, critical issue detected
- ⚠️ **WARNING**: Non-critical issue, processing can continue
- ⏭️ **VOID**: Rule not applicable to these rows
- ℹ️ **INFO**: Informational only, no action needed

---

## 🔍 Example Traceability Matrix

```csv
Timestamp,FileName,RuleID,RuleName,RuleCategory,RowsProcessed,RowsPassed,RowsFailed,RowsWarning,RowsVoid,Outcome,Details
2026-01-10 14:23:15,pursuit-data.csv,AUTOFIX-001,Trim Headers,AutoFix,500,500,0,0,0,PASS,All headers trimmed
2026-01-10 14:23:16,pursuit-data.csv,AUTOFIX-002,Normalize Whitespace,AutoFix,500,485,0,15,0,WARNING,15 rows had extra spaces
2026-01-10 14:23:17,pursuit-data.csv,AUTOFIX-003,Standardize Dates,AutoFix,500,490,10,0,0,WARNING,10 dates converted from MM/DD/YYYY
2026-01-10 14:23:18,pursuit-data.csv,AUTOFIX-004,Coerce Numeric Fields,AutoFix,500,495,5,0,0,WARNING,5 values had commas removed
2026-01-10 14:23:19,pursuit-data.csv,AUTOFIX-005,Normalize Stage Values,AutoFix,500,500,0,0,0,PASS,All stages matched standard values
2026-01-10 14:23:20,pursuit-data.csv,AUTOFIX-006,Remove Empty Rows,AutoFix,500,495,5,0,0,PASS,5 empty rows removed
2026-01-10 14:23:21,cleaned-data.csv,VAL-001,Required Columns Check,Validation,495,495,0,0,0,PASS,All required columns present
2026-01-10 14:23:22,cleaned-data.csv,VAL-002,Data Type Validation,Validation,495,490,5,0,0,WARNING,5 rows have invalid date format
2026-01-10 14:23:23,cleaned-data.csv,VAL-003,Allowed Values Check,Validation,495,495,0,0,0,PASS,All categorical values valid
2026-01-10 14:23:24,cleaned-data.csv,VAL-004,Null Threshold Check,Validation,495,495,0,0,0,PASS,Null % within limits
2026-01-10 14:23:25,cleaned-data.csv,VAL-005,Duplicate OpportunityID,Validation,495,493,2,0,0,FAIL,2 duplicate OpportunityIDs found
2026-01-10 14:23:26,cleaned-data.csv,VAL-006,Date Logic Check,Validation,495,490,5,0,0,WARNING,5 rows have LastActivity before Created
```

---

## 📊 Summary Statistics (Auto-Generated)

### By Category

| Category | Total Rules | Passed | Failed | Warnings |
|----------|------------|--------|--------|----------|
| AutoFix | 6 | 4 ✅ | 0 ❌ | 2 ⚠️ |
| Validation | 6 | 4 ✅ | 1 ❌ | 1 ⚠️ |
| **TOTAL** | **12** | **8** | **1** | **3** |

### By Outcome

- ✅ **PASS**: 8 rules (67%)
- ❌ **FAIL**: 1 rule (8%) → **GATE STOP**
- ⚠️ **WARNING**: 3 rules (25%)

### Row-Level Summary

- 📊 **Total Rows Processed**: 500
- ✅ **Rows Passed All Rules**: 483 (96.6%)
- ❌ **Rows Failed Any Rule**: 17 (3.4%)
- ⚠️ **Rows with Warnings**: 30 (6%)

---

## 🔧 How to Use the Traceability Matrix

### 1️⃣ Review Overall Health

Check the summary statistics:
- If **RowsFailed** > 0 for critical rules → Data needs fixing
- If **Warnings** are high → Review data quality

### 2️⃣ Drill Into Failures

Filter the matrix by `Outcome = "FAIL"`:
```powershell
Import-Csv traceability.csv | Where-Object { $_.Outcome -eq "FAIL" }
```

### 3️⃣ Identify Root Causes

Look at the `Details` column to understand why rules failed:
- "2 duplicate OpportunityIDs found" → Fix duplicates
- "10 dates in future" → Correct date entry

### 4️⃣ Track Improvements

Compare traceability matrices across runs:
- Are failure counts decreasing?
- Are warnings being resolved?

### 5️⃣ Audit Trail

For compliance/governance:
- Show exactly what transformations were applied
- Prove no data was invented or guessed
- Demonstrate explainability

---

## 🎨 Visualization Examples

### Rule Outcome Pie Chart

```
┌─────────────────────────┐
│   Rule Outcomes         │
├─────────────────────────┤
│ ✅ PASS     67% ████████│
│ ⚠️ WARNING  25% ███     │
│ ❌ FAIL      8% █       │
└─────────────────────────┘
```

### Row Processing Funnel

```
Input Rows         500 ██████████████████████████
  ↓ Auto-Fix
Cleaned Rows       495 █████████████████████████▌
  ↓ Validation
Validated Rows     490 ████████████████████████▌
  ↓ Scoring
Scored Rows        483 ███████████████████████▌
```

---

## 📁 Generated Files

### Auto-Generated Traceability Files

Each step generates its own traceability matrix:

1. **Step 1 (Auto-Fix)**
   - File: `05-Outputs/autofix-audit/traceability-YYYYMMDD-HHMMSS.csv`
   - Contains: All auto-fix transformations

2. **Step 2 (Validation)**
   - File: `05-Outputs/validation-reports/traceability-YYYYMMDD-HHMMSS.csv`
   - Contains: All validation rule results

3. **Step 6 (Scoring)**
   - File: `05-Outputs/insights/traceability-YYYYMMDD-HHMMSS.csv`
   - Contains: All scoring rule applications

4. **Master Traceability**
   - File: `05-Outputs/traceability/master-traceability-YYYYMMDD-HHMMSS.csv`
   - Contains: Combined view of all steps

---

## 🔐 Trust & Compliance

### Audit Questions Answered

✅ **"What data was processed?"**
- See `FileName` column → Exact file path and name

✅ **"What rules were applied?"**
- See `RuleID` and `RuleName` columns → Complete list

✅ **"How many rows were affected?"**
- See `RowsProcessed`, `RowsPassed`, `RowsFailed` → Exact counts

✅ **"Why did something fail?"**
- See `Details` column → Clear explanation

✅ **"When did this happen?"**
- See `Timestamp` column → Precise timing

✅ **"What was the outcome?"**
- See `Outcome` column → PASS/FAIL/WARNING

---

## 📊 Integration with PowerShell Scripts

### Creating Traceability Entries

```powershell
# Load common functions
. .\Common-Functions.ps1

# Create entry
$entry = New-TraceabilityEntry `
    -FileName "pursuit-data.csv" `
    -RuleID "VAL-001" `
    -RuleName "Required Columns Check" `
    -RuleCategory "Validation" `
    -RowsProcessed 500 `
    -RowsPassed 500 `
    -RowsFailed 0 `
    -RowsWarning 0 `
    -Outcome "PASS" `
    -Details "All required columns present"

# Add to collection
$traceabilityEntries += $entry
```

### Exporting Matrix

```powershell
# Export to CSV
Export-TraceabilityMatrix `
    -Entries $traceabilityEntries `
    -OutputPath "05-Outputs/traceability.csv"
```

---

## 🎯 Benefits for CX Stakeholders

1. **Full Transparency**: See exactly what happened to the data
2. **Easy Troubleshooting**: Identify issues quickly with clear error messages
3. **Compliance Ready**: Complete audit trail for governance
4. **No Black Box**: Every decision is explained and traceable
5. **Executive Friendly**: Icons and clear language (no technical jargon)

---

## 📞 Support

**If you see unexpected outcomes:**

1. Open the traceability CSV file in Excel
2. Filter by `Outcome = "FAIL"` or `Outcome = "WARNING"`
3. Read the `Details` column for explanations
4. Check the corresponding audit log JSON file for full context
5. Review the schema definitions in `02-Schema/` if rules are unclear

---

**🔒 REMEMBER: Every row, every rule, every outcome is tracked. Nothing is hidden.**
