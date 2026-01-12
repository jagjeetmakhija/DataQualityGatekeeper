# Phase-1 Local Insights: End-to-End Guide

## Purpose
Phase-1 Local Insights cleans and validates CSV or Excel files so you can review governed outputs without writing code. This version is written for non-technical users and keeps all steps in plain ASCII to avoid console encoding errors.

---

## Quick Start (about 90 seconds)

1. Open a terminal in the LocalAIAgent-Phase1 folder (the root of this guide).
2. Create and activate a virtual environment:
   - Windows: py -3.11 -m venv .venv311 then .venv311\Scripts\activate
   - macOS/Linux: python3 -m venv .venv then source .venv/bin/activate
3. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```
4. Place your input file in DataFiles (e.g. DataFiles\sample-data.csv)
5. Run the unified pipeline and UI launcher:
   ```powershell
   cd 01-Scripts
   .\RUN-ALL-AND-UI.ps1 -InputFile "..\DataFiles\sample-data.csv"
   ```
6. The script will:
   - Clean and normalize your data (auto-fix)
   - Validate schema and types
   - Launch the Flask UI for results
7. Open http://127.0.0.1:5000 in your browser to view results.

**Troubleshooting:**
- If you see an error about missing cleaned-data.csv, check that your input file exists and is readable.
- The script now checks and throws a clear error if cleaned-data.csv is not created.

---

## Full Setup (from scratch)
### 1) Get the code
```bash
# Clone
git clone https://github.com/jagjeetmakhija/Local-AIAgent.git
cd Local-AIAgent/Phase1-LocalInsights

# Or unzip and open Phase1-LocalInsights
```

### 2) Create a virtual environment
```bash
# Windows
python -m venv .venv
.venv\Scripts\activate

# macOS/Linux
python3 -m venv .venv
source .venv/bin/activate
```

### 3) Install dependencies
```bash
pip install --upgrade pip
pip install pandas==2.1.4 flask==3.0.0 jsonschema==4.20.0 openpyxl==3.1.2
```

### 4) Prepare output folders
```bash
# Windows PowerShell
if (-not (Test-Path "05-Outputs\autofix-audit")) { New-Item -ItemType Directory -Path "05-Outputs\autofix-audit" -Force }
if (-not (Test-Path "05-Outputs\validation-reports")) { New-Item -ItemType Directory -Path "05-Outputs\validation-reports" -Force }

# macOS/Linux
mkdir -p 05-Outputs/autofix-audit 05-Outputs/validation-reports
```

### 5) Sanity check
```bash
python --version
pip list | findstr pandas
python -m py_compile 04-UI/app.py
```

### 6) Start the UI
```bash
cd 04-UI
..\..\.venv\Scripts\activate   # Windows
source ../../.venv/bin/activate   # macOS/Linux
python app.py
```
Expected console lines (all ASCII):
```
Starting Local Insights Dashboard...
Running on: http://localhost:5000
Displaying results from: ../05-Outputs/
 * Running on http://127.0.0.1:5000
```

---

## Folder map (what lives where)
```
Phase1-LocalInsights/
 01-Scripts/                 PowerShell helpers (optional)
    Step1-AutoFix.ps1
    Step2-Validate.ps1
    RUN-ALL-CLEAN.ps1
 02-Schema/                  Configuration (critical)
    schema.json             Required columns, types, null thresholds
    allowed-values.json     Allowed categorical values
    validation-rules.json   Switches and thresholds
 03-Modules/                 Python engines
    auto_fixer.py           Cleans data (7 rules)
    validator.py            Validates data (4 checks)
 04-UI/                      Flask app
    app.py                  Server entry point
    templates/dashboard.html
 05-Outputs/                 Results written here
    cleaned-data.csv
    autofix-audit/audit-log.json
    validation-reports/report.json
 uploads/                    Files you upload (created on first upload)
