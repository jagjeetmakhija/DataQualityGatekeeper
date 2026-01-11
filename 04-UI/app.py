"""
═══════════════════════════════════════════════════════════════
🖥️ PHASE-1 LOCAL INSIGHTS - DASHBOARD UI
═══════════════════════════════════════════════════════════════
Purpose: Executive-friendly localhost dashboard (NO external connections)
Version: 1.0
Runs on: http://localhost:5000
═══════════════════════════════════════════════════════════════
"""

from flask import Flask, render_template, send_file, jsonify, request, redirect, url_for, flash
import json
import os
from pathlib import Path
from datetime import datetime
import glob
import subprocess
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['SECRET_KEY'] = 'phase1-local-insights-secure-key'
app.config['UPLOAD_FOLDER'] = '../uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
ALLOWED_EXTENSIONS = {'csv', 'xlsx', 'xls'}

# Create upload directory if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# ═══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_uploaded_files():
    """Get list of uploaded files"""
    upload_dir = Path(app.config['UPLOAD_FOLDER'])
    if not upload_dir.exists():
        return []
    files = []
    for file in upload_dir.glob('*'):
        if file.is_file():
            files.append({
                'name': file.name,
                'path': str(file),
                'size': file.stat().st_size,
                'modified': datetime.fromtimestamp(file.stat().st_mtime).strftime('%Y-%m-%d %H:%M:%S')
            })
    return sorted(files, key=lambda x: x['modified'], reverse=True)

def get_latest_file(pattern):
    """Get most recent file matching pattern"""
    files = glob.glob(pattern)
    if not files:
        return None
    return max(files, key=os.path.getctime)

def load_json_report(file_path):
    """Load JSON report safely"""
    if not file_path or not os.path.exists(file_path):
        return None
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except Exception:
        return None

def get_all_outputs():
    """Scan outputs directory for all generated files"""
    outputs_dir = Path("../05-Outputs")
    
    outputs = {
        "autofix": {
            "audit": get_latest_file(str(outputs_dir / "autofix-audit" / "autofix-audit-*.json")),
            "data": get_latest_file(str(outputs_dir / "autofix-audit" / "cleaned-data.csv")),
            "traceability": get_latest_file(str(outputs_dir / "autofix-audit" / "traceability-*.csv"))
        },
        "validation": {
            "report": get_latest_file(str(outputs_dir / "validation-reports" / "validation-report-*.json")),
            "traceability": get_latest_file(str(outputs_dir / "validation-reports" / "traceability-*.csv"))
        },
        "quality": {
            "report": get_latest_file(str(outputs_dir / "quality-reports" / "quality-*.json"))
        }
    }
    
    return outputs

# ═══════════════════════════════════════════════════════════════
# ROUTES
# ═══════════════════════════════════════════════════════════════

@app.route('/')
def dashboard():
    """Main dashboard"""
    outputs = get_all_outputs()
    
    # Load reports
    autofix_audit = load_json_report(outputs["autofix"]["audit"])
    validation_report = load_json_report(outputs["validation"]["report"])
    
    # Get uploaded files
    uploaded_files = get_uploaded_files()
    
    # Prepare dashboard data
    data = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "autofix": autofix_audit,
        "validation": validation_report,
        "outputs": outputs,
        "uploaded_files": uploaded_files
    }
    
    return render_template('dashboard.html', data=data)

@app.route('/upload', methods=['POST'])
def upload_file():
    """Handle file upload"""
    if 'file' not in request.files:
        flash('No file selected', 'error')
        return redirect(url_for('dashboard'))
    
    file = request.files['file']
    
    if file.filename == '':
        flash('No file selected', 'error')
        return redirect(url_for('dashboard'))
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        # Add timestamp to avoid overwrites
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        name, ext = os.path.splitext(filename)
        filename = f"{name}_{timestamp}{ext}"
        
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        flash(f'File uploaded successfully: {filename}', 'success')
        return redirect(url_for('dashboard'))
    else:
        flash('Invalid file type. Only CSV and Excel files allowed.', 'error')
        return redirect(url_for('dashboard'))

@app.route('/run-pipeline', methods=['POST'])
def run_pipeline():
    """Execute the pipeline on selected file using Python modules directly"""
    filename = request.form.get('filename')
    
    if not filename:
        flash('No file selected', 'error')
        return redirect(url_for('dashboard'))
    
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    
    if not os.path.exists(filepath):
        flash('File not found', 'error')
        return redirect(url_for('dashboard'))
    
    try:
        # Step 1: Auto-fix data
        auto_fixer_script = os.path.abspath('../03-Modules/auto_fixer.py')
        cleaned_file = os.path.abspath('../05-Outputs/cleaned-data.csv')
        audit_file = os.path.abspath('../05-Outputs/autofix-audit/audit-log.json')
        
        result_autofix = subprocess.run(
            ['python', auto_fixer_script, filepath, cleaned_file, audit_file],
            capture_output=True,
            text=True
        )
        
        if result_autofix.returncode != 0:
            flash(f'Auto-fix failed: {result_autofix.stderr}', 'error')
            return redirect(url_for('dashboard'))
        
        # Step 2: Validate data
        validator_script = os.path.abspath('../03-Modules/validator.py')
        schema_file = os.path.abspath('../02-Schema/schema.json')
        report_file = os.path.abspath('../05-Outputs/validation-reports/report.json')
        
        result_validate = subprocess.run(
            ['python', validator_script, cleaned_file, schema_file, report_file],
            capture_output=True,
            text=True
        )
        
        if result_validate.returncode == 0:
            flash(f'Pipeline executed successfully on {filename}! ✅ Validation PASSED', 'success')
        else:
            flash(f'Pipeline completed. ⚠️ Validation has warnings. Check report.', 'warning')
            
    except Exception as e:
        flash(f'Error executing pipeline: {str(e)}', 'error')
    
    return redirect(url_for('dashboard'))

@app.route('/api/status')
def api_status():
    """API endpoint for status checks"""
    outputs = get_all_outputs()
    
    status = {
        "system": "online",
        "timestamp": datetime.now().isoformat(),
        "mode": "localhost-only",
        "autofix_completed": outputs["autofix"]["audit"] is not None,
        "validation_completed": outputs["validation"]["report"] is not None
    }
    
    return jsonify(status)

@app.route('/download/<category>/<filename>')
def download_file(category, filename):
    """Download output files"""
    outputs_dir = Path("../05-Outputs")
    file_path = outputs_dir / category / filename
    
    if file_path.exists():
        return send_file(str(file_path), as_attachment=True)
    else:
        return "File not found", 404

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("")
    print("═" * 70)
    print("  🖥️  PHASE-1 LOCAL INSIGHTS DASHBOARD")
    print("═" * 70)
    print("")
    print("  🌐 Running on: http://localhost:5000")
    print("  🔒 Localhost only - NO external connections")
    print("  📊 Displaying results from: ../05-Outputs/")
    print("")
    print("  ⚠️  Do NOT share this URL publicly!")
    print("  ✅ Safe to view on your local machine only")
    print("")
    print("  Press Ctrl+C to stop the server")
    print("")
    print("═" * 70)
    print("")
    
    app.run(host='127.0.0.1', port=5000, debug=False)
