$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

$jdk = Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory -ErrorAction SilentlyContinue |
    Where-Object Name -Like 'jdk-21*' |
    Sort-Object Name -Descending |
    Select-Object -First 1
if ($jdk) {
    $env:JAVA_HOME = $jdk.FullName
    $env:Path = "$($jdk.FullName)\bin;$env:Path"
}
$env:Path = "C:\Program Files\nodejs;$env:Path"

foreach ($command in @('java', 'node', 'npm')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Missing '$command'. Close and reopen PowerShell after installation, then try again."
    }
}

if (-not (Get-NetTCPConnection -LocalPort 5432 -State Listen -ErrorAction SilentlyContinue)) {
    $postgresService = Get-Service 'postgresql-x64-17' -ErrorAction SilentlyContinue
    if (-not $postgresService) {
        throw 'PostgreSQL is not running on port 5432. Start PostgreSQL, then try again.'
    }
    if ($postgresService.Status -ne 'Running') {
        Start-Service $postgresService
        $postgresService.WaitForStatus('Running', [TimeSpan]::FromSeconds(30))
    }
}
Write-Host 'Using PostgreSQL on port 5432.'

Push-Location $root
try {
    New-Item -ItemType Directory -Force -Path (Join-Path $root '.run') | Out-Null
    $backendLog = Join-Path $root '.run\backend.log'
    $frontendLog = Join-Path $root '.run\frontend.log'

    $backend = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'mvnw.cmd spring-boot:run > "..\.run\backend.log" 2>&1' -WorkingDirectory (Join-Path $root 'backend') -WindowStyle Hidden -PassThru
    Set-Content -LiteralPath (Join-Path $root '.run\backend.pid') -Value $backend.Id

    $backendReady = $false
    for ($attempt = 0; $attempt -lt 60; $attempt++) {
        Start-Sleep -Seconds 2
        try {
            Invoke-RestMethod -Uri 'http://127.0.0.1:8080/api/products' -TimeoutSec 2 | Out-Null
            $backendReady = $true
            break
        } catch { }
    }
    if (-not $backendReady) { throw "Backend failed to start. See $backendLog" }

    if (-not (Test-Path -LiteralPath (Join-Path $root 'frontend\node_modules'))) {
        Write-Host 'Installing frontend packages...'
        Push-Location (Join-Path $root 'frontend')
        try {
            npm install
            if ($LASTEXITCODE -ne 0) { throw 'Frontend package installation failed.' }
        } finally {
            Pop-Location
        }
    }

    $frontend = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'npm run dev -- --host 127.0.0.1 > "..\.run\frontend.log" 2>&1' -WorkingDirectory (Join-Path $root 'frontend') -WindowStyle Hidden -PassThru
    Set-Content -LiteralPath (Join-Path $root '.run\frontend.pid') -Value $frontend.Id

    $frontendReady = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Seconds 1
        try {
            Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:3000' -TimeoutSec 2 | Out-Null
            $frontendReady = $true
            break
        } catch { }
    }
    if (-not $frontendReady) { throw "Frontend failed to start. See $frontendLog" }

    Start-Process 'http://127.0.0.1:3000'
    Write-Host 'Products app is ready at http://127.0.0.1:3000' -ForegroundColor Green
    Write-Host 'Run .\stop-app.ps1 when finished.'
} finally {
    Pop-Location
}
