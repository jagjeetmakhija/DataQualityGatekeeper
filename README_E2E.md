#
# Data Validation Steps Performed by This Solution

When you upload a CSV file and run the validation pipeline, the following steps are performed automatically:

1. **File Reading:**
  - The solution attempts to read your file as a standard CSV using pandas.
  - If the file is not a valid CSV or is corrupted, a clear error message is shown.

2. **Basic Structure Check:**
  - Confirms the file has at least one row and one column.
  - Checks for the presence of a header row (column names).

3. **Missing Value Detection:**
  - Scans all cells for missing (empty) values.
  - Reports the total number of missing values found.

4. **Numeric Column Analysis:**
  - Identifies all columns containing numeric data.
  - For each numeric column, checks for negative values (anomalies).
  - Reports the total number of anomalies found.

5. **Summary Statistics:**
  - Counts the total number of rows and columns.
  - Calculates a simple "Quality Score" (100 minus missing and anomaly counts, minimum 0).

6. **Validation Report Generation:**
  - Creates a JSON report summarizing:
    - Status (APPROVED if no missing values, otherwise REVIEW)
    - Row and column counts
    - Missing value and anomaly counts
    - Quality score
  - The report is available for download from the UI.

**Note:**
- The validation is schema-agnostic and works for any tabular CSV.
- No domain-specific or business-rule checks are performed unless you extend the code.
#
# Supported Business Problems & Use Cases

This solution is designed to help users quickly validate, summarize, and gain insights from tabular data in CSV format. It is ideal for:

- **Data Quality Checks:**
  - Detecting missing values, negative numbers, and anomalies in numeric columns.
  - Ensuring data completeness before analysis, reporting, or machine learning.

- **Business Data Validation:**
  - Validating sales, customer, transaction, or operational data before further processing.
  - Checking for outliers or data entry errors in business reports.

- **Survey & Feedback Analysis:**
  - Quickly summarizing survey results, feedback forms, or poll data.

- **ETL/Integration Pipelines:**
  - As a pre-step in ETL (Extract, Transform, Load) workflows to catch data issues early.

- **Regulatory & Compliance Reporting:**
  - Ensuring exported data meets basic quality standards before submission.

- **General Data Exploration:**
  - Getting a fast overview of any new dataset’s structure, size, and quality.

**Typical users:**
- Data analysts, business users, engineers, and anyone needing a quick, no-code data validation tool.

**Not intended for:**
- Deep statistical analysis, advanced anomaly detection, or domain-specific business rules (but can be extended for these needs).

## Architecture Diagram

```
┌────────────────────────────┐
│   CONFIG/CONFIG/data/      │
│   sample_data.csv          │
└─────────────┬──────────────┘
      │  (Step 1: Generate)
      ▼
┌────────────────────────────┐
│ outputs/outputs/           │
│ converted_phase1.csv       │
└─────────────┬──────────────┘
      │  (Step 2: Validate)
      ▼
┌────────────────────────────┐
│ Validation/Validation/     │
│ Reports/                   │
│ PHASE1_VALIDATION_REPORT.json
│ PHASE1_SIGNALS_REPORT.json │
└─────────────┬──────────────┘
      │  (Step 3: Analyze)
      ▼
    [User/UI/Reports]
```



# Local-AIAgent — E2E Quick Guide (Updated)

This guide provides a one-page checklist to run Phase-1 end-to-end locally or via the new Gradio-based UI. All processing is on your machine (no cloud calls).

## Prerequisites
- Windows PowerShell 5.1 or PowerShell 7 (for PowerShell pipeline)
- Python 3.8+ with `gradio` and `pandas` (for the new UI)
- No external services required

## Required Folders & Files

**Folders:**
- `CONFIG/CONFIG/data/` — stores input/sample data
- `outputs/outputs/` — stores converted CSV outputs
- `Validation/Validation/Reports/` — stores validation and signals reports
- `runbook/runbook/pipeline/` — contains all pipeline scripts

**Key Files:**
- `CONFIG.ps1` — main config (project root)
- `CONFIG/CONFIG/data/sample_data.csv` — sample input data (auto-generated)
- `outputs/outputs/converted_phase1.csv` — cleaned/converted output
- `Validation/Validation/Reports/PHASE1_VALIDATION_REPORT.json` — validation report
- `Validation/Validation/Reports/PHASE1_SIGNALS_REPORT.json` — signals report
- `runbook/runbook/pipeline/14_run_full_pipeline.ps1` — main E2E pipeline script
- `app.py` — Gradio UI for local/remote validation

