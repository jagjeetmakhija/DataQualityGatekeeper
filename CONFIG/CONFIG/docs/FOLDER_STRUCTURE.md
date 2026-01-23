# 📁 Local-AIAgent - Folder Structure

Clean, organized structure for Phase-1 AI-assisted predictive insights system.

---

## 📂 Root Directory

```
Local-AIAgent/
├── README.md                              # Main documentation and quick start
├── FOLDER_STRUCTURE.md                    # This file - organization guide
│
├── PHASE1_SUMMARY.md                      # Technical summary of Phase-1 signals
├── PHASE1_STATUS.md                       # Implementation status and live test results
├── PHASE1_EXAMPLES.md                     # CLI and API execution examples
│
├── Analyze-PursuitData.ps1               # Core: Predictive signals engine (6 signals)
├── Convert-FileToPhase1CSV.ps1           # Convert any CSV to Phase-1 format
├── Convert-AnyToPhase1CSV.ps1            # Flexible converter for various formats
├── Generate-DummyData.ps1                # Generate test data (250 records)
├── E2E-LocalValidationPipeline.ps1       # End-to-end validation workflow
├── Start-LocalUI.ps1                      # Launch local web UI (no internet needed)
│
└── .gitignore                            # Git ignore rules
```

---

## 📂 Core Directories

### `/outputs/` - Generated Files
All analysis outputs and converted data files.

```
outputs/
├── phase1_converted_local.csv            # Converted data from local sources
├── phase1_converted_testdata.csv         # Converted test datasets
├── phase1_insights_local.csv             # Analysis results from local data
└── phase1_insights_testdata.csv          # Analysis results from test data
```

**Purpose**: Centralized location for all generated files to keep root clean.

---

### `/ui/` - Web Interface
Local web UI for interactive analysis (no internet required).

```
ui/
└── index.html                            # Main UI (drag-drop, signals display)
```

**Purpose**: User-friendly interface for non-technical users.  
**Access**: Run `Start-LocalUI.ps1`, then open http://localhost:5173

---

### `/scripts/` - Utility Scripts
Helper scripts for maintenance and cleanup.

```
scripts/
└── Cleanup-Workspace.ps1                 # Clean temporary files and outputs
```

**Purpose**: Automation and maintenance tasks.

---

### `/Tests/` - Automated Testing
Unit and integration tests for validation.

```
Tests/
├── Unit-Tests.ps1                        # Core function tests (4 tests)
└── Integration-Tests.ps1                 # End-to-end workflow tests
```

**Purpose**: Ensure code quality and regression prevention.  
**Run**: `.\Tests\Unit-Tests.ps1`

---

### `/Validation/` - Data Residency & Compliance
Proof of local-only execution and data compliance.

```
Validation/
├── DataResidencyCheck.ps1               # Verifies no external network calls
├── deployment-steps.md                   # Step-by-step deployment guide
└── Reports/                             # Generated compliance reports
    └── PHASE1_VALIDATION_REPORT.json    # Validation results
```

**Purpose**: Security audit trail and compliance proof.  
**Run**: `.\Validation\DataResidencyCheck.ps1`

---

### `/azure-foundry/` - Azure Foundry Integration (Optional)
Optional cloud integration for Azure Foundry (not required for local execution).

```
azure-foundry/
├── README_FOUNDRY.md                     # Foundry integration guide
├── environment-conda.yml                 # Conda environment for Azure jobs
├── requirements-foundry.txt              # Python dependencies for Foundry
├── requirements-insights.txt             # Python dependencies for insights
│
├── foundry_min_cost_pipeline.py         # Cost-optimized pipeline
├── local_insights_optional.py            # Local Python insights (optional)
│
├── job_convert.yaml                      # Azure job config: data conversion
├── job_insights_model.yaml              # Azure job config: ML model
└── job_insights_rule.yaml               # Azure job config: rule-based
```

**Purpose**: Cloud deployment option for enterprise scale (not needed for Phase-1 PoV).

---

## 🗂️ File Categorization

### Documentation Files (Root)
- `README.md` - **Main guide**: Quick start, features, usage
- `PHASE1_SUMMARY.md` - **Technical deep-dive**: Signal definitions, scoring logic
- `PHASE1_STATUS.md` - **Project status**: Implementation checklist, live results
- `PHASE1_EXAMPLES.md` - **Usage examples**: CLI and API execution samples
- `FOLDER_STRUCTURE.md` - **This file**: Organization and navigation

