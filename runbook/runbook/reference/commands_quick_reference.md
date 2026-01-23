# Quick Commands (Runbook)

**Updated:** January 10, 2026

> Run all commands from your project root: `C:\MyCode\Local-AIAgent`

## First-time setup (recommended)
```powershell
# 1) Create folders
.\runbook\setup\03_create_folders.ps1

# 2) Environment setup
.\runbook\setup\01_setup_environment.ps1

# 3) Verify prerequisites
.\runbook\setup\02_verify_prerequisites.ps1

# 4) Run pipeline (Steps 1-3)
.\runbook\pipeline\14_run_full_pipeline.ps1

# 5) Run tests
.\runbook\testing\23_test_full_pipeline.ps1

# 6) Run audits (optional)
.\runbook\audit\30_audit_data_flow.ps1
.\runbook\audit\33_generate_audit_report.ps1
```

## Daily run
```powershell
.\runbook\pipeline\14_run_full_pipeline.ps1
.\runbook\testing\23_test_full_pipeline.ps1
```

## Optional UI
```powershell
.\runbook\pipeline\13_run_step4_ui.ps1
# UI:  http://localhost:5173
# API: http://localhost:5175
```

## Troubleshooting
```powershell
.\runbook\troubleshooting\40_diagnose_issues.ps1
.\runbook\troubleshooting\41_fix_execution_policy.ps1
.\runbook\troubleshooting\43_reset_pipeline.ps1
```