## E2E Pipeline Flow

### Option 1: PowerShell Scripts
1. **Generate Sample Data**
  - Script: `runbook/runbook/pipeline/10_run_step1_generate.ps1`
  - Output: `CONFIG/CONFIG/data/sample_data.csv`
2. **Validate & Clean Data**
  - Script: `runbook/runbook/pipeline/11_run_step2_validate.ps1`
  - Output: `outputs/outputs/converted_phase1.csv`, `Validation/Validation/Reports/PHASE1_VALIDATION_REPORT.json`
3. **Analyze Signals**
  - Script: `runbook/runbook/pipeline/12_run_step3_analyze.ps1`
  - Output: `Validation/Validation/Reports/PHASE1_SIGNALS_REPORT.json`
4. **Full Pipeline (Automated)**
  - Run: `powershell -ExecutionPolicy Bypass -File runbook\runbook\pipeline\14_run_full_pipeline.ps1`
  - This runs all steps above in sequence.


### Option 2: Gradio Web UI (Recommended)


#### Supported Data Files & Schema

- **File Type:**
  - Standard CSV files (`.csv`) with comma as the default delimiter.
  - File must include a header row (column names).
  - UTF-8 encoding is recommended for best compatibility.

- **Schema Flexibility:**
  - Any number of columns and rows are supported.
  - Column names and order can be anything—no fixed schema is required.
  - Numeric, text, and mixed-type columns are all accepted.
  - The app automatically detects numeric columns for anomaly checks (e.g., negative values).
  - Missing values (empty cells) are detected and reported.

- **Examples of Accepted CSVs:**
  - Simple tabular data: `id,name,score\n1,Alice,95\n2,Bob,88`
  - Business data: `customer_id,region,sales,active\n1001,West,1200.5,TRUE`
  - Survey results, logs, exported spreadsheets, etc.

- **Not Supported:**
  - Files without a header row (add column names as the first row).
  - Non-CSV formats (Excel `.xlsx`, JSON, etc. — convert to CSV first).
  - CSVs with inconsistent row lengths or corrupted formatting.

- **Advanced:**
  - If your CSV uses a different delimiter (e.g., semicolon), contact the maintainer to adjust the code for your needs.

#### Modern, Professional UI Features
- Clean, vibrant color palette (deep blue, gold, white)
- Clear, step-by-step workflow labels:
  - **Step 1: Upload your CSV data file**
  - **Step 2: Run Data Validation Pipeline**
  - **Step 3: Validation Results & Insights**
  - **Step 4: Download Validation Report**
- Emoji and icon accents for clarity
- Accepts any dynamic CSV file (no fixed schema required)
- Robust error handling and user feedback

#### How to Use
1. **Start the UI:**
   - Run: `python app.py`
   - The UI will open in your browser.
2. **Step 1: Upload your CSV data file**
   - Use the file upload box to select any CSV (e.g., `sample_data.csv` or your own data).
3. **Step 2: Run Data Validation Pipeline**
   - Click the button to validate and analyze your data.
4. **Step 3: Validation Results & Insights**
   - Review the output and summary in the results box.
5. **Step 4: Download Validation Report**
   - Download the generated JSON report for your records.

## Output Summary
- `CONFIG/CONFIG/data/sample_data.csv` — source data
- `outputs/outputs/converted_*.csv` — converted Phase-1 CSVs
- `Validation/Validation/Reports/PHASE1_VALIDATION_REPORT.json` — pipeline summary
- `Validation/Validation/Reports/PHASE1_SIGNALS_REPORT.json` — signals summary
- `validation_report.json` — UI-generated validation report (downloadable)


## Tips
- All scripts and the UI use robust project root detection; no hardcoded paths.
- Outputs are always in `outputs/outputs/` and `Validation/Validation/Reports/`.
- The UI supports any well-formed CSV file (with headers, any columns).
- If you see missing file errors, rerun the full pipeline or re-upload your CSV in the UI.

## Troubleshooting
- If you see a port conflict on 5173, the UI is already running; reuse it.
- If tests fail, rerun the full pipeline or refresh/re-upload in the UI to refresh all data and outputs.
- If you see "No file uploaded" or "Error reading CSV", check your file format and try again.
