# Phase-1 (POV) — Offline, Explainable, Directional Predictive Insights (Localhost Only)

> **Scope:** Phase-1 proof-of-value (directional insights), **NOT** a production ML system.  
> **Runtime:** 100% localhost / offline-capable.  
> **Model:** *Foundry Local* (example: phi-4) running on **CPU or GPU** locally.

---

## ✅ Non‑Negotiable Trust Constraints (Built‑in)

🔐 **Data & Trust**
- Confidential data stays on the machine (no sharing).
- **No external connections**: no external APIs, no plugins, no uploads.
- **No telemetry**: no background reporting.
- **Predictable cost**: local execution only; no hidden usage meters.
- **Explainable outputs**: rules/heuristics + “why” drivers (no black‑box scoring).

🚫 **Explicitly forbidden**
- Any remote AI endpoints
- Public APIs
- Auto-upload or sync
- Browser AI tools
- Background processes that can create cost surprises

---

## 1) Text Architecture Diagram (Simple + Auditable)

```
[User / Stakeholder]                         (Local machine only)
        |
        | 1) selects local file (CSV/XLSX/TXT)
        v
[Local Intake Loader (non‑AI)]
        |
        | 2) deterministic auto-fix (logged)
        v
[Auto‑Fix Engine] ---> writes ---> outputs/audit/AUTOFIX_AUDIT_REPORT.json
        |
        | 3) schema validation gate (PASS/FAIL)
        v
[Schema Validator] ---> writes ---> outputs/validation/PHASE1_VALIDATION_REPORT.json
        |
        | FAIL => STOP + actionable error
        | PASS => continue
        v
[Snippet Generator (non‑AI)]  (50–100 rows max, redacted/limited)
        |
        | 4) user-controlled prompt + snippet
        v
[Foundry Local Model (offline)]  ---> returns ---> [Explainable Drafts]
        |
        | 5) rules-based scoring + drivers
        v
[Insights Generator]
        |
        +--> outputs/insights/RANKED_INSIGHTS.csv
        +--> outputs/insights/SCORING_DEFINITIONS.md
        +--> outputs/insights/SUCCESS_METRICS.md
        +--> outputs/data_quality/DATA_QUALITY_SUMMARY.json
        +--> outputs/run_metadata/RUN_METADATA.json
```

---

## 2) Clean Module / Folder Structure

Recommended project layout:

```
<project-root>/
  data/                         # input files (local only)
  Validation/
    Schemas/                    # schema definitions (yaml/json)
    Reports/                    # validation outputs
  outputs/
    audit/
    validation/
    converted/                  # cleaned datasets
    snippets/
    insights/
    data_quality/
    run_metadata/
  ui/                           # thin local UI (optional)
  runbook/
    setup/
    pipeline/
    testing/
    audit/
    troubleshooting/
    reference/                  # this doc + schemas + templates
```

---

## 3) Minimal Dependencies (Phase‑1) + Why

**Required**
- **PowerShell 7+**: consistent scripting + portability
- **Python 3.10+** (optional but recommended): robust CSV/XLSX parsing + deterministic cleanup
- **Foundry Local runtime**: local model inference (CPU/GPU), offline

**Avoid (Phase‑1)**
- Heavy ML stacks (training frameworks) — not needed for directional scoring
- Anything that requires internet access

---

## 4) Phase‑1 Execution Flow (With Fail Gates)

### Step A — Intake (non‑AI)
- User selects a local file in `data/`
- Loader reads it (CSV/XLSX/TXT) and writes a normalized CSV into:
  - `outputs/converted/converted_phase1.csv`

### Step B — Auto‑Fix (deterministic + auditable)
Auto-fix MUST:
- Trim headers and values
- Normalize casing/whitespace
- Standardize dates to ISO (YYYY‑MM‑DD) when possible
- Coerce numeric fields safely (`"1,000" → 1000`)
- Normalize known categorical synonyms (controlled mapping only)
- Handle delimiter issues (comma/tab)
- Remove/flag empty rows
- De‑duplicate obvious duplicates