```

---

## Configuration essentials
- [02-Schema/schema.json](02-Schema/schema.json): required columns, data types, and null thresholds.
- [02-Schema/allowed-values.json](02-Schema/allowed-values.json): allowed values for categorical columns (update this if you see warnings like Region).
- [02-Schema/validation-rules.json](02-Schema/validation-rules.json): toggles for each rule and thresholds.
- Keep console/output text in ASCII to avoid Windows code page issues.

---

## Using the Web UI
1. Activate the virtual environment and run python app.py inside [04-UI/app.py](04-UI/app.py).
2. Open http://127.0.0.1:5000.
3. Upload a CSV or Excel file (16 MB or smaller).
4. Click Run Pipeline next to your uploaded file.
5. Review outputs in the UI or directly in [05-Outputs](05-Outputs).

If the page does not load, confirm the server log shows Running on: http://localhost:5000 and no other program is using port 5000.

---

## What you need to run a test
- A file with a header row; column names must match [02-Schema/schema.json](02-Schema/schema.json).
- Supported formats: .csv, .xlsx, .xls.
- File size limit: 16 MB.
- Output folders exist: [05-Outputs/autofix-audit](05-Outputs/autofix-audit) and [05-Outputs/validation-reports](05-Outputs/validation-reports).

---

## Outputs cheat sheet
- Cleaned data: [05-Outputs/cleaned-data.csv](05-Outputs/cleaned-data.csv)
- Audit trail: [05-Outputs/autofix-audit/audit-log.json](05-Outputs/autofix-audit/audit-log.json)
- Validation report: [05-Outputs/validation-reports/report.json](05-Outputs/validation-reports/report.json)

overallStatus in the validation report is PASS when there are zero errors (warnings are fine).

---

## One-minute smoke test
1. Ensure the virtual environment is active and output folders exist.
2. Start the UI (python app.py from 04-UI) and open http://127.0.0.1:5000.
3. Upload a small CSV. You can use the sample below by saving it as sample-data.csv:
   ```csv
   CustomerID,CustomerName,PurchaseDate,PurchaseAmount,Status,Region
   C001,John Doe,2024-01-15,150.50,Active,North
   C002,Jane Smith,2024-02-20,299.99,Inactive,South
   C003,Ada Lovelace,2024-03-10,425.00,Active,East
   ```
4. Click Run Pipeline and wait for the success message.
5. Check outputs in [05-Outputs](05-Outputs). You should see cleaned-data.csv, autofix-audit/audit-log.json, and validation-reports/report.json updated with the current timestamp.

---

## Troubleshooting (plain-language fixes)
- Server will not start: confirm Python 3.11+, reinstall dependencies, and make sure port 5000 is free (netstat -ano | findstr :5000 on Windows).
- Upload fails: keep files under 16 MB, ensure a header row, and use CSV or Excel formats.
- Pipeline fails in UI: verify the output folders exist, then run the modules manually:
  ```bash
  python 03-Modules/auto_fixer.py uploads/your-file.csv 05-Outputs/cleaned-data.csv 05-Outputs/autofix-audit/audit-log.json
  python 03-Modules/validator.py 05-Outputs/cleaned-data.csv 02-Schema/schema.json 05-Outputs/validation-reports/report.json
  ```
- Validation fails often: align column names with [02-Schema/schema.json](02-Schema/schema.json), adjust null thresholds, or add missing allowed values in [02-Schema/allowed-values.json](02-Schema/allowed-values.json).
- Empty outputs: check transformations in [05-Outputs/autofix-audit/audit-log.json](05-Outputs/autofix-audit/audit-log.json) to see which rows were dropped (all-null rows and exact duplicates are removed).

---

## Success checklist
You are done when:
- The UI loads at http://127.0.0.1:5000 and shows the dashboard.
- Upload works and the Run Pipeline button finishes without errors.
- The three output files in [05-Outputs](05-Outputs) refresh with the current timestamp.
- The validation report shows "overallStatus": "PASS" (warnings are acceptable).

---

Version: 1.1
Last Updated: January 10, 2026
Maintained By: Local-AIAgent Team
