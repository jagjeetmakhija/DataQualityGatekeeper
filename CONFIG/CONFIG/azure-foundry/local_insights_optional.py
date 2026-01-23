#!/usr/bin/env python3
import argparse
import json
import os
from datetime import datetime
from pathlib import Path

import pandas as pd


def rule_based_insight(row: dict) -> str:
    def _clean(v):
        s = str(v).strip()
        return "" if s.lower() == "nan" else s

    name = _clean(row.get("PursuitName", "")) or "This pursuit"
    stage = _clean(row.get("Stage", "")).lower()
    amount = _clean(row.get("Amount", ""))
    try:
        amount_num = float(amount) if str(amount).strip() else None
    except Exception:
        amount_num = None
    close_date = _clean(row.get("CloseDate", ""))

    messages = []
    if stage in {"prospecting", "qualification", "qualify", "discovery"}:
        messages.append("Advance to next stage by securing a dated next step and stakeholder alignment.")
    elif stage in {"proposal", "proposal/price quote", "negotiation", "commit"}:
        messages.append("Focus on decision-makers and remove blockers to accelerate close.")
    elif stage in {"closed won", "won"}:
        messages.append("Closed-won: confirm handoff and capture learnings.")
    elif stage in {"closed lost", "lost"}:
        messages.append("Closed-lost: document reasons and plan re-engagement where appropriate.")

    if amount_num is not None and amount_num >= 100000:
        messages.append("High value: ensure exec sponsor and competitive differentiation are clear.")

    if close_date:
        messages.append(f"Target close: {close_date} — confirm timeline and exit criteria.")

    if not messages:
        messages.append("Review health, stakeholders, and next best action to progress.")

    return f"{name}: " + " ".join(messages)


def get_client_and_model(args):
    # Prefer Azure OpenAI if configured
    azure_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
    azure_key = os.getenv("AZURE_OPENAI_API_KEY")
    azure_api_version = os.getenv("AZURE_OPENAI_API_VERSION", "2024-10-21")
    azure_deployment = args.deployment or os.getenv("AZURE_OPENAI_DEPLOYMENT")

    if azure_endpoint and azure_key and azure_deployment:
        try:
            from openai import AzureOpenAI
        except Exception as e:  # pragma: no cover
            raise SystemExit("openai package not installed. Run: pip install -r code/azure-foundry/requirements-insights.txt")
        client = AzureOpenAI(api_key=azure_key, api_version=azure_api_version, azure_endpoint=azure_endpoint)
        return client, azure_deployment, "azure"

    # Fallback to OpenAI-compatible base URL (e.g., Foundry Local endpoint or other local server)
    base_url = os.getenv("OPENAI_API_BASE") or os.getenv("LOCAL_MODEL_API_BASE")
    api_key = os.getenv("OPENAI_API_KEY") or os.getenv("LOCAL_MODEL_API_KEY") or "not-needed"
    model = args.model or os.getenv("OPENAI_MODEL", "local-model")

    if base_url:
        try:
            from openai import OpenAI
        except Exception as e:  # pragma: no cover
            raise SystemExit("openai package not installed. Run: pip install -r code/azure-foundry/requirements-insights.txt")
        client = OpenAI(base_url=base_url, api_key=api_key)
        return client, model, "openai"

    raise SystemExit("Model mode requested but no endpoint configured. Set Azure or OpenAI-compatible env vars, or use --mode rule.")


def generate_model_insight(client, model_name, flavor: str, row: dict) -> str:
    sys_prompt = (
        "You are a sales assistant. In 1-2 sentences, summarize the deal status "
        "and suggest one actionable next step. Be concise and specific."
    )
    user_context = {
        "PursuitId": row.get("PursuitId", ""),
        "PursuitName": row.get("PursuitName", ""),
        "Account": row.get("Account", ""),
        "Stage": row.get("Stage", ""),
        "Amount": row.get("Amount", ""),
        "Currency": row.get("Currency", ""),
        "CloseDate": row.get("CloseDate", ""),
        "Region": row.get("Region", ""),
    }

    messages = [
        {"role": "system", "content": sys_prompt},
        {"role": "user", "content": f"Context: {json.dumps(user_context, ensure_ascii=False)}"},
    ]

    if flavor == "azure":
        resp = client.chat.completions.create(
            model=model_name,
            messages=messages,
            temperature=0.2,
            max_tokens=120,
        )
        return resp.choices[0].message.content.strip()
    else:
        resp = client.chat.completions.create(
            model=model_name,
            messages=messages,
            temperature=0.2,
            max_tokens=120,
        )
        return resp.choices[0].message.content.strip()


def main():
    ap = argparse.ArgumentParser(description="Optional local insights generator (CPU-friendly)")
    ap.add_argument("--input", required=True, help="Input Phase 1 CSV path (from converter)")
    ap.add_argument("--output", required=False, help="Output CSV for insights (default: alongside input)")
    ap.add_argument("--mode", choices=["rule", "model"], default="rule", help="Insight mode: 'rule' (no model) or 'model' (LLM)")
    ap.add_argument("--deployment", required=False, help="Azure OpenAI deployment name (when using Azure)")
    ap.add_argument("--model", required=False, help="Model name for OpenAI-compatible local endpoint")
    args = ap.parse_args()

    inp = Path(args.input)
    if not inp.exists():
        raise SystemExit(f"Input not found: {inp}")

    out_path = Path(args.output) if args.output else inp.with_name(inp.stem + "_insights.csv")

    df = pd.read_csv(inp)
    rows = []

    client = None
    model_name = None
    flavor = None
    if args.mode == "model":
        client, model_name, flavor = get_client_and_model(args)

    for _, r in df.iterrows():
        rec = r.to_dict()
        if args.mode == "rule":
            insight = rule_based_insight(rec)
        else:
            try:
                insight = generate_model_insight(client, model_name, flavor, rec)
            except Exception as e:
                insight = f"[model-error] {e}"
        rows.append({
            "PursuitId": rec.get("PursuitId", ""),
            "PursuitName": rec.get("PursuitName", ""),
            "Account": rec.get("Account", ""),
            "Stage": rec.get("Stage", ""),
            "Insight": insight,
        })

    pd.DataFrame(rows).to_csv(out_path, index=False)

    print(json.dumps({
        "ok": True,
        "mode": args.mode,
        "input": str(inp),
        "output": str(out_path),
        "rows": len(rows),
        "azure_used": flavor == "azure",
        "openai_compatible_used": flavor == "openai",
    }, indent=2))


if __name__ == "__main__":
    main()
