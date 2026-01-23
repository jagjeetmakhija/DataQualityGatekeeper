import gradio as gr
import pandas as pd
import json
import io

def run_e2e_pipeline(input_file):
    if input_file is None:
        return "Error: No file uploaded. Please upload a CSV file and try again.", []
    try:
        try:
            df = pd.read_csv(input_file)
        except Exception:
            content = input_file.read()
            df = pd.read_csv(io.StringIO(content.decode("utf-8")))
    except Exception as e:
        return f"Error reading CSV: {e}", []

    import platform
    import sys
    import datetime
    try:
        import torch
        device = "cuda" if torch.cuda.is_available() else "cpu"
    except ImportError:
        device = "cpu"

    num_rows = len(df)
    num_cols = len(df.columns)
    missing = df.isnull().sum().sum()
    numeric_df = df.select_dtypes(include='number')
    anomalies = (numeric_df < 0).sum().sum() if not numeric_df.empty else 0

    # Per-column missing values and data types
    col_missing = df.isnull().sum().to_dict()
    col_types = df.dtypes.apply(lambda x: str(x)).to_dict()

    total_cells = num_rows * num_cols
    filled_cells = total_cells - missing
    quality_score = int(round((filled_cells / total_cells) * 100)) if total_cells > 0 else 0
    report = {
        "Status": "APPROVED" if missing == 0 else "REVIEW",
        "Rows": int(num_rows),
        "Columns": int(num_cols),
        "Missing Values": int(missing),
        "Anomalies": int(anomalies),
        "Quality Score": quality_score,
        "Per Column Missing Values": col_missing,
        "Column Data Types": col_types,
        "Run Metadata": {
            "timestamp": datetime.datetime.now().isoformat(),
            "python_version": sys.version,
            "platform": platform.platform(),
            "device": device
        }
    }
    report_path = "validation_report.json"
    with open(report_path, "w") as f:
        json.dump(report, f, indent=2)



    # Determine cause if data has missing values or anomalies, and specify columns with missing values
    cause = []
    # Only check and report missing value columns once
    missing_cols = [col for col, val in col_missing.items() if val > 0]
    if missing > 0:
        cause.append(f"missing values present ({missing}) in columns: {', '.join(missing_cols)}")
    if anomalies > 0:
        cause.append(f"anomalies present ({anomalies})")
    cause_str = f"\nCause: {', '.join(cause)}." if cause else "\nData is clean."

    summary = (
        f"Validation Complete\nStatus: {report['Status']}\nQuality Score: {report['Quality Score']}%\n"
        f"Rows: {num_rows}\nColumns: {num_cols}\nMissing: {missing}\nAnomalies: {anomalies}\nReport: {report_path}\n"
        f"Timestamp: {report['Run Metadata']['timestamp']}\nDevice: {report['Run Metadata']['device']}\nPython: {report['Run Metadata']['python_version'].split()[0]}\n"
        f"Checked Perform: Data loaded, missing values checked, anomalies checked, per-column missing values and types checked, device and environment info captured." + cause_str
    )

    return summary, [report_path]


