

from flask import Flask, jsonify, send_from_directory
import pandas as pd
import os
import glob
import json


app = Flask(__name__)


@app.route('/')
def dashboard():
    return send_from_directory('static', 'dashboard.html')


@app.route('/api/results')
def api_results():
    # Find latest audit log
    audit_dir = os.path.join('05-Outputs', 'autofix-audit')
    audit_logs = sorted(glob.glob(os.path.join(audit_dir, 'autofix-audit-*.json')))
    step1_audits = sorted(glob.glob(os.path.join(audit_dir, 'step1-audit-*.json')))
    trace_files = sorted(glob.glob(os.path.join(audit_dir, 'traceability-*.csv')))
    cleaned_data_path = os.path.join('05-Outputs', 'cleaned-data.csv')
    summary = {}

    # Cleaned data summary
    if os.path.exists(cleaned_data_path):
        df = pd.read_csv(cleaned_data_path)
        summary['cleaned_row_count'] = len(df)
        summary['columns'] = list(df.columns)
    else:
        summary['cleaned_row_count'] = 0
        summary['columns'] = []

    # Latest audit log
    if audit_logs:
        with open(audit_logs[-1], 'r') as f:
            audit = json.load(f)
        summary['audit'] = {
            'timestamp': audit.get('timestamp'),
            'inputFile': audit.get('inputFile'),
            'outputFile': audit.get('outputFile'),
            'originalRowCount': audit.get('originalRowCount'),
            'finalRowCount': audit.get('finalRowCount'),
            'rowsRemoved': audit.get('rowsRemoved'),
            'transformations': audit.get('transformations', [])
        }
    else:
        summary['audit'] = None

    # Latest step1 audit
    if step1_audits:
        with open(step1_audits[-1], 'r') as f:
            step1 = json.load(f)
        summary['step1_audit'] = step1
    else:
        summary['step1_audit'] = None

    # Latest traceability file
    if trace_files:
        with open(trace_files[-1], 'r') as f:
            trace_lines = f.readlines()
        summary['traceability'] = {
            'header': trace_lines[0].strip(),
            'rows': trace_lines[1:6]  # show first 5 rows for preview
        }
    else:
        summary['traceability'] = None

    return jsonify(summary)


if __name__ == '__main__':
    app.run(debug=True)
