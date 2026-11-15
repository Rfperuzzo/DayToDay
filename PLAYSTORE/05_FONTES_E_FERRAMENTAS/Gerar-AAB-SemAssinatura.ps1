param(
    [string]$ProjectRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
    [switch]$PermitirDownloadDeDependencias
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'android/gradlew.bat'))) { throw 'Informe -ProjectRoot com a pasta do projeto Flutter DayToDay.' }
# Prefer Android Studio's bundled JDK; never change the machine-wide Java config.
$jdk = Join-Path $env:ProgramFiles 'Android/Android Studio/jbr'
$previousJavaHome = $env:JAVA_HOME
if (Test-Path -LiteralPath (Join-Path $jdk 'bin/java.exe')) { $env:JAVA_HOME = $jdk }
$init = Join-Path $PSScriptRoot 'unsigned-release.init.gradle'
$androidRoot = Join-Path $ProjectRoot 'android'
Push-Location -LiteralPath $androidRoot
try {
    $gradleArguments = @('--no-daemon', '-Pdaytoday.allowUnsigned=true', '-I', $init, ':app:bundleRelease', ':app:assembleRelease', "-Ptarget=$ProjectRoot/lib/main.dart", '-Ptarget-platform=android-arm,android-arm64,android-x64', '-Ptree-shake-icons=true')
    if (-not $PermitirDownloadDeDependencias) { $gradleArguments = @('--offline') + $gradleArguments }
    & .\gradlew.bat @gradleArguments
    if ($LASTEXITCODE -ne 0) { throw 'O build release sem assinatura falhou. Consulte o log.' }
} finally { Pop-Location; $env:JAVA_HOME = $previousJavaHome }
$destination = Join-Path $ProjectRoot 'PLAYSTORE/04_BUILD'
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'build/app/outputs/bundle/release/app-release.aab') -Destination (Join-Path $destination 'DayToDay-1.0.0-1-SEM-ASSINATURA-NAO-ENVIAR.aab')
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'build/app/outputs/apk/release/app-release-unsigned.apk') -Destination (Join-Path $destination 'DayToDay-1.0.0-1-SEM-ASSINATURA-NAO-INSTALAR.apk')
Write-Output 'Build sem assinatura concluido. Estes arquivos NAO estao prontos para envio ao Play Console.'
