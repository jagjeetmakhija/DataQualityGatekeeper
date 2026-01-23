# Configuration
$Port = 5173
$UIPath = Join-Path $PSScriptRoot "ui"

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Starting Static UI Server" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if port is in use
$portInUse = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "Port $Port is in use. Trying to free it..." -ForegroundColor Yellow
    $processId = $portInUse.OwningProcess
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Start HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")

try {
    $listener.Start()
    Write-Host "[OK] Server running at http://localhost:$Port/" -ForegroundColor Green
    Write-Host "[OK] Serving files from: $UIPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    Write-Host ""
    
    # Open browser
    Start-Process "http://localhost:$Port/"
    
    # Serve files
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            # Get requested file path
            $requestedPath = $request.Url.LocalPath
            if ($requestedPath -eq "/" -or $requestedPath -eq "") {
                $requestedPath = "/index.html"
            }
            
            $filePath = Join-Path $UIPath $requestedPath.TrimStart('/')
        
        # Serve file if exists
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            
            # Set content type
            $extension = [System.IO.Path]::GetExtension($filePath)
            $contentType = switch ($extension) {
                ".html" { "text/html" }
                ".css"  { "text/css" }
                ".js"   { "text/javascript" }
                ".json" { "application/json" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".gif"  { "image/gif" }
                ".svg"  { "image/svg+xml" }
                ".ico"  { "image/x-icon" }
                default { "application/octet-stream" }
            }
            
            $response.ContentType = $contentType
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
            
            Write-Host "[OK] Served: $requestedPath" -ForegroundColor Gray
        }
        else {
            # 404 Not Found
            $response.StatusCode = 404
            $notFoundHtml = "<h1>404 - Not Found</h1><p>Requested: $requestedPath</p>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($notFoundHtml)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            
            # Suppress logging for API endpoints
            if (-not $requestedPath.StartsWith("/api/")) {
                Write-Host "[FAIL] Not found: $requestedPath" -ForegroundColor Red
            }
        }
        
        $response.Close()
            # $response.Close() already called above, removed duplicate
        } catch {
            Write-Host "[ERROR] $_" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "[ERROR] $_" -ForegroundColor Red
} finally {
    $listener.Stop()
    Write-Host ""
    Write-Host "Server stopped." -ForegroundColor Yellow
}