**Why separate?**
- README: For first-time users
- SUMMARY: For technical stakeholders
- STATUS: For project managers
- EXAMPLES: For developers

---

### PowerShell Scripts (Root)
All core functionality is in root for easy access:

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `Analyze-PursuitData.ps1` | Generate signals | Main analysis workflow |
| `Convert-FileToPhase1CSV.ps1` | Data conversion | Prepare external data |
| `Convert-AnyToPhase1CSV.ps1` | Flexible converter | Handle various formats |
| `Generate-DummyData.ps1` | Test data | Development and demos |
| `E2E-LocalValidationPipeline.ps1` | Full validation | Quality assurance |
| `Start-LocalUI.ps1` | Launch web UI | Non-technical users |

---

### Output Files (outputs/)
All generated files go here to keep root clean:

- **Converted Data**: `phase1_converted_*.csv`
- **Analysis Results**: `phase1_insights_*.csv`

**Naming Convention**: `phase1_<type>_<source>.csv`
- `<type>`: converted | insights
- `<source>`: local | testdata | custom

---

## 🧹 What Was Removed (Cleanup)

During the cleanup process, the following files were removed:

✅ **Removed**:
- `Convert-FileToPhase1CSV.ps1.bak` - Backup file (outdated)
- `tmp2.csv` - Temporary file (19 KB, unnecessary)
- `ui/index-old.html` - Old UI version
- `ui/index-enhanced.html` - Intermediate UI version

✅ **Kept**: Only the latest `ui/index.html`

---

## 📝 Best Practices

### When Adding New Files

1. **Scripts** → Root directory
2. **Outputs** → `/outputs/` folder
3. **Tests** → `/Tests/` folder
4. **Documentation** → Root (if important) or `/docs/` (if detailed)
5. **UI Components** → `/ui/` folder

### Naming Conventions

- **Scripts**: Use `PascalCase-WithHyphens.ps1`
- **Outputs**: Use `lowercase_with_underscores.csv`
- **Docs**: Use `UPPERCASE_UNDERSCORES.md` for status files

### Cleanup Routine

Run periodically:
```powershell
# Clean old outputs (keep last 7 days)
Get-ChildItem "outputs\*.csv" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item

# Remove temp files
Get-ChildItem "tmp*", "*.bak", "*~" | Remove-Item -Force
```

---

## 🚀 Quick Navigation

**To run analysis**:
```powershell
.\Analyze-PursuitData.ps1 -CSVFilePath "your_data.csv"
```

**To generate test data**:
```powershell
.\Generate-DummyData.ps1
```

**To launch UI**:
```powershell
.\Start-LocalUI.ps1
```

**To run tests**:
```powershell
.\Tests\Unit-Tests.ps1
```

**To validate data residency**:
```powershell
.\Validation\DataResidencyCheck.ps1
```

**To view outputs**:
```powershell
Get-ChildItem outputs\
```

---

## 📊 Folder Size Summary

Approximate sizes:
- **Root scripts**: ~75 KB
- **Documentation**: ~55 KB
- **Outputs**: ~30 KB
- **UI**: ~20 KB
- **Tests**: ~10 KB
- **Validation**: ~5 KB
- **Azure-foundry**: ~15 KB

**Total**: ~210 KB (lightweight and portable)

---

## 🔄 Version Control

**Tracked by Git** (`.git/`):
- All scripts and source code
- Documentation files
- Configuration files
- UI assets

**Ignored** (`.gitignore`):
- `/outputs/` - Generated files
- `.venv/` - Python virtual environment
- Temporary files (*.bak, tmp*)

---

## 📖 Additional Resources

- **Main Guide**: [README.md](README.md)
- **Technical Details**: [PHASE1_SUMMARY.md](PHASE1_SUMMARY.md)
- **Status Report**: [PHASE1_STATUS.md](PHASE1_STATUS.md)
- **Usage Examples**: [PHASE1_EXAMPLES.md](PHASE1_EXAMPLES.md)
- **Azure Integration**: [azure-foundry/README_FOUNDRY.md](azure-foundry/README_FOUNDRY.md)
- **Deployment**: [Validation/deployment-steps.md](Validation/deployment-steps.md)

---

**Folder structure is now clean, organized, and maintainable!** ✨
