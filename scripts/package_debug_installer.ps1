[CmdletBinding()]
param(
    [string]$OutputDirectory,
    [string]$AdbDirectory,
    [string]$FlutterPath = 'flutter',
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$sourceDirectory = Join-Path $PSScriptRoot 'debug_installer'
$apkPath = Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-debug.apk'

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $projectRoot 'outputs'
}

if (-not $AdbDirectory) {
    if (-not $env:LOCALAPPDATA) {
        throw 'LOCALAPPDATA não está definido. Informe -AdbDirectory.'
    }
    $AdbDirectory = Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools'
}

if (-not $SkipBuild) {
    Write-Host 'Gerando APK debug...' -ForegroundColor Cyan
    Push-Location $projectRoot
    try {
        & $FlutterPath 'build' 'apk' '--debug' '--no-pub'
        if ($LASTEXITCODE -ne 0) {
            throw "O build Flutter falhou com código $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
    throw "APK não encontrado em '$apkPath'. Execute sem -SkipBuild."
}

$requiredAdbFiles = @('adb.exe', 'AdbWinApi.dll', 'AdbWinUsbApi.dll')
foreach ($fileName in $requiredAdbFiles) {
    $filePath = Join-Path $AdbDirectory $fileName
    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        throw "Arquivo obrigatório do ADB não encontrado: $filePath"
    }
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

$packageId = [Guid]::NewGuid().ToString('N')
$stagingParent = Join-Path $projectRoot "build\debug_installer\$packageId"
$stagingDirectory = Join-Path $stagingParent 'Rotina-da-Jhenifer-Debug'
$platformToolsDirectory = Join-Path $stagingDirectory 'platform-tools'

New-Item -ItemType Directory -Path $platformToolsDirectory -Force | Out-Null

Copy-Item -LiteralPath $apkPath -Destination (Join-Path $stagingDirectory 'app-debug.apk')
$installerSource = Join-Path $sourceDirectory 'install_debug.ps1'
$installerDestination = Join-Path $stagingDirectory 'install_debug.ps1'
$installerContent = Get-Content -LiteralPath $installerSource -Raw -Encoding UTF8
# Windows PowerShell 5 usa o BOM para reconhecer UTF-8. O arquivo distribuído
# recebe essa codificação para preservar as mensagens em português.
Set-Content -LiteralPath $installerDestination -Value $installerContent -Encoding UTF8
Copy-Item -LiteralPath (Join-Path $sourceDirectory 'Instalar-Rotina-Debug.cmd') -Destination $stagingDirectory
Copy-Item -LiteralPath (Join-Path $sourceDirectory 'LEIA-ME.md') -Destination $stagingDirectory

foreach ($fileName in $requiredAdbFiles) {
    Copy-Item -LiteralPath (Join-Path $AdbDirectory $fileName) -Destination $platformToolsDirectory
}

$zipPath = Join-Path $OutputDirectory 'Rotina-da-Jhenifer-Debug-Windows.zip'
Compress-Archive -LiteralPath $stagingDirectory -DestinationPath $zipPath -CompressionLevel Optimal -Force

$zip = Get-Item -LiteralPath $zipPath
$hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash

Write-Host ''
Write-Host 'Instalador gerado com sucesso.' -ForegroundColor Green
Write-Host "Arquivo: $($zip.FullName)"
Write-Host ("Tamanho: {0:N1} MB" -f ($zip.Length / 1MB))
Write-Host "SHA-256: $hash"
