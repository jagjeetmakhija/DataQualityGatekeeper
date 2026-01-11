"""
═══════════════════════════════════════════════════════════════
🧹 AUTO-FIXER MODULE
═══════════════════════════════════════════════════════════════
Purpose: Clean and normalize data before validation
Version: 1.0
No AI/ML - purely deterministic transformations
═══════════════════════════════════════════════════════════════
"""

import sys
import json
import pandas as pd
from datetime import datetime
from pathlib import Path

def trim_whitespace(df):
    """Trim whitespace from headers and string values"""
    # Trim column names
    df.columns = df.columns.str.strip()
    
    # Trim string values
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = df[col].str.strip() if df[col].dtype == 'object' else df[col]
    
    return df, len(df)

def normalize_casing(df, categorical_columns=None):
    """Normalize casing for categorical columns"""
    if categorical_columns is None:
        categorical_columns = ['Stage', 'Status', 'Region', 'Priority']
    
    affected = 0
    for col in categorical_columns:
        if col in df.columns:
            df[col] = df[col].str.title()  # Convert to Title Case
            affected += len(df)
    
    return df, affected

def standardize_dates(df, date_columns=None):
    """Convert dates to ISO format (YYYY-MM-DD)"""
    if date_columns is None:
        date_columns = ['CreatedDate', 'LastActivityDate', 'ClosedDate']
    
    affected = 0
    for col in date_columns:
        if col in df.columns:
            try:
                df[col] = pd.to_datetime(df[col], errors='coerce').dt.strftime('%Y-%m-%d')
                affected += df[col].notna().sum()
            except Exception:
                pass
    
    return df, affected

def coerce_numeric_fields(df, numeric_columns=None):
    """Remove commas and convert to numeric"""
    if numeric_columns is None:
        numeric_columns = ['EstimatedValue', 'Probability', 'ContactCount']
    
    affected = 0
    for col in numeric_columns:
        if col in df.columns:
            # Remove commas and convert to numeric
            if df[col].dtype == 'object':
                df[col] = df[col].str.replace(',', '').str.replace('$', '')
                df[col] = pd.to_numeric(df[col], errors='coerce')
                affected += len(df)
    
    return df, affected

def normalize_categorical_values(df):
    """Normalize known categorical values using synonyms"""
    
    # Stage synonyms
    stage_mapping = {
        'new': 'Lead', 'initial': 'Lead', 'prospecting': 'Lead',
        'qualified lead': 'Qualified', 'sql': 'Qualified', 'mql': 'Qualified',
        'proposed': 'Proposal', 'quote sent': 'Proposal',
        'negotiating': 'Negotiation', 'contract review': 'Negotiation',
        'won': 'Closed-Won', 'closed won': 'Closed-Won', 'success': 'Closed-Won',
        'lost': 'Closed-Lost', 'closed lost': 'Closed-Lost', 'rejected': 'Closed-Lost',
        'paused': 'On-Hold', 'deferred': 'On-Hold', 'postponed': 'On-Hold'
    }
    
    affected = 0
    if 'Stage' in df.columns:
        df['Stage'] = df['Stage'].str.lower().map(lambda x: stage_mapping.get(x, x.title() if isinstance(x, str) else x))
        affected += len(df)
    
    return df, affected

def remove_empty_rows(df):
    """Remove rows where all values are NaN"""
    original_count = len(df)
    df = df.dropna(how='all')
    removed = original_count - len(df)
    return df, removed

def deduplicate(df, id_column='OpportunityID'):
    """Remove exact duplicate rows"""
    original_count = len(df)
    df = df.drop_duplicates(subset=[id_column], keep='first') if id_column in df.columns else df.drop_duplicates()
    removed = original_count - len(df)
    return df, removed

def auto_fix_data(input_file, output_file, audit_file):
    """Main auto-fix pipeline"""
    
    print(f"📂 Loading data from: {input_file}")
    
    # Load data
    if input_file.endswith('.csv'):
        df = pd.read_csv(input_file)
    elif input_file.endswith(('.xlsx', '.xls')):
        df = pd.read_excel(input_file)
    else:
        raise ValueError("Unsupported file format. Use CSV or Excel.")
    
    original_rows = len(df)
    print(f"📊 Input rows: {original_rows}")
    
    # Initialize audit log
    audit = {
        "timestamp": datetime.now().isoformat(),
        "inputFile": input_file,
        "outputFile": output_file,
        "originalRowCount": original_rows,
        "transformations": []
    }
    
    # Apply transformations
    transformations = [
        ("AUTOFIX-001", "Trim Headers and Values", trim_whitespace, {}),
        ("AUTOFIX-002", "Normalize Casing", normalize_casing, {}),
        ("AUTOFIX-003", "Standardize Dates", standardize_dates, {}),
        ("AUTOFIX-004", "Coerce Numeric Fields", coerce_numeric_fields, {}),
        ("AUTOFIX-005", "Normalize Categorical Values", normalize_categorical_values, {}),
        ("AUTOFIX-006", "Remove Empty Rows", remove_empty_rows, {}),
        ("AUTOFIX-007", "De-duplicate Rows", deduplicate, {}),
    ]
    
    for rule_id, rule_name, func, kwargs in transformations:
        try:
            print(f"⏳ Applying: {rule_name}...")
            df, affected = func(df, **kwargs)
            
            audit["transformations"].append({
                "ruleID": rule_id,
                "ruleName": rule_name,
                "status": "applied",
                "rowsAffected": affected,
                "details": f"{affected} rows affected"
            })
            print(f"✅ {rule_name}: {affected} rows affected")
        
        except Exception as e:
            audit["transformations"].append({
                "ruleID": rule_id,
                "ruleName": rule_name,
                "status": "failed",
                "rowsAffected": 0,
                "details": str(e)
            })
            print(f"⚠️  {rule_name}: FAILED - {e}")
    
    # Final counts
    final_rows = len(df)
    audit["finalRowCount"] = final_rows
    audit["rowsRemoved"] = original_rows - final_rows
    
    # Save cleaned data
    print(f"💾 Saving cleaned data to: {output_file}")
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_file, index=False)
    
    # Save audit log
    print(f"📝 Saving audit log to: {audit_file}")
    Path(audit_file).parent.mkdir(parents=True, exist_ok=True)
    with open(audit_file, 'w') as f:
        json.dump(audit, f, indent=2)
    
    print(f"✅ Auto-fix completed: {original_rows} → {final_rows} rows")
    return 0

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python auto_fixer.py <input_file> <output_file> <audit_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    audit_file = sys.argv[3]
    
    try:
        exit_code = auto_fix_data(input_file, output_file, audit_file)
        sys.exit(exit_code)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
