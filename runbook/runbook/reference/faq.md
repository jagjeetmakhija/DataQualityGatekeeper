# FAQ

## Where do outputs go?
- Input data: `CONFIG\data\sample_data.csv`
- Cleaned output: `outputs\converted_phase1.csv`
- Insights: `outputs\phase1_insights_local.csv` (optional depending on implementation)
- Reports: `Validation\Reports\PHASE1_VALIDATION_REPORT.json` and `PHASE1_SIGNALS_REPORT.json`

## Can I run everything with one command?
Yes:
```powershell
.\runbook\pipeline\14_run_full_pipeline.ps1
```

## I get ExecutionPolicy errors
Run:
```powershell
.\runbook\troubleshooting\41_fix_execution_policy.ps1
```

## How do I start the UI?
```powershell
.\runbook\pipeline\13_run_step4_ui.ps1
```

## How do I reset and re-run from scratch?
```powershell
.\runbook\troubleshooting\43_reset_pipeline.ps1
.\runbook\pipeline\14_run_full_pipeline.ps1
```
