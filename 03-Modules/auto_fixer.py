import os
import json
import pandas as pd
from datetime import datetime


# ------------------------------------------------------------------
# Centralized Output Folder Resolution
# ------------------------------------------------------------------
def get_run_output_dir():
    """
    Priority:
      1. OUTPUT_RUN_DIR  -> set by PowerShell pipeline
      2. OUTPUT_PATH     -> base output path
      3. ../05-Outputs   -> fallback
    Always returns a run-specific folder.
    """
    run_dir = os.getenv("OUTPUT_RUN_DIR")
    if run_dir:
        return run_dir

    output_root = os.getenv("OUTPUT_PATH")
    if not output_root:
        output_root = os.path.join(os.getcwd(), "..", "05-Outputs")

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    return os.path.join(output_root, f"Output_{ts}")


# ------------------------------------------------------------------
# Initialize output locations for this run
# ------------------------------------------------------------------
OUT_DIR = get_run_output_dir()
os.makedirs(OUT_DIR, exist_ok=True)

AUDIT_DIR = os.path.join(OUT_DIR, "autofix-audit")
os.makedirs(AUDIT_DIR, exist_ok=True)

CLEANED_DATA_PATH = os.path.join(OUT_DIR, "cleaned-data.csv")
ERROR_LOG_PATH = os.path.join(OUT_DIR, "error.log")


# ------------------------------------------------------------------
# Logging Helper
# ------------------------------------------------------------------
def log_error(message: str):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(ERROR_LOG_PATH, "a", encoding="utf-8") as f:
        f.write(f"[{ts}] {message}\n")


# ------------------------------------------------------------------
# Main Auto-Fix Function
# ------------------------------------------------------------------
def run_auto_fix(input_csv_path: str):
    """
    Reads a CSV, applies cleaning rules, writes:
      - cleaned-data.csv
      - autofix-audit/autofix-audit-YYYYMMDD_HHMMSS.json
      - error.log (if needed)
    All inside the current run folder.
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    audit_file = os.path.join(AUDIT_DIR, f"autofix-audit-{timestamp}.json")

    audit = {
        "timestamp": timestamp,
        "inputFile": input_csv_path,
        "outputFile": CLEANED_DATA_PATH,
        "originalRowCount": 0,
        "finalRowCount": 0,
        "rowsRemoved": 0,
        "transformations": []
    }

    try:
        # Load CSV
        df = pd.read_csv(input_csv_path)
        audit["originalRowCount"] = len(df)

        # -------------------------------
        # PLACE YOUR REAL AUTO-FIX LOGIC HERE
        # Examples:
        #   - trim spaces
        #   - normalize column names
        #   - drop empty rows
        #   - enforce schema rules
        # -------------------------------
        df = df.dropna(how="all")
        df.columns = [c.strip() for c in df.columns]

        audit["finalRowCount"] = len(df)
        audit["rowsRemoved"] = audit["originalRowCount"] - audit["finalRowCount"]
        audit["transformations"].append("Dropped empty rows")
        audit["transformations"].append("Trimmed column names")

        # Save cleaned data
        df.to_csv(CLEANED_DATA_PATH, index=False)

        # Save audit JSON
        with open(audit_file, "w", encoding="utf-8") as f:
            json.dump(audit, f, indent=2)

        return {
            "status": "success",
            "output_dir": OUT_DIR,
            "cleaned_data": CLEANED_DATA_PATH,
            "audit_file": audit_file
        }

    except Exception as e:
        log_error(str(e))
        return {
            "status": "error",
            "message": str(e),
            "error_log": ERROR_LOG_PATH
        }


# ------------------------------------------------------------------
# CLI Support (if you run this file directly)
# ------------------------------------------------------------------
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python auto_fixer.py <input_csv_path>")
        sys.exit(1)

    input_csv = sys.argv[1]
    result = run_auto_fix(input_csv)
    print(json.dumps(result, indent=2))
