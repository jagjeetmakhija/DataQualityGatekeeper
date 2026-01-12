"""
═══════════════════════════════════════════════════════════════
PHASE-1 ANALYTICS MODULE
═══════════════════════════════════════════════════════════════
Purpose: Generate explainable, directional business analytics
Version: 1.0
No AI/ML - rule-based, auditable, local-only outputs
═══════════════════════════════════════════════════════════════
"""

import sys
import json
import pandas as pd
from pathlib import Path
from datetime import datetime

def score_priority(row):
    # Example: Priority based on EstimatedValue and Stage
    if 'EstimatedValue' in row and row['EstimatedValue'] >= 100000:
        return 'High'
    if 'EstimatedValue' in row and row['EstimatedValue'] >= 50000:
        return 'Medium'
    return 'Low'

def score_activation_likelihood(row):
    # Example: Likelihood based on Stage and Probability
    if row.get('Stage', '').lower() in ['proposal', 'negotiation', 'closed-won'] and row.get('Probability', 0) >= 70:
        return 'High'
    if row.get('Probability', 0) >= 40:
        return 'Medium'
    return 'Low'

def detect_stalling_risk(row):
    # Example: Risk if status is On-Hold or probability is low
    if row.get('Status', '').lower() in ['on-hold', 'paused']:
        return 'Stalled'
    if row.get('Probability', 0) < 20:
        return 'At Risk'
    return 'OK'

def main(input_file, output_dir):
    df = pd.read_csv(input_file)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # 1. Scoring definitions
    df['AccountPriority'] = df.apply(score_priority, axis=1)
    df['ActivationLikelihoodBand'] = df.apply(score_activation_likelihood, axis=1)
    df['StallingRisk'] = df.apply(detect_stalling_risk, axis=1)

    scoring_defs = {
        "AccountPriority": "High: EstimatedValue >= 100,000; Medium: >= 50,000; else Low",
        "ActivationLikelihoodBand": "High: Stage in Proposal/Negotiation/Closed-Won and Probability >= 70; Medium: Probability >= 40; else Low",
        "StallingRisk": "Stalled: Status On-Hold/Paused; At Risk: Probability < 20; else OK"
    }
    with open(output_dir / 'scoring-definitions.json', 'w') as f:
        json.dump(scoring_defs, f, indent=2)

    # 2. CX-aligned success metrics (example KPIs)
    kpis = {
        "TotalOpportunities": int(len(df)),
        "TotalEstimatedValue": float(df['EstimatedValue'].sum()) if 'EstimatedValue' in df else None,
        "ClosedWonCount": int((df['Stage'] == 'Closed-Won').sum()) if 'Stage' in df else None,
        "ClosedLostCount": int((df['Stage'] == 'Closed-Lost').sum()) if 'Stage' in df else None,
        "AvgProbability": float(df['Probability'].mean()) if 'Probability' in df else None
    }
    with open(output_dir / 'success-metrics.json', 'w') as f:
        json.dump(kpis, f, indent=2)

    # 3. Ranked insights
    top_opps = df.sort_values(['EstimatedValue', 'Probability'], ascending=[False, False]).head(10)
    top_risks = df[df['StallingRisk'].isin(['Stalled', 'At Risk'])].sort_values('Probability').head(10)
    top_opps.to_csv(output_dir / 'top-opportunities.csv', index=False)
    top_risks.to_csv(output_dir / 'top-risks.csv', index=False)

    # 4. Data quality summary (simple)
    dq_summary = {
        "missing_values": df.isnull().sum().to_dict(),
        "duplicates": int(df.duplicated().sum()),
        "row_count": int(len(df))
    }
    with open(output_dir / 'data-quality-summary.json', 'w') as f:
        json.dump(dq_summary, f, indent=2)

    # 5. Validation results (if available)
    val_report = output_dir / 'report.json'
    if val_report.exists():
        with open(val_report) as f:
            val_data = json.load(f)
        with open(output_dir / 'validation-results.json', 'w') as f2:
            json.dump(val_data, f2, indent=2)

    print("Phase-1 analytics complete. All outputs saved locally in:", output_dir)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python phase1_analytics.py <input_file> <output_dir>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
