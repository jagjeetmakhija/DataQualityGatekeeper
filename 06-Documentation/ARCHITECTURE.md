# 📐 PHASE-1 LOCAL AI INSIGHTS ARCHITECTURE

## 🎯 Solution Overview

**Phase-1 Local Predictive Insights System**
- Fully offline, localhost-only execution
- Zero cloud exposure, zero cost surprises
- Explainable, auditable, and deterministic
- Uses Azure AI Foundry Local (phi-4 or similar)

---

## 🏗️ System Architecture (Text Diagram)

```
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
```

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
│   ├── Step7-GenerateOutputs.ps1  # Final report generation
│   ├── RUN-ALL.ps1                # Master orchestration script
│   └── Common-Functions.ps1       # Shared utilities
│
├── 02-Schema/                     # Schema definitions
│   ├── schema.json                # Required columns, types, rules
│   ├── allowed-values.json        # Valid categorical values
│   └── validation-rules.json      # Custom validation logic
│
├── 03-Modules/                    # Python helper modules
│   ├── data_loader.py             # CSV/Excel loading
│   ├── auto_fixer.py              # Data cleaning logic
│   ├── validator.py               # Schema validation
│   ├── quality_analyzer.py        # Data quality checks
│   ├── snippet_generator.py       # Sample data extraction
│   ├── model_client.py            # Local AI model interface
│   ├── scorer.py                  # Scoring logic
│   └── report_generator.py        # Output formatting
│
├── 04-UI/                         # Localhost web interface
│   ├── app.py                     # Flask/FastAPI app
│   ├── templates/
│   │   └── dashboard.html         # Executive dashboard
│   └── static/
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
│
├── 06-Documentation/              # All documentation
│   ├── ARCHITECTURE.md            # This file
│   ├── EXECUTION-FLOW.md          # Step-by-step guide
│   ├── TRACEABILITY-MATRIX.md     # Audit trail guide
│   └── CX-TRUST-CHECKLIST.md      # Security compliance
│
├── requirements.txt               # Python dependencies
├── config.json                    # Configuration settings
└── README.md                      # Quick start guide
```

---

## 🔧 Technology Stack

### Core Components
- **Language**: Python 3.10+ (for modules), PowerShell 7+ (for scripts)
- **Local AI Model**: Azure AI Foundry Local (phi-4 recommended)
- **Data Processing**: pandas, openpyxl (NO external APIs)
- **UI Framework**: Flask (localhost only)
- **Storage**: Local filesystem only

### Dependencies (Minimal)
```
pandas==2.1.4          # Data manipulation
openpyxl==3.1.2        # Excel file support
flask==3.0.0           # Web UI
jsonschema==4.20.0     # Schema validation
python-dateutil==2.8.2 # Date parsing
```

**Why these dependencies?**
- pandas: Industry standard for data manipulation
- openpyxl: Excel file reading without external tools
- flask: Lightweight, localhost-only web framework
- jsonschema: Standard JSON schema validation
- python-dateutil: Robust date parsing

**FORBIDDEN dependencies:**
- ❌ Any cloud SDKs
- ❌ Telemetry libraries
- ❌ Analytics/tracking tools
- ❌ External API clients

---

## 🔐 Security & Trust Guarantees

### ✅ Data Confidentiality
- All data stays on localhost
- No network connections during processing
- No telemetry or logging to external services
- No background uploads

### ✅ Explainability
- Every score has clear business logic
- Every transformation is documented
- Every decision is auditable
- No black-box model behavior

### ✅ Cost Predictability
- Zero cloud costs (100% local)
- One-time model download only
- No per-query charges
- No surprise API bills

### ✅ Auditability
- Every file processed → logged
- Every rule applied → logged
- Every transformation → logged
- Every failure → logged with reason

---

## 🚦 Execution Flow (High-Level)

1. **User selects local data file** (CSV/XLSX/TXT)
2. **Auto-fix runs** → Generates audit report
3. **Schema validation runs** → PASS/FAIL gate
   - ❌ FAIL: Stop + show fix instructions
   - ✅ PASS: Continue
4. **Quality check runs** → Generates quality report
5. **Snippet generated** → User reviews (optional)
6. **Local AI model analyzes snippet** → Generates scoring logic
7. **Scoring applied to full dataset** → Ranked insights
8. **All outputs saved locally** → Reports generated
9. **UI displays results** → Executive dashboard

---

## 📊 Key Outputs

### 1. Auto-Fix Audit Report
- File: `autofix-audit-{timestamp}.json`
- Contents: All transformations applied
- Format: JSON + HTML summary

### 2. Schema Validation Report
- File: `validation-{timestamp}.json`
- Contents: PASS/FAIL status + error details
- Format: JSON + HTML summary

### 3. Data Quality Summary
- File: `quality-{timestamp}.json`
- Contents: Null %, ranges, anomalies
- Format: JSON + HTML summary

### 4. Ranked Insights Table
- File: `insights-{timestamp}.csv`
- Contents: Opportunities, risks, drivers
- Format: CSV (Excel-ready)

### 5. Scoring Definitions
- File: `scoring-{timestamp}.json`
- Contents: Priority bands, rules, thresholds
- Format: JSON

### 6. Success Metrics
- File: `metrics-{timestamp}.json`
- Contents: Proposed KPIs for CX alignment
- Format: JSON

### 7. Traceability Matrix
- File: `traceability-{timestamp}.csv`
- Contents: File → Rules → Outcome mapping
- Format: CSV (Excel-ready)

---

## 🎯 Phase-1 Success Criteria

✅ **Operational Success**
- Runs 100% offline on localhost
- Processes typical datasets (500-5000 rows) in < 5 minutes
- Generates all 7 output types

✅ **Trust Success**
- Zero external network calls
- All transformations documented
- All scores explainable

✅ **Business Success**
- Identifies top 10 opportunities
- Identifies top 10 risks
- Provides clear "why" explanations
- CX stakeholders can understand outputs

---

## 🔄 Next Steps (Future Phases)

**Phase-2 Enhancements** (Out of scope for Phase-1)
- Statistical validation of scoring models
- Historical trend analysis
- What-if scenario modeling
- Advanced visualization

**NOT in Phase-1:**
- Production-grade ML pipelines
- Real-time data ingestion
- Cloud deployment
- Multi-user access control

---

## 📞 Support & Maintenance

**For Issues:**
1. Check `05-Outputs/run-metadata/` for error logs
2. Review traceability matrix for rule failures
3. Consult `EXECUTION-FLOW.md` for step-by-step guide
4. Check schema definitions in `02-Schema/`

**For Enhancements:**
- Modify schema in `02-Schema/schema.json`
- Adjust scoring logic in `03-Modules/scorer.py`
- Update UI in `04-UI/templates/dashboard.html`
- Add custom rules in `02-Schema/validation-rules.json`

---

**🔒 TRUST GUARANTEE: This system is designed to be 100% offline, 100% explainable, and 0% cloud exposure.**
