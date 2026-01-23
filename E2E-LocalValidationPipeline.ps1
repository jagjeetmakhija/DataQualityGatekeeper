# Phase-1 Local Validation Pipeline
param(
    [string]$CSVFilePath = "",
    [string]$ReportOutputPath = ""
)

# Source CONFIG for all paths
. (Join-Path $PSScriptRoot "CONFIG.ps1")

# Use CONFIG defaults if not provided
if ([string]::IsNullOrWhiteSpace($CSVFilePath)) { $CSVFilePath = $script:SampleDataPath }
if ([string]::IsNullOrWhiteSpace($ReportOutputPath)) { $ReportOutputPath = $script:ValidationReportsPath }

Write-Host "`nPhase-1: Local AI Data Validation Pipeline" -ForegroundColor Cyan
Write-Host "Zero Cloud Dependency - 100% Local Processing`n" -ForegroundColor Cyan

# Initialize
if (-not (Test-Path $ReportOutputPath)) {
    New-Item -ItemType Directory -Path $ReportOutputPath -Force | Out-Null
}

# Load CSV data
if (-not (Test-Path $CSVFilePath)) {
    Write-Host "ERROR: CSV file not found at $CSVFilePath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading CSV data..." -ForegroundColor Green
$csvData = @(Import-Csv $CSVFilePath)
Write-Host "Loaded: $($csvData.Count) rows" -ForegroundColor Green

# Get header
$header = $csvData[0].psobject.properties.name

# Calculate quality score
$completionRates = @()
foreach ($row in $csvData) {
    $emptyCount = 0
    foreach ($prop in $header) {
        if ([string]::IsNullOrWhiteSpace($row.$prop)) {
            $emptyCount++
        }
    }
    $rowCompletion = ((($header.Count - $emptyCount) / $header.Count) * 100)
    $completionRates += $rowCompletion
}

if ($completionRates.Count -gt 0) {
    $qualityScore = [Math]::Round(($completionRates | Measure-Object -Average).Average, 0)
} else {
    $qualityScore = 0
}

# Analyze data
Write-Host "Analyzing data structure..." -ForegroundColor Green
$analytics = @{
    TotalRecords = $csvData.Count
    TotalColumns = $header.Count
    FieldAnalysis = @{}
}

foreach ($col in $header) {
    $nonEmpty = 0
    foreach ($row in $csvData) {
        if (-not [string]::IsNullOrWhiteSpace($row.$col)) {
            $nonEmpty++
        }
    }
    
    $completion = [Math]::Round(($nonEmpty / $csvData.Count) * 100, 2)
    $analytics.FieldAnalysis[$col] = @{
        CompletionRate = "$completion%"
        MissingCount = $csvData.Count - $nonEmpty
    }
}

# Detect anomalies
Write-Host "Detecting anomalies..." -ForegroundColor Green
$anomalies = @()
$sampleSize = [Math]::Min(100, $csvData.Count)
for ($i = 0; $i -lt $sampleSize; $i++) {
    $row = $csvData[$i]
    $firstColName = $header[0]
    if ([string]::IsNullOrWhiteSpace($row.($firstColName))) {
        $anomalies += @{
            RowIndex = $i
            Issue = "Missing value in first column"
            Severity = "HIGH"
        }
    }
}

# Generate report
Write-Host "Generating report..." -ForegroundColor Green
$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Phase = "Phase-1: Local Validation"
    Status = if ($qualityScore -ge 80) { "APPROVED" } else { "REQUIRES_REVIEW" }
    DataQuality = @{
        Score = $qualityScore
        Assessment = switch ($qualityScore) {
            { $_ -ge 90 } { "Excellent" }
            { $_ -ge 80 } { "Good" }
            default { "Fair" }
        }
    }
    DescriptiveAnalytics = $analytics
    AnomaliesDetected = $anomalies.Count
    DataResidency = @{
        Status = "COMPLIANT"
        CloudCalls = 0
        LocalBoundary = "C:\MyCode\Local-AIAgent"
    }
}

# Save report
$reportPath = Join-Path $ReportOutputPath "PHASE1_VALIDATION_REPORT.json"
$report | ConvertTo-Json -Depth 10 | Set-Content -Path $reportPath -Encoding UTF8

# Log audit entry
$auditEntry = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Action = "VALIDATION_COMPLETE"
    Status = $report.Status
    CloudCalls = 0
    DataResidency = "LOCAL"
} | ConvertTo-Json

Add-Content -Path (Join-Path $ReportOutputPath "validation_audit.log") -Value $auditEntry -Encoding UTF8

# Display summary
Write-Host "`nValidation Complete" -ForegroundColor Green
Write-Host "Status: $($report.Status)" -ForegroundColor Green
Write-Host "Quality Score: $($report.DataQuality.Score)/100" -ForegroundColor Green
Write-Host "Anomalies: $($anomalies.Count)" -ForegroundColor Yellow
Write-Host "Data Residency: $($report.DataResidency.Status)" -ForegroundColor Green
Write-Host "Report: $reportPath`n" -ForegroundColor Cyan
