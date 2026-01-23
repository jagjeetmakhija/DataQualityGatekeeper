# Source CONFIG for all paths
param(
    [string]$InputFile = "",
    [string]$OutputFile = "",
    [string]$FileFormat = "auto",  # auto, xlsx, json, xml, csv, tsv, txt
    [hashtable]$ColumnMapping = @{}
)

. (Join-Path $PSScriptRoot "CONFIG.ps1")

# Use CONFIG default for output if not provided
if ([string]::IsNullOrWhiteSpace($OutputFile)) { $OutputFile = Join-Path $script:OutputsPath "converted_data.csv" }

$Phase1Schema = @(
    'MARKET','SITE','CLIENT','INITIATION DATE','EXPECTED CLOSE','STAGE','CAPACITY (MW)','TYPE','PRICING','PRICING DATE'
)

function ConvertFrom-JsonFile { param([string]$Path)
        if(-not (Test-Path $Path)){ Write-Host "ERROR: File not found: $Path" -ForegroundColor Red; return $null }
        try {
            $arr = Get-Content $Path -Raw | ConvertFrom-Json
            if($arr -isnot [array]){ Write-Host "ERROR: JSON must be an array of objects" -ForegroundColor Red; return $null }
            $headers = $arr[0].PSObject.Properties.Name
            return @{ Headers=$headers; Rows=$arr }
        } catch { Write-Host "ERROR: Invalid JSON - $_" -ForegroundColor Red; return $null }
    }

function ConvertFrom-XmlFile { param([string]$Path)
        if(-not (Test-Path $Path)){ Write-Host "ERROR: File not found: $Path" -ForegroundColor Red; return $null }
        try {
            [xml]$doc = Get-Content $Path
            $rows = @(); $headers=$null
            foreach($n in $doc.DocumentElement.ChildNodes){
                if($n.NodeType -ne 'Element'){ continue }
                $obj = @{}
                foreach($c in $n.ChildNodes){ if($c.NodeType -eq 'Element'){ $obj[$c.Name]=$c.InnerText } }
                if(-not $headers){ $headers = $obj.Keys }
                $rows += (New-Object psobject -Property $obj)
            }
            return @{ Headers=$headers; Rows=$rows }
        } catch { Write-Host "ERROR: Invalid XML - $_" -ForegroundColor Red; return $null }
    }

function ConvertFrom-TextFile { param([string]$Path)
        if(-not (Test-Path $Path)){ Write-Host "ERROR: File not found: $Path" -ForegroundColor Red; return $null }
        try {
            $lines = Get-Content $Path
            $del = (',','`t',';') | Where-Object { $lines[0] -like "*$_*" } | Select-Object -First 1; if(-not $del){ $del="," }
            $headers = ($lines[0] -split $del).Trim()
            $rows = @()
            for($i=1;$i -lt $lines.Count;$i++){
                $vals = ($lines[$i] -split $del)
                $obj=@{}; for($j=0;$j -lt $headers.Count;$j++){ $obj[$headers[$j]] = $vals[$j] }
                $rows += (New-Object psobject -Property $obj)
            }
            return @{ Headers=$headers; Rows=$rows }
        } catch { Write-Host "ERROR: Cannot parse text - $_" -ForegroundColor Red; return $null }
    }

function ConvertFrom-CsvFile { param([string]$Path)
        if(-not (Test-Path $Path)){ Write-Host "ERROR: File not found: $Path" -ForegroundColor Red; return $null }
        try { $data = Import-Csv $Path; return @{ Headers=$data[0].PSObject.Properties.Name; Rows=$data } } catch { Write-Host "ERROR: Invalid CSV - $_" -ForegroundColor Red; return $null }
    }

