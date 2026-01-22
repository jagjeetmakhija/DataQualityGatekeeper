# All-in-One README: Data Quality Gatekeeper

## 📐 Architecture & Flow Diagram

```
**Purpose:** Visualizes the entire E2E process, showing how data flows and is transformed at each step. Each box represents a phase in the workflow, with a brief description of what happens and why it's important.
┌─────────────────────────────────────────────────────────────┐
│                  📂 DATA INPUT (Local Files)                 │
│              CSV / XLSX / TXT (Stakeholder-Shared)           │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         🧹 STEP 1: AUTO-FIX (Non-AI, Deterministic)         │
│  • Trim headers/values                                       │
│  • Normalize whitespace, casing                              │
│  • Standardize dates (ISO)                                   │
│  • Coerce numeric fields                                     │
│  • Normalize categorical values                              │
│  • Remove empty rows, de-duplicate                           │
│  • ✅ Generate Audit Report                                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│        ✅ STEP 2: SCHEMA VALIDATION (Gate/Checkpoint)        │
│  • Required columns check                                    │
│  • Data type validation                                      │
│  • Allowed values enforcement                                │
│  • Date format checks                                        │
│  • Null threshold validation                                 │
│  • ❌ FAIL → STOP + Show Fix Instructions                    │
│  • ✅ PASS → Continue to Analysis                            │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│      🔍 STEP 3: DATA QUALITY SUMMARY (Non-AI Analysis)      │
│  • Column completeness (null %)                              │
│  • Value ranges and distributions                            │
│  • Anomaly detection (outliers)                              │
│  • Duplicate analysis                                        │
│  • Generate Quality Report                                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│       📝 STEP 4: SNIPPET GENERATION (Controlled Sample)     │
│  • Extract 50-100 rows (configurable)                        │
│  • Include representative samples                            │
│  • Format as readable text (CSV/JSON)                        │
│  • User reviews before sending to model                      │
│  • NO AUTOMATIC FILE ACCESS BY MODEL                         │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│   🧠 STEP 5: LOCAL MODEL ANALYSIS (Azure AI Foundry Local) │
│  • Model: phi-4 (or configured model)                       │
│  • Execution: localhost, CPU/GPU                             │
│  • Internet: OFF                                             │
│  • Input: Text snippet only (not raw file)                   │
│  • Output: Explainable scoring logic + insights              │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│      📊 STEP 6: SCORING & INSIGHTS (Rule-Based + AI)        │
│  • Account Priority (High/Medium/Low)                        │
│  • Activation Likelihood Bands                               │
│  • Stalling/Risk Indicators                                  │
│  • Top Opportunities (ranked)                                │
│  • Top Risks (ranked)                                        │
│  • Clear Drivers ("Why" explanations)                        │
│  • Draft Success Metrics                                     │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         💾 STEP 7: OUTPUT GENERATION (Local Storage)        │
│  • Auto-fix audit report (JSON/HTML)                         │
│  • Schema validation report (PASS/FAIL)                      │
│  • Data quality summary (JSON/HTML)                          │
│  • Ranked insights table (CSV/Excel)                         │
│  • Scoring definitions (JSON)                                │
│  • Success metrics (JSON)                                    │
│  • Traceability matrix (CSV/Excel)                           │
│  • All saved to 05-Outputs/                                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│     🖥️ STEP 8: LOCALHOST UI (Executive Dashboard)           │
│  • Flask/FastAPI on localhost:5000                           │
│  • Sectioned cards/tabs                                      │
│  • Icons for PASS/FAIL, priority levels                      │
│  • Download buttons for all outputs                          │
│  • Run metadata display                                      │
│  • NO EXTERNAL CONNECTIONS                                   │
└─────────────────────────────────────────────────────────────┘

---
**Purpose:** Lists all folders and files involved in the workflow, and the exact order to run scripts. Ensures users know where to find logic and how to execute the process correctly.
## 📁 Folder, File Locations & Script Execution Order

Follow this sequence for a successful E2E run:

- **Files:** Place your input CSV (e.g., `sample-data_ui_edgecases.csv`)

- **Command to run:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File 01-Scripts/RUN-ALL.ps1
  ```

- **Step 1:**
  - **Script:** `Step1-AutoFix.ps1` (calls `auto_fixer.py`)
- **Step 2:**
  - **Script:** `Step2-Validate.ps1` (calls `validator.py`)
- **Step 3:**
  - **Script:** Analytics and scoring logic
  - **Location:** `03-Modules/phase1_analytics.py`

- **Files:**
  - `cleaned-data.csv` (final processed data)
  - `autofix-audit/` (audit logs)
  - `traceability-*.csv` (traceability reports)
---

**Purpose:** Guides users through the full process, from input preparation to output review.
---

- Windows OS
- PowerShell 5.1 or later
- Python (for module scripts)
1. **Prepare Input Data**
2. **Run E2E Script**


     ```powershell
     powershell -ExecutionPolicy Bypass -File 01-Scripts/RUN-ALL.ps1
     ```
### Detailed Flow
- Step 1: Auto-fix input data using rules from `03-Modules/auto_fixer.py` and config files in `02-Schema/`.
- Step 3: Save cleaned/validated data, audit, and traceability reports in output folders.

### Output Structure
- `05-Outputs/Output_<timestamp>/`
  - `cleaned-data.csv` — Final processed data
### Additional Notes
- Module details: See scripts in `03-Modules/`
- Schema/rules: See `02-Schema/`
**Purpose:** Shows where logic and outputs are stored, helping users locate scripts, modules, and results.

---

## 📁 Folder Structure

```
Phase1-LocalInsights/
├── 01-Scripts/                    # PowerShell execution scripts
│   ├── Step1-AutoFix.ps1          # Data cleaning and normalization
│   ├── Step2-Validate.ps1         # Schema validation gate
│   ├── Step3-QualityCheck.ps1     # Data quality analysis
│   ├── Step4-GenerateSnippet.ps1  # Sample data for model
│   ├── Step5-RunAnalysis.ps1      # Local AI model execution
│   ├── Step6-GenerateInsights.ps1 # Scoring and ranking
│
├── 02-Schema/                     # Schema definitions
│   ├── schema.json                # Required columns, types, rules
│   └── validation-rules.json      # Custom validation logic
│
├── 03-Modules/                    # Python helper modules
│   ├── data_loader.py             # CSV/Excel loading
│   ├── auto_fixer.py              # Data cleaning logic
│   ├── validator.py               # Schema validation
│   ├── scorer.py                  # Scoring logic
│   └── report_generator.py        # Output formatting
│
│   │   └── dashboard.html         # Executive dashboard
│       ├── style.css              # Minimal styling
│       └── script.js              # Client-side interactions
│
├── 05-Outputs/                    # All generated outputs
│   ├── autofix-audit/             # Auto-fix reports
│   ├── validation-reports/        # Schema validation results
│   ├── quality-reports/           # Data quality summaries
│   ├── insights/                  # Ranked insights and scores
│   ├── traceability/              # Audit trails
│   └── run-metadata/              # Execution logs
├── 06-Documentation/              # All documentation
```
**Purpose:** Links to supporting documentation for deeper understanding and traceability.

- ARCHITECTURE.md
- TRACEABILITY-MATRIX.md

---
**Contact:** Project owner for support or questions.
