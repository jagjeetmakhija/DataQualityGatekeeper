# Error Codes (Simple)

This runbook uses plain PowerShell exceptions. Common failures and fixes:

- **Missing mandatory root scripts**
  - Symptom: prerequisites fail or pipeline step fails immediately
  - Fix: ensure these exist in project root:
    - CONFIG.ps1
    - Generate-DummyData.ps1
    - E2E-LocalValidationPipeline.ps1
    - Analyze-PursuitData.ps1
    - Start-LocalUI.ps1

- **ExecutionPolicy / script blocked**
  - Symptom: "running scripts is disabled" or file is blocked
  - Fix: run:
    - .\runbook\troubleshooting\41_fix_execution_policy.ps1
    - then rerun .\runbook\setup\01_setup_environment.ps1 (unblocks files)

- **Ports 5173 / 5175 in use**
  - Symptom: UI step fails to start
  - Fix: stop existing process using the port, or reboot; then rerun UI.

If you want more detailed codes, you can extend scripts to emit structured JSON errors.