# --- Spotify-inspired, colorful, emoji-rich UI ---
with gr.Blocks() as demo:
    gr.Markdown("""
<div id='pro-header' style='display:flex;align-items:center;justify-content:center;background:linear-gradient(90deg,#0f2027 0%,#2c5364 60%,#f5ba57 100%);padding:26px 0 16px 0;border-radius:0 0 40px 40px;box-shadow:0 6px 32px #2c536488;'>
    <img src='https://img.icons8.com/color/96/verified-account--v1.png' style='height:70px;margin-right:22px;filter:drop-shadow(0 0 12px #f5ba57);'>
    <div style='text-align:left;'>
        <h1 style='font-size:2.7em;margin:0;color:#fff;letter-spacing:2.5px;font-family:Montserrat,sans-serif;text-shadow:0 2px 12px #0f202799;'>
            <span style='font-size:1.2em;'>📊</span> <span style='color:#f5ba57;'>AI Data Validation</span> <span style='font-size:1.2em;'>🛡️</span>
        </h1>
        <div style='font-size:1.2em;color:#fff;opacity:0.96;text-shadow:0 2px 8px #0f202777;'>
            <b>Upload your CSV, run the pipeline, and download insights!</b> <span style='color:#f5ba57;'>Professional. Private. Powerful.</span>
        </div>
    </div>
</div>
""")
    gr.Markdown("""
<div style='display:flex;justify-content:center;gap:22px;margin:22px 0 0 0;'>
    <div style='background:linear-gradient(135deg,#2c5364 0%,#0f2027 100%);border-radius:22px;padding:22px 28px;box-shadow:0 4px 24px #2c536488;min-width:340px;max-width:420px;'>
        <ul style='list-style:none;padding:0;margin:0;font-size:1.2em;'>
            <li style='margin-bottom:14px;'>
                <span style='font-size:1.5em;'>📂</span> <b style='color:#f5ba57;text-shadow:0 2px 8px #fff;'>Upload</b> <code style='background:#fffbe7;border-radius:6px;padding:2px 8px;'>sample_data.csv</code>
                <img src='https://img.icons8.com/fluency/32/upload.png' style='vertical-align:middle;margin-left:6px;'>
            </li>
            <li style='margin-bottom:14px;'>
                <span style='font-size:1.5em;'>⚡</span> <b style='color:#f5ba57;text-shadow:0 2px 8px #fff;'>Run</b> the pipeline
                <img src='https://img.icons8.com/fluency/32/play.png' style='vertical-align:middle;margin-left:6px;'>
            </li>
            <li>
                <span style='font-size:1.5em;'>📥</span> <b style='color:#f5ba57;text-shadow:0 2px 8px #fff;'>Download</b> results
                <img src='https://img.icons8.com/fluency/32/download.png' style='vertical-align:middle;margin-left:6px;'>
            </li>
        </ul>
    </div>
</div>
""")
    with gr.Row(equal_height=True):
        with gr.Column(scale=1):
            file_input = gr.File(label="Step 1: Upload your CSV data file", file_types=[".csv"], elem_id="file-upload", min_width=0)
        with gr.Column(scale=2):
            btn = gr.Button("Step 2: Run Data Validation Pipeline", elem_id="run-btn", min_width=0)
    with gr.Row():
        output_console = gr.Textbox(label="Step 3: Validation Results & Insights", lines=8, elem_id="output-console")
    with gr.Row():
        output_files = gr.Files(label="Step 4: Download Validation Report", elem_id="output-files")
    btn.click(run_e2e_pipeline, file_input, [output_console, output_files])
    gr.Markdown("""
<div id='pro-footer' style='text-align:center;margin:0;padding:14px 0 0 0;'>
    <span style='font-size:1.5em;'>🏅</span> <b style='color:#f5ba57;font-family:Montserrat,sans-serif;text-shadow:0 2px 8px #0f202799;'>Phase1 Local AI Solution</b> &mdash; <span style='color:#fff;text-shadow:0 2px 8px #0f202777;'>Built with Gradio</span> <span style='font-size:1.5em;'>🚀</span>
</div>
""")

if __name__ == "__main__":
    demo.launch(css="""
    .gradio-container {padding: 0 !important;}
    body {
        background: linear-gradient(135deg, #0f2027 0%, #2c5364 60%, #f5ba57 100%) !important;
        min-height: 100vh;
        font-family: 'Montserrat', 'Segoe UI', Arial, sans-serif;
        animation: bgmove 18s ease-in-out infinite alternate;
    }
    @keyframes bgmove {
        0% {background-position: 0% 50%;}
        100% {background-position: 100% 50%;}
    }
    #pro-header {
        margin-bottom: 0;
        box-shadow: 0 6px 32px #f5ba5788;
    }
    .gradio-container {
        background: transparent !important;
        box-shadow: none !important;
        padding: 0 !important;
    }
    #output-console textarea {
        background: linear-gradient(90deg,#fffbe7 0%,#f5ba57 100%);
        color: #2c5364;
        font-family: 'Fira Mono', 'Consolas', monospace;
        font-size: 1.1em;
        border-radius: 12px;
        border: 2.5px solid #f5ba57;
        box-shadow: 0 2px 12px #2c536488;
    }
    #run-btn button {
        background: linear-gradient(90deg, #f5ba57 0%, #2c5364 100%);
        color: #0f2027;
        font-size: 1.2em;
        border-radius: 10px;
        border: 2.5px solid #f5ba57;
        box-shadow: 0 2px 12px #f5ba5744;
        transition: background 0.2s, color 0.2s;
        font-weight: bold;
        text-shadow: 0 2px 8px #fffbe7cc;
    }
    #run-btn button:hover {
        background: linear-gradient(90deg, #2c5364 0%, #f5ba57 100%);
        color: #fffbe7;
    }
    #file-upload input[type="file"] {
        background: linear-gradient(90deg,#fffbe7 0%,#f5ba57 100%);
        color: #2c5364;
        border-radius: 10px;
        border: 2.5px solid #f5ba57;
        padding: 10px;
        font-size: 1.1em;
        font-weight: bold;
        box-shadow: 0 2px 12px #2c536488;
    }
    #pro-footer {
        color: #fff;
        background: transparent;
        margin-top: 0;
        font-size: 1.2em;
        text-shadow: 0 2px 12px #0f202788;
    }
    #output-files .gr-file-list {
        background: linear-gradient(90deg,#fffbe7 0%,#f5ba57 100%);
        border-radius: 12px;
        border: 2.5px solid #f5ba57;
        color: #2c5364;
        font-size: 1.1em;
        box-shadow: 0 2px 12px #2c536488;
    }
    """)