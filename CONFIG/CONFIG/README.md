# CONFIG - Central Configuration Hub

**Location**: `Local-AIAgent/CONFIG/`

All configuration artifacts, documentation, schemas, and templates are centralized in this folder for clean organization and easy maintenance.

---

## 📁 Folder Structure

```
CONFIG/
├── docs/                          # Documentation & guides
│   ├── README.md                 # Main overview
│   ├── PHASE1_SUMMARY.md         # Technical implementation details
│   ├── PHASE1_STATUS.md          # Project status & live results
│   ├── PHASE1_EXAMPLES.md        # CLI/API usage examples
│   └── FOLDER_STRUCTURE.md       # Original folder organization guide
│
├── schemas/                       # Data validation schemas
│   ├── Phase1_Schema.json        # Phase-1 CSV schema definition
│   └── [Custom schemas]          # Custom validation rules
│
├── azure-foundry/                # Azure Foundry integration (optional)
│   ├── README_FOUNDRY.md         # Foundry setup guide
│   ├── environment-conda.yml     # Conda environment
│   ├── requirements-foundry.txt  # Python dependencies
│   ├── foundry_min_cost_pipeline.py
│   ├── local_insights_optional.py
│   └── [YAML job configs]
│
├── data/                         # Sample/test data files
│   └── [Data files]
│
└── templates/                    # (Reserved for future use)
```

---

## 🔧 Configuration Reference

All paths are centralized and configurable through **`CONFIG.ps1`** located at the Local-AIAgent root.

### Available Paths

| Path Type | Variable | Reference |
|-----------|----------|-----------|
| **CONFIG Root** | `$script:ConfigPath` | `CONFIG/` |
| **Schemas** | `$script:SchemaPath` | `CONFIG/schemas/` |
| **Documentation** | `$script:DocsPath` | `CONFIG/docs/` |
| **Sample Data** | `$script:DataPath` | `CONFIG/data/` |
| **Azure** | `$script:AzureFoundryPath` | `CONFIG/azure-foundry/` |
| **Outputs** | `$script:OutputPath` | `outputs/` (root level) |
| **Reports** | `$script:ValidationReportsPath` | `Validation/Reports/` (root level) |
| **UI** | `$script:UIPath` | `ui/` (root level) |

### How Scripts Reference CONFIG

All PowerShell scripts now source the central `CONFIG.ps1`:

```powershell
# At the top of any script:
. (Join-Path $PSScriptRoot "CONFIG.ps1")

# Then use predefined variables:
$schemaFile = Join-Path $script:SchemaPath "Phase1_Schema.json"
$sampleData = $script:SampleDataPath
$reportDir = $script:ValidationReportsPath
```

---

## 📄 Documentation Files

Located in `CONFIG/docs/`:

1. **README.md** - Quick start guide and overview
2. **PHASE1_SUMMARY.md** - Technical deep-dive on signal definitions
3. **PHASE1_STATUS.md** - Current implementation status
4. **PHASE1_EXAMPLES.md** - CLI/API usage examples
5. **FOLDER_STRUCTURE.md** - Original folder organization documentation

---

## 🔐 Schemas

Located in `CONFIG/schemas/`:

### Phase1_Schema.json
Defines validation rules for Phase-1 CSV files:
- Required columns
- Data types
- Allowed values
- Null thresholds

```json
{
  "required_columns": ["MARKET", "SITE", "CLIENT", ...],
  "column_types": {
    "CAPACITY (MW)": "float",
    ...
  }
}
```

---

## ☁️ Azure Foundry Configuration

Located in `CONFIG/azure-foundry/`:

For cloud-based Azure Foundry deployment (optional, not required for local Phase-1):
- Conda environment specifications
- Python dependency lists
- YAML job configurations
- Cost-optimized pipeline definitions

**Note**: Phase-1 runs 100% locally without cloud components.

---

## 🎯 Using CONFIG in Your Workflows

### Example 1: Loading a Schema

```powershell
. (Join-Path $PSScriptRoot "CONFIG.ps1")
$schema = Get-Content $script:DefaultSchemaPath | ConvertFrom-Json
```

### Example 2: Getting a Path by Type

```powershell
. (Join-Path $PSScriptRoot "CONFIG.ps1")
$docsPath = Get-ConfigPath -PathType 'docs'
$schemaPath = Get-ConfigPath -PathType 'schema'
```

### Example 3: Accessing Sample Data

```powershell
. (Join-Path $PSScriptRoot "CONFIG.ps1")
$data = Import-Csv $script:SampleDataPath
```

---

## 📋 Best Practices

✅ **Always Source CONFIG.ps1** at the start of any script
✅ **Use Predefined Variables** instead of hardcoded paths
✅ **Keep Artifacts in CONFIG** for centralized management
✅ **Update CONFIG.ps1** if new paths are added
✅ **Reference Documentation** from CONFIG/docs/

❌ **Don't hardcode paths** like `C:\MyCode\Local-AIAgent\...`
❌ **Don't create duplicates** of CONFIG files
❌ **Don't modify CONFIG.ps1** paths without testing

---

## 🔄 Migration from Old Structure

All legacy paths have been consolidated:

| Old Path | New Path |
|----------|----------|
| `Local-AIAgent/schemas/` | `CONFIG/schemas/` |
| `Local-AIAgent/*.md` | `CONFIG/docs/` |
| `Local-AIAgent/data/` | `CONFIG/data/` |
| `Local-AIAgent/azure-foundry/` | `CONFIG/azure-foundry/` |

Scripts have been updated to use `CONFIG.ps1` for automatic path resolution.

---

## 📝 Adding New Configuration Items

To add new CONFIG items:

1. Create subfolder in `CONFIG/` (e.g., `CONFIG/custom-rules/`)
2. Add variable to `CONFIG.ps1`:
   ```powershell
   $script:CustomRulesPath = Join-Path $ConfigPath "custom-rules"
   ```
3. Add case to `Get-ConfigPath` function:
   ```powershell
   'custom' { return $script:CustomRulesPath }
   ```
4. Use in scripts via `Get-ConfigPath -PathType 'custom'`

---

## ✨ Summary

**CONFIG provides**:
- ✅ Centralized artifact management
- ✅ Single source of truth for paths
- ✅ Clean folder organization
- ✅ Easy maintenance and updates
- ✅ Scalable configuration model

**Local-AIAgent now has a professional, enterprise-ready structure!**

---

**Last Updated**: January 9, 2026
**Status**: CONFIG structure in place, all scripts updated
