# 📘 Phase-1 Local Insights: End-to-End User Guide

## 🎯 Overview
Phase-1 Local Insights is a data quality automation solution that automatically cleans, validates, and generates governed insights from your CSV/Excel files. This guide provides complete instructions from scratch setup to final output validation.

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup from Scratch](#environment-setup-from-scratch)
3. [Folder Structure & Purpose](#folder-structure--purpose)
4. [Using the Web UI](#using-the-web-ui)
5. [Loading & Processing Data](#loading--processing-data)
6. [Understanding Outputs](#understanding-outputs)
7. [Validation & Quality Gates](#validation--quality-gates)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

### System Requirements
- **Operating System**: Windows 10/11 or macOS/Linux
- **Python**: Version 3.11 or higher
- **Memory**: Minimum 4 GB RAM
- **Disk Space**: 500 MB free space

### Required Software
1. **Python 3.11+** - [Download from python.org](https://www.python.org/downloads/)
2. **Git** (optional) - For cloning repository
3. **Web Browser** - Chrome, Firefox, Edge, or Safari

---

## 🚀 Environment Setup from Scratch

### Step 1: Get the Code
```bash
# Option A: Clone from GitHub
git clone https://github.com/jagjeetmakhija/Local-AIAgent.git
cd Local-AIAgent/Phase1-LocalInsights

# Option B: Download ZIP and extract
# Then navigate to Phase1-LocalInsights folder
```

### Step 2: Create Virtual Environment
```bash
# Windows
python -m venv .venv
.venv\Scripts\activate

# macOS/Linux
python3 -m venv .venv
source .venv/bin/activate
```

### Step 3: Install Dependencies
```bash
pip install --upgrade pip
pip install pandas==2.1.4 flask==3.0.0 jsonschema==4.20.0 openpyxl==3.1.2
```

### Step 4: Verify Installation
```bash
python --version  # Should show 3.11.x or higher
pip list         # Should show pandas, flask, jsonschema, openpyxl
```

### Step 5: Create Output Directories
```bash
# Windows PowerShell
cd Phase1-LocalInsights
if (-not (Test-Path "05-Outputs\autofix-audit")) { New-Item -ItemType Directory -Path "05-Outputs\autofix-audit" -Force }
if (-not (Test-Path "05-Outputs\validation-reports")) { New-Item -ItemType Directory -Path "05-Outputs\validation-reports" -Force }

# macOS/Linux
mkdir -p 05-Outputs/autofix-audit
mkdir -p 05-Outputs/validation-reports
```

---

## 📁 Folder Structure & Purpose

```
Phase1-LocalInsights/
│
├── 01-Scripts/                    # PowerShell automation scripts (optional)
│   ├── Step1-AutoFix.ps1         # Standalone data cleaning script
│   ├── Step2-Validate.ps1        # Standalone validation script
│   └── RUN-ALL-CLEAN.ps1         # Combined pipeline script
│
├── 02-Schema/                     # Configuration & rules (CRITICAL)
│   ├── schema.json               # Defines expected data structure
│   ├── allowed-values.json       # Valid values for categorical fields
│   └── validation-rules.json     # Validation thresholds & rules
│
├── 03-Modules/                    # Python processing modules
│   ├── auto_fixer.py             # Data cleaning engine (7 rules)
│   └── validator.py              # Schema validation engine (4 checks)
│
├── 04-UI/                         # Web Interface
│   ├── app.py                    # Flask web server
│   └── templates/
│       └── dashboard.html        # Web dashboard UI
│
├── 05-Outputs/                    # Generated results
│   ├── cleaned-data.csv          # Cleaned output data
│   ├── autofix-audit/
│   │   └── audit-log.json        # Transformation audit trail
│   └── validation-reports/
│       └── report.json           # Validation results
│
├── 06-Documentation/              # Additional documentation
│
└── uploads/                       # Uploaded input files (auto-created)
```

### 🔑 Critical Configuration Files

#### 1. `02-Schema/schema.json`
**Purpose**: Defines expected columns, data types, and null thresholds  
**Contains**:
- Required column names
- Expected data types (string, integer, float, date)
- Maximum null percentage allowed per column
- Column descriptions

**Example**:
```json
{
  "columns": {
    "CustomerID": {
      "type": "string",
      "required": true,
      "null_threshold": 0
    },
    "PurchaseAmount": {
      "type": "float",
      "required": true,
      "null_threshold": 5
    }
  }
}
```

#### 2. `02-Schema/allowed-values.json`
**Purpose**: Defines valid values for categorical columns  
**Contains**: Whitelist of acceptable values per column

**Example**:
```json
{
  "Status": ["Active", "Inactive", "Pending"],
  "Region": ["North", "South", "East", "West"]
}
```

#### 3. `02-Schema/validation-rules.json`
**Purpose**: Defines validation gates and thresholds  
**Contains**:
- Required columns check: ON/OFF
- Data type validation: ON/OFF
- Null threshold enforcement: ON/OFF
- Allowed values enforcement: ON/OFF

---

## 🌐 Using the Web UI

### Step 1: Start the Flask Server
```bash
# Navigate to UI folder
cd Phase1-LocalInsights/04-UI

# Activate virtual environment (if not already active)
..\..\.venv\Scripts\activate  # Windows
source ../../.venv/bin/activate  # macOS/Linux

# Start server
python app.py
```

**Expected Output**:
```
🚀 Starting Local Insights Dashboard...
🌐 Running on: http://localhost:5000
📊 Displaying results from: ../05-Outputs/
 * Running on http://127.0.0.1:5000
```

### Step 2: Access the Dashboard
1. Open your web browser
2. Navigate to: `http://localhost:5000`
3. You should see the **Local Insights Dashboard**

### Step 3: Dashboard Features
- **📤 File Upload Section**: Drag-and-drop or click to upload CSV/Excel files
- **📂 Uploaded Files Table**: View all uploaded files with timestamps
- **▶️ Run Pipeline Button**: Process selected file through cleaning + validation
- **📊 Results Section**: View cleaned data, audit logs, and validation reports

---

## 📥 Loading & Processing Data

### Step 1: Prepare Your Data File
**Supported Formats**:
- CSV (`.csv`)
- Excel (`.xlsx`, `.xls`)

**Requirements**:
- Must have header row with column names
- Column names should match `02-Schema/schema.json`
- Maximum file size: 16 MB

**Sample Data Structure**:
```csv
CustomerID,CustomerName,PurchaseDate,PurchaseAmount,Status
C001,John Doe,2024-01-15,150.50,Active
C002,Jane Smith,2024-02-20,299.99,Inactive
```

### Step 2: Upload File via UI
1. Click **"Choose File"** or **drag-and-drop** your file
2. Click **"Upload"** button
3. File appears in **"Uploaded Files"** table with timestamp

### Step 3: Run Processing Pipeline
1. Locate your file in the **Uploaded Files** table
2. Click the **"Run Pipeline"** button next to your file
3. Wait for processing (typically 1-3 seconds)
4. View results in the **Results** section

### Processing Workflow
```
Input File → Auto-Fix (7 Rules) → Validation (4 Checks) → Output Files
```

**Auto-Fix Transformations**:
1. ✂️ Trim Headers and Values (remove whitespace)
2. 🔤 Normalize Column Name Casing (consistent format)
3. 📅 Standardize Date Formats (YYYY-MM-DD)
4. 🔢 Coerce Numeric Types (string → number)
5. 🏷️ Normalize Categorical Values (standardize spelling)
6. 🗑️ Remove Empty Rows (all-null rows)
7. 🔄 Deduplicate Rows (remove exact duplicates)

---

## 📊 Understanding Outputs

### Output 1: Cleaned Data
**Location**: `05-Outputs/cleaned-data.csv`

**Description**: Your input data after applying all 7 transformation rules

**Use Case**: Production-ready dataset for analytics/reporting

**Example**:
```csv
CustomerID,CustomerName,PurchaseDate,PurchaseAmount,Status
C001,John Doe,2024-01-15,150.50,Active
C002,Jane Smith,2024-02-20,299.99,Inactive
```

### Output 2: Audit Log
**Location**: `05-Outputs/autofix-audit/audit-log.json`

**Description**: Complete audit trail showing:
- Which rules were applied
- How many rows were affected
- Before/after row counts
- Processing timestamp

**Example**:
```json
{
  "timestamp": "2026-01-10T22:10:51",
  "input_file": "sample-data.csv",
  "input_rows": 9,
  "output_rows": 9,
  "transformations": [
    {
      "rule": "Trim Headers and Values",
      "rows_affected": 9,
      "status": "completed"
    }
  ]
}
```

### Output 3: Validation Report
**Location**: `05-Outputs/validation-reports/report.json`

**Description**: Validation results with PASS/FAIL status

**Structure**:
- `overallStatus`: "PASS" or "FAIL"
- `summary`: Error and warning counts
- `validationRules`: Detailed results per rule

**Example**:
```json
{
  "overallStatus": "PASS",
  "summary": {
    "totalErrors": 0,
    "totalWarnings": 1
  },
  "validationRules": [
    {
      "rule": "Required Columns",
      "status": "PASS",
      "errors": []
    },
    {
      "rule": "Null Thresholds",
      "status": "WARNING",
      "warnings": ["PurchaseAmount has 11.1% nulls (threshold: 5%)"]
    }
  ]
}
```

---

## ✅ Validation & Quality Gates

### 4 Validation Rules

#### 1. Required Columns Check
- **Purpose**: Ensures all mandatory columns are present
- **Result**: ERROR if missing
- **Configuration**: `02-Schema/schema.json` → `required: true`

#### 2. Data Type Validation
- **Purpose**: Verifies each column has correct data type
- **Result**: ERROR if type mismatch
- **Configuration**: `02-Schema/schema.json` → `type: "string|integer|float|date"`

#### 3. Null Threshold Enforcement
- **Purpose**: Ensures null percentages don't exceed limits
- **Result**: WARNING if exceeded, ERROR if critical
- **Configuration**: `02-Schema/schema.json` → `null_threshold: 5`

#### 4. Allowed Values Check
- **Purpose**: Validates categorical columns against whitelist
- **Result**: ERROR if invalid values found
- **Configuration**: `02-Schema/allowed-values.json`

### PASS Criteria
✅ **PASS**: 0 errors (warnings are acceptable)  
❌ **FAIL**: 1 or more errors

---

## 🛠️ Troubleshooting

### Issue 1: Flask Server Won't Start
**Symptom**: Error message when running `python app.py`

**Solutions**:
```bash
# Check Python version
python --version  # Must be 3.11+

# Reinstall dependencies
pip install --upgrade flask pandas jsonschema openpyxl

# Check port availability
netstat -ano | findstr :5000  # Windows
lsof -i :5000  # macOS/Linux
```

### Issue 2: File Upload Fails
**Symptom**: Upload button doesn't work or returns error

**Solutions**:
1. Check file size (must be < 16 MB)
2. Verify file format (CSV or Excel only)
3. Ensure file has header row
4. Check browser console for JavaScript errors

### Issue 3: Pipeline Execution Failed
**Symptom**: "Pipeline Execution Failed" message in UI

**Solutions**:
```bash
# Verify output directories exist
ls 05-Outputs/autofix-audit
ls 05-Outputs/validation-reports

# Check Python modules
python -c "import pandas, flask, jsonschema, openpyxl; print('OK')"

# Run manual test
cd 03-Modules
python auto_fixer.py ../uploads/your-file.csv ../05-Outputs/cleaned-data.csv ../05-Outputs/autofix-audit/audit-log.json
```

### Issue 4: Validation Always Fails
**Symptom**: `overallStatus: "FAIL"` in report.json

**Solutions**:
1. Check `02-Schema/schema.json` for column requirements
2. Verify input file has all required columns
3. Review `report.json` → `validationRules` for specific errors
4. Adjust `null_threshold` values if needed
5. Update `allowed-values.json` if new values should be accepted

### Issue 5: Empty Output Files
**Symptom**: `cleaned-data.csv` is empty or has fewer rows than input

**Solutions**:
1. Check `audit-log.json` → `transformations` for affected rows
2. Verify input data isn't all duplicates
3. Check for all-null rows (automatically removed)
4. Review deduplication logic if needed

---

## 📧 Support & Additional Resources

### Documentation
- **Business Use Cases**: See `BUSINESS_USE_CASES.md`
- **Production Readiness**: See `PRODUCTION_READY.md`
- **Validation Report**: See `E2E_VALIDATION_REPORT.md`

### GitHub Repository
- **Local-AIAgent**: https://github.com/jagjeetmakhija/Local-AIAgent
- **LocalAIAgent-Phase1**: https://github.com/jagjeetmakhija/LocalAIAgent-Phase1

### Quick Command Reference
```bash
# Start UI
cd Phase1-LocalInsights/04-UI
python app.py

# Run CLI pipeline (alternative)
cd 01-Scripts
.\RUN-ALL-CLEAN.ps1 -InputFile "..\sample-data.csv"

# View outputs
cd 05-Outputs
cat cleaned-data.csv
cat autofix-audit/audit-log.json
cat validation-reports/report.json
```

---

## 🎉 Success Indicators

You've successfully completed E2E setup when you see:
1. ✅ Flask server running on `http://localhost:5000`
2. ✅ Dashboard loads in browser
3. ✅ File uploads successfully
4. ✅ Pipeline executes without errors
5. ✅ Three output files generated:
   - `cleaned-data.csv`
   - `audit-log.json`
   - `report.json`
6. ✅ Validation report shows `"overallStatus": "PASS"`

---

**Version**: 1.0  
**Last Updated**: January 10, 2026  
**Maintained By**: Local-AIAgent Team
