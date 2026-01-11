"""
═══════════════════════════════════════════════════════════════
✅ VALIDATOR MODULE
═══════════════════════════════════════════════════════════════
Purpose: Validate data against schema (GATE checkpoint)
Version: 1.0
No AI/ML - rule-based validation only
═══════════════════════════════════════════════════════════════
"""

import sys
import json
import pandas as pd
from datetime import datetime
from pathlib import Path

def load_schema(schema_file):
    """Load schema definition"""
    with open(schema_file, 'r') as f:
        return json.load(f)

def validate_required_columns(df, schema):
    """Check if all required columns exist"""
    required = schema['properties']['requiredColumns']['default']
    missing = [col for col in required if col not in df.columns]
    
    if missing:
        return False, f"Missing required columns: {', '.join(missing)}", len(df), 0, len(df)
    return True, "All required columns present", len(df), len(df), 0

def validate_data_types(df, schema):
    """Validate data types for each column"""
    col_defs = schema['properties']['columnDefinitions']['properties']
    
    total_errors = 0
    details = []
    
    for col_name, col_def in col_defs.items():
        if col_name not in df.columns:
            continue
        
        expected_type = col_def['properties']['dataType']['enum'][0]
        
        if expected_type in ['numeric', 'float', 'integer']:
            non_numeric = df[df[col_name].notna()][col_name].apply(lambda x: not isinstance(x, (int, float))).sum()
            if non_numeric > 0:
                total_errors += non_numeric
                details.append(f"{col_name}: {non_numeric} non-numeric values")
        
        elif expected_type == 'date':
            try:
                pd.to_datetime(df[col_name], errors='coerce')
            except Exception:
                pass
    
    passed = len(df) - total_errors
    return total_errors == 0, "; ".join(details) if details else "All data types valid", len(df), passed, total_errors

def validate_null_thresholds(df, schema):
    """Check null percentages against thresholds"""
    null_thresholds = schema['properties']['validationRules']['properties']['nullThresholds']['properties']
    
    violations = []
    total_violations = 0
    
    for col in df.columns:
        null_pct = (df[col].isna().sum() / len(df)) * 100
        threshold = null_thresholds.get(col, null_thresholds.get('_default', {'default': 50})).get('default', 50)
        
        if null_pct > threshold:
            violations.append(f"{col}: {null_pct:.1f}% nulls (threshold: {threshold}%)")
            total_violations += 1
    
    passed = total_violations == 0
    return passed, "; ".join(violations) if violations else "All null thresholds met", len(df.columns), len(df.columns) - total_violations, total_violations

def validate_allowed_values(df, schema_dir):
    """Validate categorical values against allowed values"""
    allowed_values_file = Path(schema_dir) / 'allowed-values.json'
    
    if not allowed_values_file.exists():
        return True, "No allowed values file found", 0, 0, 0
    
    with open(allowed_values_file, 'r') as f:
        allowed_values = json.load(f)
    
    violations = []
    total_violations = 0
    
    for field, config in allowed_values.items():
        if field in ['description', 'version', 'lastUpdated', 'normalizationRules']:
            continue
        
        if field not in df.columns:
            continue
        
        standard_values = config.get('standardValues', [])
        if not standard_values:
            continue
        
        invalid = df[~df[field].isin(standard_values) & df[field].notna()]
        if len(invalid) > 0:
            violations.append(f"{field}: {len(invalid)} invalid values")
            total_violations += len(invalid)
    
    passed = total_violations == 0
    return passed, "; ".join(violations) if violations else "All categorical values valid", len(df), len(df) - total_violations, total_violations

def validate_data(input_file, schema_file, report_file):
    """Main validation pipeline"""
    print(f"Loading data from: {input_file}")
    df = pd.read_csv(input_file) if input_file.endswith('.csv') else pd.read_excel(input_file)
    
    print(f"Loading schema from: {schema_file}")
    schema = load_schema(schema_file)
    schema_dir = Path(schema_file).parent
    
    print(f"Validating {len(df)} rows...")
    
    # Initialize report
    report = {
        "timestamp": datetime.now().isoformat(),
        "inputFile": input_file,
        "schemaFile": schema_file,
        "rowCount": len(df),
        "overallStatus": "PASS",
        "summary": {
            "errorCount": 0,
            "warningCount": 0,
            "infoCount": 0
        },
        "rules": [],
        "fixInstructions": []
    }
    
    # Validation rules
    validation_rules = [
        ("VAL-001", "Required Columns Check", "DataQuality", "error", validate_required_columns, (df, schema)),
        ("VAL-002", "Data Type Validation", "DataQuality", "error", validate_data_types, (df, schema)),
        ("VAL-003", "Null Threshold Check", "DataQuality", "warning", validate_null_thresholds, (df, schema)),
        ("VAL-004", "Allowed Values Check", "BusinessLogic", "warning", validate_allowed_values, (df, schema_dir)),
    ]
    
    for rule_id, rule_name, category, severity, func, args in validation_rules:
        try:
            print(f"Validating: {rule_name}...")
            passed, message, rows_checked, rows_passed, rows_failed = func(*args)
            
            rule_result = {
                "ruleID": rule_id,
                "ruleName": rule_name,
                "category": category,
                "severity": severity,
                "passed": passed,
                "rowsChecked": rows_checked,
                "rowsPassed": rows_passed,
                "rowsFailed": rows_failed,
                "rowsWarning": 0 if passed else rows_failed,
                "message": message
            }
            
            report["rules"].append(rule_result)
            
            # Update summary
            if not passed:
                if severity == "error":
                    report["summary"]["errorCount"] += 1
                    report["overallStatus"] = "FAIL"
                    report["fixInstructions"].append(f"Fix {rule_name}: {message}")
                elif severity == "warning":
                    report["summary"]["warningCount"] += 1
            
            icon = "PASS" if passed else ("FAIL" if severity == "error" else "WARN")
            print(f"{icon} {rule_name}: {message}")
        
        except Exception as e:
            print(f"ERROR {rule_name}: {e}")
            report["rules"].append({
                "ruleID": rule_id,
                "ruleName": rule_name,
                "passed": False,
                "message": f"Validation error: {e}"
            })
            report["summary"]["errorCount"] += 1
            report["overallStatus"] = "FAIL"
    
    # Save report
    print(f"Saving validation report to: {report_file}")
    Path(report_file).parent.mkdir(parents=True, exist_ok=True)
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    status_icon = "PASS" if report["overallStatus"] == "PASS" else "FAIL"
    print(f"{status_icon} Validation {report['overallStatus']}: {report['summary']['errorCount']} errors, {report['summary']['warningCount']} warnings")
    
    return 0 if report["overallStatus"] == "PASS" else 1

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python validator.py <input_file> <schema_file> <report_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    schema_file = sys.argv[2]
    report_file = sys.argv[3]
    
    try:
        exit_code = validate_data(input_file, schema_file, report_file)
        sys.exit(exit_code)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
