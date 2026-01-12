from flask import Flask, jsonify, send_from_directory, request
import pandas as pd
import os
import glob
import json
import subprocess

app = Flask(__name__)


def get_out_dir() -> str:
    """
    Returns the per-run output folder if available (OUTPUT_RUN_DIR),
    otherwise falls back to OUTPUT_PATH, otherwise defaults to ../05-Outputs.
    """
    output_root = os.getenv("OUTPUT_PATH", os.path.join(os.getcwd(), "..", "05-Outputs"))
    run_dir = os.getenv("OUTPUT_RUN_DIR")
    return run_dir or output_root


@app.route('/api/files')
def api_files():
    data_dir = os.path.join('DataFiles')
    files = []
    for fname in sorted(os.listdir(data_dir)):
        if fname.endswith('.csv'):
            fpath = os.path.join(data_dir, fname)
            stat = os.stat(fpath)
            files.append({
                'name': fname,
                'size': f"{stat.st_size/1024:.2f}",
                'modified': pd.to_datetime(stat.st_mtime, unit='s').strftime('%Y-%m-%d %H:%M:%S')
            })
    return jsonify(files)


@app.route('/api/run_pipeline', methods=['POST'])
def api_run_pipeline():
    req = request.get_json()
    filename = req.get('filename')
    if not filename or not filename.endswith('.csv'):
        return jsonify({'status': 'error', 'message': 'Invalid filename'}), 400

    input_path = os.path.join('DataFiles', filename)
    if not os.path.exists(input_path):
        return jsonify({'status': 'error', 'message': 'File not found'}), 404

    try:
        # Run PowerShell pipeline. This will create a new Output_YYYYMMDD_HHMMSS folder.
        result = subprocess.run(
            [
                'powershell', '-ExecutionPolicy', 'Bypass',
                '-File', '01-Scripts/RUN-ALL.ps1',
                '-InputFile', input_path
            ],
            capture_output=True,
            text=True,
            timeout=300
        )
        return jsonify({
            'status': 'ok',
            'stdout': result.stdout,
            'stderr': result.stderr,
            'returncode': result.returncode
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/')
def dashboard():
    return send_from_directory('static', 'dashboard.html')


@app.route('/api/results')
def api_results():
    out_dir = get_out_dir()

    # All audit artifacts live under the run folder
    audit_dir = os.path.join(out_dir, "autofix-audit")
    os.makedirs(audit_dir, exist_ok=True)

    audit_logs = sorted(glob.glob(os.path.join(audit_dir, 'autofix-audit-*.json')))
    step1_audits = sorted(glob.glob(os.path.join(audit_dir, 'step1-audit-*.json')))
    trace_files = sorted(glob.glob(os.path.join(audit_dir, 'traceability-*.csv')))

    # Cleaned data should also be inside the run folder
    cleaned_data_path = os.path.join(out_dir, 'cleaned-data.csv')

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

    # Latest traceability file preview
    if trace_files:
        with open(trace_files[-1], 'r') as f:
            trace_lines = f.readlines()
        summary['traceability'] = {
            'header': trace_lines[0].strip() if trace_lines else "",
            'rows': trace_lines[1:6] if len(trace_lines) > 1 else []
        }
    else:
        summary['traceability'] = None

    # Helpful for UI/debugging
    summary['output_dir'] = out_dir

    return jsonify(summary)


if __name__ == '__main__':
    # Respect launch.json / environment variables
    debug_on = os.getenv("FLASK_DEBUG", "0") == "1"
    app.run(debug=debug_on)