function Map-ColumnsToSchema { param([array]$SourceHeaders,[hashtable]$UserMapping)
        $map=@{}
        if($UserMapping -and $UserMapping.Count -gt 0){ return $UserMapping }
        $common=@{
            'MARKET'=@('market','region','area','location','zone');
            'SITE'=@('site','site_id','site_name','siteid','code');
            'CLIENT'=@('client','customer','company','account','client_name');
            'INITIATION DATE'=@('initiation','start_date','start date','initiated','creation_date','created');
            'EXPECTED CLOSE'=@('expected close','close_date','close date','target_close','expected_close','close');
            'STAGE'=@('stage','pipeline','status','phase','stage_name');
            'CAPACITY (MW)'=@('capacity','mw','megawatts','power','capacity_mw');
            'TYPE'=@('type','project_type','projecttype','category','kind');
            'PRICING'=@('pricing','price','value','cost','amount');
            'PRICING DATE'=@('pricing date','price_date','pricing_date','priced_date')
        }
        foreach($sc in $Phase1Schema){ foreach($src in $SourceHeaders){ $l=$src.ToLower().Trim(); foreach($p in $common[$sc]){ if($l -eq $p -or $l -like "*$p*"){ $map[$sc]=$src; break } } if($map.ContainsKey($sc)){ break } } }
        return $map
    }

function Convert-ToPhase1CSV { param([object]$InputData,[array]$SourceHeaders,[hashtable]$ColumnMapping,[string]$OutputPath)
    $mapping = Map-ColumnsToSchema -SourceHeaders $SourceHeaders -UserMapping $ColumnMapping
    $csvLines = @(); $csvLines += ($Phase1Schema -join ',')
    foreach($row in $InputData.Rows){
        $vals=@()
        foreach($col in $Phase1Schema){
            if($mapping.ContainsKey($col)){
                $src=$mapping[$col]
                $v = $row.$src
                if($null -eq $v){ $v='' }
                if($v -match '[,\"]'){ $v = '"' + ($v -replace '"','""') + '"' }
                $vals += $v
            } else {
                $vals += ''
            }
        }
        $csvLines += ($vals -join ',')
    }
    $csvLines -join "`r`n" | Set-Content -Path $OutputPath -Encoding UTF8
    return $OutputPath
}

if([string]::IsNullOrWhiteSpace($InputFile)){
    Write-Host "Provide -InputFile" -ForegroundColor Yellow
    exit 1
}
if($FileFormat -eq 'auto'){
    $FileFormat = [IO.Path]::GetExtension($InputFile).ToLower().TrimStart('.')
}

$data=$null
switch($FileFormat){
    'xlsx' { Write-Host 'Excel not supported in this local build; provide CSV/TSV/JSON/XML' -ForegroundColor Yellow; $data=$null }
    'xls'  { Write-Host 'Excel not supported in this local build; provide CSV/TSV/JSON/XML' -ForegroundColor Yellow; $data=$null }
    'json' { $data = ConvertFrom-JsonFile $InputFile }
    'xml'  { $data = ConvertFrom-XmlFile $InputFile }
    'csv'  { $data = ConvertFrom-CsvFile $InputFile }
    'tsv'  { $data = ConvertFrom-TextFile $InputFile }
    'txt'  { $data = ConvertFrom-TextFile $InputFile }
    default { Write-Host "ERROR: Unsupported format: $FileFormat" -ForegroundColor Red; exit 1 }
}
if ($null -eq $data){
    Write-Host "ERROR: Failed to read input file" -ForegroundColor Red
    exit 1
}

Write-Host "`nSource Headers Found: $($data.Headers.Count)" -ForegroundColor Cyan
Write-Host "  $($data.Headers -join ', ')" -ForegroundColor DarkGray
Write-Host "`nSource Records: $($data.Rows.Count)" -ForegroundColor Cyan

# Convert to Phase 1 CSV
$outputPath = Convert-ToPhase1CSV -InputData $data -SourceHeaders $data.Headers -ColumnMapping $ColumnMapping -OutputPath $OutputFile

Write-Host ""  # spacer
Write-Host "File ready for Phase 1 analysis!" -ForegroundColor Green
