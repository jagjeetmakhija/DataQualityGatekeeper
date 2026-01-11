# 🚀 EXECUTION CHEATSHEET

## ⚡ Quick Commands Reference

### Setup (One-Time)
```powershell
cd Phase1-LocalInsights
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Run Complete Pipeline
```powershell
cd 01-Scripts
.\RUN-ALL.ps1 -InputFile "C:\Path\To\data.csv"
```

### Run Individual Steps
```powershell
# Step 1: Auto-Fix
.\Step1-AutoFix.ps1 -InputFile "C:\Path\To\data.csv"

# Step 2: Validation
.\Step2-Validate.ps1 -InputFile "05-Outputs\autofix-audit\cleaned-data.csv"
```

### Start UI
```powershell
cd 04-UI
python app.py
# Open: http://localhost:5000
```

---

## 📁 Output Locations

| Output | Location |
|--------|----------|
| Cleaned Data | `05-Outputs/autofix-audit/cleaned-data.csv` |
| Auto-Fix Audit | `05-Outputs/autofix-audit/autofix-audit-*.json` |
| Validation Report | `05-Outputs/validation-reports/validation-report-*.json` |
| Traceability Matrix | `05-Outputs/*/traceability-*.csv` |
| Execution Logs | `05-Outputs/*/step*-audit-*.json` |

---

## 🎨 Console Icons Guide

| Icon | Meaning | Action |
|------|---------|--------|
| ✅ | Success | Continue |
| ❌ | Error | Fix and retry |
| ⚠️ | Warning | Review |
| ℹ️ | Info | Note |
| ⏳ | Processing | Wait |
| 📊 | Metric | Review value |

---

## 🔧 Common Issues & Fixes

### "Python not found"
```powershell
.\.venv\Scripts\Activate.ps1
python --version  # Should show 3.10+
```

### "Validation FAILED"
1. Read error messages
2. Open validation report JSON
3. Fix source data
4. Re-run Step 1

### "Module not found"
```powershell
pip install pandas openpyxl flask jsonschema python-dateutil
```

---

## 📊 Success Indicators

✅ Console shows: `STEP X COMPLETED SUCCESSFULLY`  
✅ Validation status: `PASS`  
✅ Files exist in `05-Outputs/`  
✅ UI loads at http://localhost:5000  
✅ Exit code: `0` (check with `echo $LASTEXITCODE`)

---

## ❌ Failure Indicators

❌ Console shows: `STEP X FAILED`  
❌ Validation status: `FAIL`  
❌ Missing output files  
❌ Exit code: `1`

---

## 📋 Minimum Data Requirements

Required columns:
- AccountName
- OpportunityID (unique)
- Stage
- CreatedDate
- EstimatedValue

---

## 🗂️ File Structure Quick Reference

```
Phase1-LocalInsights/
├── 01-Scripts/          ← PowerShell scripts (run these)
├── 02-Schema/           ← Validation rules
├── 03-Modules/          ← Python modules (auto-executed)
├── 04-UI/               ← Dashboard (python app.py)
├── 05-Outputs/          ← All results
└── 06-Documentation/    ← Detailed docs
```

---

## ⏱️ Expected Timings

| Step | Duration |
|------|----------|
| Setup (one-time) | 5-10 min |
| Step 1: Auto-Fix | 10-30 sec |
| Step 2: Validation | 5-15 sec |
| Complete Pipeline | 30-60 sec |
| UI Startup | 5 sec |

---

## 🎯 Quick Decision Tree

```
Need to start? → Read QUICKSTART.md
Need to troubleshoot? → Read EXECUTION-FLOW.md
Need to understand system? → Read ARCHITECTURE.md
Need to explain to CX? → Read CX-TRUST-CHECKLIST.md
Need audit trail? → Check traceability-*.csv
Need to see what happened? → Check *-audit-*.json
```

---

## 📞 Support Priority

1. **Check console error messages** (usually self-explanatory)
2. **Review audit logs** in `05-Outputs/`
3. **Open traceability matrix** in Excel
4. **Read EXECUTION-FLOW.md** (troubleshooting section)

---

## 💡 Pro Tips

### Save Console Output
```powershell
.\RUN-ALL.ps1 -InputFile "data.csv" | Tee-Object -FilePath "run-log.txt"
```

### Check Exit Code
```powershell
echo $LASTEXITCODE  # 0 = success, 1 = failure
```

### Skip Validation for Testing
```powershell
.\RUN-ALL.ps1 -InputFile "data.csv" -SkipValidation
```

### View Latest Output
```powershell
explorer 05-Outputs\
```

---

## 🔐 Security Reminders

✅ 100% localhost - no cloud  
✅ No external APIs  
✅ No telemetry  
✅ Internet not required (after setup)  
✅ All data stays on your machine

---

## 📚 Documentation Quick Links

- **[QUICKSTART.md](QUICKSTART.md)** - 5 min start
- **[VISUAL-WALKTHROUGH.md](VISUAL-WALKTHROUGH.md)** - Console output guide
- **[README.md](README.md)** - Complete overview
- **[EXECUTION-FLOW.md](06-Documentation/EXECUTION-FLOW.md)** - Detailed steps
- **[ARCHITECTURE.md](06-Documentation/ARCHITECTURE.md)** - System design
- **[TRACEABILITY-MATRIX.md](06-Documentation/TRACEABILITY-MATRIX.md)** - Audit guide
- **[CX-TRUST-CHECKLIST.md](06-Documentation/CX-TRUST-CHECKLIST.md)** - Security validation

---

**🎉 Keep this handy for quick reference during execution!**

---

**Version:** 1.0  
**Last Updated:** 2026-01-10
