<#
.SYNOPSIS
Pricing Logistics Demo Startup Script
.DESCRIPTION
This script safely provisions and starts the Pricing Logistics environment for a demo.
#>

$ErrorActionPreference = "Stop"

# 1. Resolve project root
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

Write-Host "Pricing Logistics Demo Startup Tool" -ForegroundColor Cyan
Write-Host "====================================`n"

# Cleanup tracking
$PidsToCleanup = @()

function Cleanup {
    Write-Host "`nShutting down demo processes..." -ForegroundColor Yellow
    foreach ($pidToKill in $PidsToCleanup) {
        try {
            $process = Get-Process -Id $pidToKill -ErrorAction SilentlyContinue
            if ($process) {
                Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
                Write-Host "Stopped process ID: $pidToKill"
            }
        } catch {}
    }
    Write-Host "Cleanup complete." -ForegroundColor Green
}

# Trap Ctrl+C and exit
[console]::TreatControlCAsInput = $false
[System.Console]::CancelKeyPress += {
    Cleanup
    $global:quit = $true
}

# 3. Virtual Env Python
$PythonExe = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    Write-Error "Virtual environment python not found at $PythonExe"
    exit 1
}

# 4. Verify Database configuration from Django
Write-Host "Verifying database configuration..."
$DbName = & $PythonExe manage.py shell -c "from django.conf import settings; print(settings.DATABASES['default']['NAME'])" | Select-Object -Last 1
$DbName = $DbName.Trim()

if (-not $DbName) {
    Write-Error "Database name is blank or undefined in Django settings."
    exit 1
}

if ($DbName -eq "postgres" -or $DbName -match "^template\d+$" -or $DbName -eq "pricing_logistics_test") {
    Write-Error "Refusing to operate on protected database: $DbName"
    exit 1
}

if ($DbName -ne "pricing_logistics_dev") {
    Write-Error "Unexpected database name: $DbName. Expected exactly 'pricing_logistics_dev'."
    exit 1
}

Write-Host "Database verified as $DbName" -ForegroundColor Green

# 2. Check Postgres is reachable via Django's connection check
Write-Host "Checking PostgreSQL connectivity..."
try {
    & $PythonExe manage.py check --database default 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Database check failed."
    }
} catch {
    Write-Error "Could not connect to PostgreSQL database '$DbName'."
    exit 1
}
Write-Host "PostgreSQL is reachable." -ForegroundColor Green

# 8. Idempotent Seed
Write-Host "Seeding UAT database..."
# Note: No passwords printed or contained here.
& $PythonExe manage.py seed_uat --confirm-local-demo-seed
if ($LASTEXITCODE -ne 0) {
    Write-Error "Database seed failed."
    exit 1
}
Write-Host "Seed completed safely." -ForegroundColor Green

# Start Django
Write-Host "Starting Django server..."
$DjangoProc = Start-Process -FilePath $PythonExe -ArgumentList "manage.py runserver 8000" -NoNewWindow -PassThru
$PidsToCleanup += $DjangoProc.Id

# Wait for Django Health Check
$DjangoReady = $false
Write-Host "Waiting for Django..."
for ($i = 0; $i -lt 15; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/me/" -Method Get -ErrorAction Stop
        $DjangoReady = $true
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}
if (-not $DjangoReady) {
    Write-Error "Django failed to start or become reachable."
    Cleanup
    exit 1
}
Write-Host "Django is ready." -ForegroundColor Green

# Start Vite
Write-Host "Starting Vite Dev Server..."
$ViteProc = Start-Process -FilePath "npm" -ArgumentList "run dev" -NoNewWindow -PassThru
$PidsToCleanup += $ViteProc.Id

# Wait for Vite Health Check
$ViteReady = $false
Write-Host "Waiting for Vite..."
for ($i = 0; $i -lt 15; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method Get -ErrorAction Stop
        $ViteReady = $true
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}
if (-not $ViteReady) {
    Write-Error "Vite failed to start or become reachable."
    Cleanup
    exit 1
}
Write-Host "Vite is ready." -ForegroundColor Green

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "DEMO IS READY!" -ForegroundColor Green
Write-Host "Access the frontend at: http://localhost:3000"
Write-Host "Press Ctrl+C to stop the servers safely."
Write-Host "=======================================================`n" -ForegroundColor Cyan

while (-not $global:quit) {
    Start-Sleep -Seconds 1
}
