# End-to-End Runbook (Cleaned)

**Version:** 1.1  
**Updated:** January 10, 2026  
**Goal:** Help an end user set up, run, test, and audit the Phase‑1 local pipeline end-to-end.

---

## What you get in this package

- A **single, easy E2E flow** (no duplicate instructions)
- **All scripts as real .ps1 files** (no “copy PIECE blocks” needed)
- Every script:
  - auto-detects the project root using `$PSScriptRoot`
  - can be run multiple times safely
  - includes short comments and clear output

---

## Folder layout

Place this `runbook` folder under your project root:

```
C:\MyCode\Local-AIAgent\
  runbook\
    00_RUNBOOK_MASTER.md
    setup\
    pipeline\
    testing\
    audit\
    troubleshooting\
    reference\
    reports\
```

---

## Mandatory files in your project root (must already exist)

These are your core pipeline scripts (this runbook calls them):

- `CONFIG.ps1`
- `Generate-DummyData.ps1`
- `E2E-LocalValidationPipeline.ps1`
- `Analyze-PursuitData.ps1`
- `Start-LocalUI.ps1` (only needed if you use the UI step)

---

## End-to-end: first-time setup

Run everything from **PowerShell**:

```powershell
cd C:\MyCode\Local-AIAgent

# 1) Create all folders (runbook + outputs)
.\runbook\setup\03_create_folders.ps1

# 2) Environment setup (execution policy + unblock scripts)
.\runbook\setup\01_setup_environment.ps1

# 3) Verify prerequisites (folders + mandatory root files)
.\runbook\setup\02_verify_prerequisites.ps1

# 4) Run pipeline (Steps 1 → 3)
.\runbook\pipeline\14_run_full_pipeline.ps1

# 5) Run tests
.\runbook\testing\23_test_full_pipeline.ps1

# 6) Audit (optional)
.\runbook\audit\30_audit_data_flow.ps1
.\runbook\audit\33_generate_audit_report.ps1
```

---

## Daily run

```powershell
cd C:\MyCode\Local-AIAgent
.\runbook\pipeline\14_run_full_pipeline.ps1
.\runbook\testing\23_test_full_pipeline.ps1
```

---

## Optional: launch UI

```powershell
.\runbook\pipeline\13_run_step4_ui.ps1
```

- UI: `http://localhost:5173`
- API: `http://localhost:5175`

Stop: `Ctrl + C`

---

## Troubleshooting

```powershell
# Diagnose
.\runbook\troubleshooting\40_diagnose_issues.ps1

# Fix execution policy
.\runbook\troubleshooting\41_fix_execution_policy.ps1

# Reset generated outputs
.\runbook\troubleshooting\43_reset_pipeline.ps1
```

---

## Reference

- `runbook\reference\commands_quick_reference.md`
- `runbook\reference\error_codes.md`
- `runbook\reference\faq.md`

### Phase‑1 Offline Explainable Insights (Reference)

- `runbook\reference\PHASE1_OFFLINE_EXPLAINABLE_INSIGHTS.md`
- `runbook\reference\schema_phase1.yaml`
