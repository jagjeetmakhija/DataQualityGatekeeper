#!/usr/bin/env python3
import argparse
import csv
import json
import os
import re
from datetime import datetime, UTC
from pathlib import Path

import pandas as pd

try:
    import xmltodict  # lightweight XML → dict
except Exception:  # pragma: no cover
    xmltodict = None


PHASE1_COLUMNS = [
    "PursuitId",
    "Account",
    "PursuitName",
    "Owner",
    "Stage",
    "Amount",
    "Currency",
    "CloseDate",
    "Region",
]

# Synonyms for auto-mapping (normalized to alphanum lowercase)
SYNONYMS = {
    "PursuitId": [
        "pursuitid", "id", "dealid", "opportunityid", "oppid", "opportunity_id",
    ],
    "Account": [
        "account", "accountname", "customer", "customername", "client", "company", "companyname",
    ],
    "PursuitName": [
        "pursuit", "pursuitname", "deal", "dealname", "opportunity", "opportunityname", "name", "title", "site",
    ],
    "Owner": [
        "owner", "rep", "salesrep", "seller", "accountowner", "ownername", "ae",
    ],
    "Stage": [
        "stage", "status", "salesstage", "pipeline_stage", "phase",
    ],
    "Amount": [
        "amount", "value", "dealvalue", "arr", "acv", "tcv", "revenue", "price", "total",
    ],
    "Currency": [
        "currency", "ccy", "curr",
    ],
    "CloseDate": [
        "closedate", "close_date", "expectedclose", "expectedclosedate", "targetclose", "closeby", "close", "close_dt", "date", "forecastclose",
    ],
    "Region": [
        "region", "geo", "area", "territory", "location", "market",
    ],
}


def norm(s: str) -> str:
    return re.sub(r"[^a-z0-9]", "", s.strip().lower())


def detect_delimiter(text_sample: str) -> str:
    try:
        sniffer = csv.Sniffer()
        dialect = sniffer.sniff(text_sample)
        return dialect.delimiter
    except Exception:
        # Fallback to comma
        return ","


def load_any(path: Path) -> pd.DataFrame:
    ext = path.suffix.lower()
    if ext in {".csv"}:
        return pd.read_csv(path)
    if ext in {".tsv"}:
        return pd.read_csv(path, sep="\t")
    if ext in {".txt"}:
        # Try to sniff delimiter from first 4096 bytes
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            sample = f.read(4096)
        delim = detect_delimiter(sample)
        return pd.read_csv(path, sep=delim)
    if ext in {".json"}:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        # Accept list[dict] or object containing a list under some key
        records = None
        if isinstance(data, list):
            records = data
        elif isinstance(data, dict):
            # Find first list value
            for v in data.values():
                if isinstance(v, list):
                    records = v
                    break
        if records is None:
            records = [data]
        return pd.json_normalize(records)
    if ext in {".xml"}:
        if xmltodict is None:
            raise RuntimeError("xmltodict not installed; add to requirements-foundry.txt")
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            data = xmltodict.parse(f.read())
        # Find the deepest list of dicts
        def find_records(obj):
            if isinstance(obj, list):
                return obj
            if isinstance(obj, dict):
                # Prefer list-typed values
                for v in obj.values():
                    recs = find_records(v)
                    if recs is not None:
                        return recs
            return None
        records = find_records(data) or []
        if not records:
            # Fallback: flatten the dict
            return pd.json_normalize(data)
        return pd.json_normalize(records)
    raise ValueError(f"Unsupported file extension: {ext}")


def build_mapping(df: pd.DataFrame) -> dict:
    cols_norm = {norm(c): c for c in df.columns}
    mapping = {}
    used = set()
    for target in PHASE1_COLUMNS:
        found = None
        for syn in SYNONYMS.get(target, []):
            if syn in cols_norm:
                cand = cols_norm[syn]
                if cand not in used:
                    found = cand
                    break
        if not found:
            # Try exact normalized name match against target name itself
            tnorm = norm(target)
            if tnorm in cols_norm and cols_norm[tnorm] not in used:
                found = cols_norm[tnorm]
        mapping[target] = found  # can be None
        if found:
            used.add(found)
    return mapping


def coerce_columns(df: pd.DataFrame, mapping: dict) -> pd.DataFrame:
    out = pd.DataFrame()
    for col in PHASE1_COLUMNS:
        src = mapping.get(col)
        if src and src in df.columns:
            out[col] = df[src]
        else:
            out[col] = ""
    # Normalize CloseDate to ISO YYYY-MM-DD when possible
    if "CloseDate" in out.columns:
        try:
            out["CloseDate"] = pd.to_datetime(out["CloseDate"], errors="coerce").dt.strftime("%Y-%m-%d")
            out["CloseDate"] = out["CloseDate"].fillna("")
        except Exception:
            pass
    # Numeric Amount
    if "Amount" in out.columns:
        try:
            out["Amount"] = pd.to_numeric(out["Amount"].astype(str).str.replace(",", ""), errors="coerce")
        except Exception:
            pass
    return out


def basic_validate(df: pd.DataFrame) -> dict:
    issues = []
    required_any = ["PursuitName", "Account"]
    for col in required_any:
        if col not in df.columns:
            issues.append(f"Missing required column: {col}")
        elif df[col].fillna("").eq("").all():
            issues.append(f"Column {col} is empty")
    return {
        "rowCount": int(len(df)),
        "issues": issues,
        "ok": len(issues) == 0,
    }


def main():
    ap = argparse.ArgumentParser(description="Convert arbitrary file to Phase 1 CSV schema (minimal-cost Foundry pipeline)")
    ap.add_argument("--input", required=True, help="Input data file path (CSV/TSV/TXT/JSON/XML)")
    ap.add_argument("--output", required=False, help="Output CSV path (default: alongside input)")
    args = ap.parse_args()

    inp = Path(args.input)
    if not inp.exists():
        raise SystemExit(f"Input not found: {inp}")

    out_dir = inp.parent
    stamp = datetime.now(UTC).strftime("%Y%m%d_%H%M%S")
    out_path = Path(args.output) if args.output else out_dir / f"phase1_converted_{stamp}.csv"

    df_raw = load_any(inp)
    mapping = build_mapping(df_raw)
    df_out = coerce_columns(df_raw, mapping)

    # Write CSV minimal quoting; pandas handles quoting appropriately
    df_out.to_csv(out_path, index=False)

    validation = basic_validate(df_out)

    summary = {
        "ok": True,
        "input": str(inp),
        "output": str(out_path),
        "rows": int(len(df_out)),
        "mapped": {k: (v if v is not None else "") for k, v in mapping.items()},
        "validation": validation,
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
