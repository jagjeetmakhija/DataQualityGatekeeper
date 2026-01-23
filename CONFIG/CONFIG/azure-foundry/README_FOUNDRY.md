# Azure AI Foundry: Minimal-Cost Pipeline (Default Settings)

This guide lets you run the Phase 1 data conversion entirely inside Azure AI Foundry with the lowest-cost defaults. It converts CSV/TSV/TXT/JSON/XML to the Phase 1 CSV schema and performs a basic validation.

## What you get
- CPU-only pipeline (no GPUs) → lowest cost
- No external model calls by default → near-zero inference cost
- One Python script you can run in a compute session
 - Optional insights step (rule-based or local model) you can enable later

## Files
- `azure-foundry/foundry_min_cost_pipeline.py` — Conversion + basic validation
- `azure-foundry/requirements-foundry.txt` — Minimal dependencies (pandas, xmltodict)
 - `azure-foundry/local_insights_optional.py` — Optional insights (rule-based by default; model-enabled if configured)
 - `azure-foundry/requirements-insights.txt` — Only needed for model-enabled insights (installs `openai`)

## Setup (one-time)
1. Create or open an Azure AI Foundry Project.
2. Start a small CPU compute session (e.g., 2 vCPU / 8 GB). Enable auto-suspend/auto-shutdown if available.
3. Upload the two files above into your project (e.g., under `code/azure-foundry/`).

## Run steps
1. Open a terminal in the compute session.
2. Install dependencies once:
   ```bash
   pip install -r code/azure-foundry/requirements-foundry.txt
   ```
3. Place your input data file in the project data storage (e.g., `data/yourfile.csv`).
4. Run the converter:
   ```bash
   python code/azure-foundry/foundry_min_cost_pipeline.py --input data/yourfile.csv --output data/phase1_converted.csv
   ```
5. The script prints a JSON summary and writes `data/phase1_converted.csv`.

## Run as a Job (one-click in Foundry)
You can run these as CPU-only command jobs using the YAMLs below. In Azure AI Foundry:
- Go to Jobs → Create from YAML → upload the YAML → set inputs/outputs.

YAML files:
- `azure-foundry/job_convert.yaml` — converts your input file to Phase 1 CSV
- `azure-foundry/job_insights_rule.yaml` — rule-based insights (no model)
- `azure-foundry/job_insights_model.yaml` — model-enabled insights (optional)

Notes:
- Compute: use a small CPU cluster (instance_count: 1) for lowest cost.
- Env: `azure-foundry/environment-conda.yml` installs minimal packages.
- Inputs/Outputs: point to your data assets (URI file) in Foundry.

## Optional: Insights (CPU-friendly)
By default, insights are rule-based (no model) to keep cost minimal. You can also point to a local/OpenAI-compatible endpoint or Azure OpenAI deployed in your Foundry project.

### Rule-based insights (no model, lowest cost)
```bash
python code/azure-foundry/local_insights_optional.py --input data/phase1_converted.csv --mode rule --output data/phase1_insights.csv
```

### Model-enabled insights (OpenAI-compatible local endpoint)
Install the small extra dependency once:
```bash
pip install -r code/azure-foundry/requirements-insights.txt
```
Set endpoint variables to your local/OpenAI-compatible server (e.g., Foundry Local endpoint) and run:
```bash
set OPENAI_API_BASE=https://<your-local-endpoint>
set OPENAI_API_KEY=not-needed-or-your-key
python code/azure-foundry/local_insights_optional.py --input data/phase1_converted.csv --mode model --model <model-name> --output data/phase1_insights.csv
```

### Model-enabled insights (Azure OpenAI in Foundry)
If using an Azure OpenAI deployment within the project:
```bash
pip install -r code/azure-foundry/requirements-insights.txt
set AZURE_OPENAI_ENDPOINT=https://<your-endpoint>.openai.azure.com/
set AZURE_OPENAI_API_KEY=<your-key>
set AZURE_OPENAI_DEPLOYMENT=<your-deployment-name>
python code/azure-foundry/local_insights_optional.py --input data/phase1_converted.csv --mode model --deployment %AZURE_OPENAI_DEPLOYMENT% --output data/phase1_insights.csv
```

## Supported inputs
- `.csv`, `.tsv`, `.txt` (auto-detects delimiter), `.json` (arrays or objects containing arrays), `.xml` (best-effort flattening)

## Output schema (columns)
- `PursuitId, Account, PursuitName, Owner, Stage, Amount, Currency, CloseDate, Region`

If some columns aren’t present in your source, they are created empty. A basic validation report is included in the JSON summary.

## Optional: Local model insights (still low cost)
- Keep this pipeline model-free by default to minimize cost.
- If you later want short narrative insights, you can add a small local model cell or script using Azure AI Foundry Local models (CPU). This is optional and can be enabled only when needed.
 - Use the commands above to enable model mode only when required.

## Cost tips
- Prefer the YAML jobs with a tiny CPU compute, instance_count=1.
- Auto-stop compute when idle in the project.
- Keep model mode disabled unless needed; rule mode is free of inference cost.

## Cost tips
- Use CPU-only compute.
- Stop/suspend the compute when you’re done.
- Keep dependencies minimal (as provided).
- Avoid calling cloud-hosted models unless necessary.