**Rules**
- Deterministic only (same input → same output)
- No guessing/inventing business values
- Every change is logged in `outputs/audit/`

### Step C — Schema Validation Gate (STOP if FAIL)
Validation checks:
- Required columns
- Data types
- Allowed values
- Date formats
- Null thresholds

**If FAIL**
- STOP processing immediately
- Show **actionable** message:
  - what failed
  - why it failed
  - how to fix it
- Save a FAIL report:
  - `outputs/validation/PHASE1_VALIDATION_REPORT.json`

**If PASS**
- Proceed to snippet generation + Phase‑1 analysis

### Step D — Controlled Model Usage (user‑controlled)
- Model NEVER reads files
- User provides ONLY a limited snippet (50–100 rows max)
- Snippet is created by a local snippet generator and saved under:
  - `outputs/snippets/snippet_phase1.txt`
- Internet OFF

### Step E — Phase‑1 Analytics Outputs (Explainable)
Generate:
1) **Directional scoring definitions**
   - Account Priority (High/Medium/Low)
   - Activation Likelihood band
   - Stalling / Risk indicators
2) **CX-aligned success metrics** (draft KPIs)
3) **Ranked insights**
   - top opportunities
   - top risks
   - drivers (“why”)
4) **Data quality summary** + validation results

---

## 5) Example Schema Definition (YAML)

See: `runbook/reference/schema_phase1.yaml`

---

## 6) Explainable Scoring Logic (Rules / Heuristics)

**Important:** Directional scoring only — not statistical prediction.

### Example rule set (illustrative)
**Account Priority**
- High:
  - Stage in {Negotiation, Proposal} AND
  - Value >= threshold AND
  - LastActivityDate within last N days
- Medium:
  - Stage in {Discovery, Qualification} OR
  - Value moderate AND activity recent
- Low:
  - Low value OR no recent activity OR missing key fields

**Activation Likelihood Band**
- High:
  - Activation milestones completed count >= X
  - No blocked dependencies
- Medium:
  - Some milestones completed, some pending
- Low:
  - Many pending + long inactivity + high nulls in critical fields

**Stalling / Risk Indicators**
- “Stale activity”: LastActivityDate older than N days
- “Stage stagnation”: StageAgeDays > threshold
- “Data risk”: key columns null rate > threshold
- “Value mismatch”: High value but no progress signals

**Explainability rule**
- Every score MUST output:
  - triggered rules
  - fields used
  - driver text (“why this was ranked”)

---

## 7) Sample Output Templates

### Ranked Insights table (CSV)
- `OpportunityRank`
- `AccountId`
- `AccountName`
- `PriorityBand`
- `RiskBand`
- `TopDrivers` (semicolon-separated)
- `RecommendedNextAction`
- `ConfidenceNote` (directional)

### Validation report (JSON)
- `OverallStatus`: PASS/FAIL
- `FailedChecks`: list with `check`, `column`, `reason`, `fix`
- `Summary`: row counts, duplicates removed, quality score

### Run metadata (JSON)
- `timestamp`
- `model_name`
- `device` (CPU/GPU)
- `rows_in`
- `rows_after_autofix`
- `snippet_rows_sent_to_model`

---

## 8) CX Trust Checklist (Phase‑1 Proof)

✅ Offline execution
- All steps run locally (no remote calls)

✅ No data exposure
- Inputs/outputs remain on disk locally
- No external dependencies that transmit data

✅ No black‑box behavior
- Directional scoring = explicit rules + drivers
- Model used only for drafting text explanations from limited snippets

✅ No cost surprises
- Local compute only (CPU/GPU)
- No metered remote usage

✅ Full auditability
- Auto-fix audit report saved
- Validation report saved (PASS/FAIL)
- Run metadata saved
