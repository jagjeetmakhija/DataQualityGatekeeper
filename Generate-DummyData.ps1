# Source CONFIG for all paths
param(
    [string]$OutputPath = ""
)

. (Join-Path $PSScriptRoot "CONFIG.ps1")

# Use CONFIG default if not provided
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = $script:SampleDataPath }

Write-Host "`nGenerating dummy data..." -ForegroundColor Cyan

$headers = @("CompanyName","ProjectType","PowerCapacity_MW","ProjectLocation","DevelopmentPhase","EstimatedCloseDate","ProbabilityPercent","LeadEngineer","TechnologyType","GridConnection","PermitStatus","InvestmentValue_USD")

$companies = @("Acme Energy", "SolarTech Inc", "GreenPower Corp", "WindForce LLC", "CleanGrid Solutions", "FutureGen Energy", "EcoWatt Systems", "RenewableFirst", "BrightEnergy Co", "PowerNow Industries")
$projectTypes = @("Solar PV", "Wind Farm", "Battery Storage", "Hybrid Solar+Storage", "Offshore Wind")
$locations = @("California", "Texas", "Arizona", "Nevada", "New Mexico", "Colorado", "Utah", "Oregon", "Washington", "Florida")
$phases = @("Pre-Qualification", "Qualification", "Proposal", "Negotiation", "Contract Signed")
$engineers = @("Sarah Chen", "Michael Rodriguez", "Emily Watson", "David Kim", "Jessica Martinez", "Robert Thompson", "Lisa Anderson", "James Wilson")
$technologies = @("Monocrystalline Si", "Bifacial Modules", "Vestas V150", "GE Haliade-X", "Tesla Megapack", "Siemens Gamesa 5.X")
$gridConnections = @("138kV Substation", "230kV Transmission", "69kV Distribution", "500kV Backbone")
$permitStatus = @("Applied", "Under Review", "Conditional Approval", "Approved", "Pending EIS")

$data = @()
$data += $headers -join ','

for ($i = 1; $i -le 250; $i++) {
    $company = $companies | Get-Random
    $projectType = $projectTypes | Get-Random
    $capacity = switch ($projectType) {
        "Solar PV" { Get-Random -Minimum 50 -Maximum 500 }
        "Wind Farm" { Get-Random -Minimum 100 -Maximum 600 }
        "Battery Storage" { Get-Random -Minimum 25 -Maximum 200 }
        "Hybrid Solar+Storage" { Get-Random -Minimum 75 -Maximum 400 }
        "Offshore Wind" { Get-Random -Minimum 200 -Maximum 800 }
    }
    
    $location = $locations | Get-Random
    $phase = $phases | Get-Random
    
    $daysOut = switch ($phase) {
        "Pre-Qualification" { Get-Random -Minimum 180 -Maximum 365 }
        "Qualification" { Get-Random -Minimum 120 -Maximum 240 }
        "Proposal" { Get-Random -Minimum 60 -Maximum 150 }
        "Negotiation" { Get-Random -Minimum 30 -Maximum 90 }
        "Contract Signed" { Get-Random -Minimum 0 -Maximum 30 }
    }
    $closeDate = (Get-Date).AddDays($daysOut).ToString("yyyy-MM-dd")
    
    $probability = switch ($phase) {
        "Pre-Qualification" { Get-Random -Minimum 10 -Maximum 30 }
        "Qualification" { Get-Random -Minimum 25 -Maximum 45 }
        "Proposal" { Get-Random -Minimum 40 -Maximum 60 }
        "Negotiation" { Get-Random -Minimum 55 -Maximum 80 }
        "Contract Signed" { Get-Random -Minimum 85 -Maximum 100 }
    }
    
    $engineer = $engineers | Get-Random
    $technology = $technologies | Get-Random
    $grid = $gridConnections | Get-Random
    $permit = $permitStatus | Get-Random
    
    $costPerMW = switch ($projectType) {
        "Solar PV" { Get-Random -Minimum 800000 -Maximum 1200000 }
        "Wind Farm" { Get-Random -Minimum 1200000 -Maximum 1800000 }
        "Battery Storage" { Get-Random -Minimum 400000 -Maximum 800000 }
        "Hybrid Solar+Storage" { Get-Random -Minimum 1000000 -Maximum 1500000 }
        "Offshore Wind" { Get-Random -Minimum 3000000 -Maximum 5000000 }
    }
    $investment = [math]::Round($capacity * $costPerMW, 0)
    
    $companyVal = if ((Get-Random -Minimum 1 -Maximum 100) -le 5) { "" } else { $company }
    $phaseVal = if ((Get-Random -Minimum 1 -Maximum 100) -le 5) { "" } else { $phase }
    $closeDateVal = if ((Get-Random -Minimum 1 -Maximum 100) -le 8) { "" } else { $closeDate }
    $engineerVal = if ((Get-Random -Minimum 1 -Maximum 100) -le 5) { "" } else { $engineer }
    
    $row = @($companyVal,$projectType,$capacity,$location,$phaseVal,$closeDateVal,$probability,$engineerVal,$technology,$grid,$permit,$investment) -join ','
    $data += $row
}

$data | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Done! Generated 250 records" -ForegroundColor Green
Write-Host "File: $OutputPath" -ForegroundColor Green
