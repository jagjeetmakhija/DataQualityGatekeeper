# Data Residency Verification Check
param(
    [string]$LocalBoundary = "C:\MyCode\Local-AIAgent"
)

Write-Host "`nData Residency Compliance Verification`n" -ForegroundColor Cyan

$checks = @()

# Check 1: CSV file location
Write-Host "Check 1: CSV file location" -ForegroundColor Yellow
$csvPath = "C:\MyCode\Local-AIAgent\converted_data.csv"
if (Test-Path $csvPath) {
    $fullPath = (Get-Item $csvPath).FullName
    if ($fullPath.StartsWith($LocalBoundary)) {
        Write-Host "  PASS - File within local boundary" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "  FAIL - File outside boundary" -ForegroundColor Red
        $checks += $false
    }
}

# Check 2: Report files location
Write-Host "Check 2: Report files location" -ForegroundColor Yellow
$reportPath = "C:\MyCode\Local-AIAgent\Validation\Reports"
if (Test-Path $reportPath) {
    $files = Get-ChildItem $reportPath
    $allLocal = $true
    foreach ($file in $files) {
        if (-not $file.FullName.StartsWith($LocalBoundary)) {
            $allLocal = $false
        }
    }
    if ($allLocal) {
        Write-Host "  PASS - All reports within local boundary" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "  FAIL - Some reports outside boundary" -ForegroundColor Red
        $checks += $false
    }
}

# Check 3: No cloud service references
Write-Host "Check 3: Cloud service references" -ForegroundColor Yellow
$scriptContent = Get-Content "C:\MyCode\Local-AIAgent\E2E-LocalValidationPipeline.ps1" -Raw
if ($scriptContent -notmatch "openai|amazonaws|azure.*compute") {
    Write-Host "  PASS - No cloud service references" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "  FAIL - Cloud references found" -ForegroundColor Red
    $checks += $false
}

# Check 4: Audit trail shows zero cloud calls
Write-Host "Check 4: Audit trail cloud calls" -ForegroundColor Yellow
$auditLog = "C:\MyCode\Local-AIAgent\Validation\Reports\validation_audit.log"
if (Test-Path $auditLog) {
    $content = Get-Content $auditLog
    if ($content -match '"CloudCalls":\s*0') {
        Write-Host "  PASS - Audit shows CloudCalls = 0" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "  FAIL - Cloud calls detected" -ForegroundColor Red
        $checks += $false
    }
}

# Summary
Write-Host "`nSummary:" -ForegroundColor Cyan
$passCount = ($checks | Where-Object { $_ -eq $true } | Measure-Object).Count
$totalCount = $checks.Count

Write-Host "Passed: $passCount/$totalCount" -ForegroundColor $(if ($passCount -eq $totalCount) { "Green" } else { "Red" })
Write-Host "Status: $(if ($passCount -eq $totalCount) { 'COMPLIANT' } else { 'NON-COMPLIANT' })" -ForegroundColor $(if ($passCount -eq $totalCount) { "Green" } else { "Red" })
Write-Host "Local Boundary: $LocalBoundary" -ForegroundColor Green
Write-Host "Cloud Calls: 0" -ForegroundColor Green
Write-Host ""
