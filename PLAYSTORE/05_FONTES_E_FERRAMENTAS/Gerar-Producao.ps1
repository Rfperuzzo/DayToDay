param(
    [string]$ProjectRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
    [string]$SigningDirectory = (Join-Path $env:USERPROFILE '.codex/signing/daytoday'),
    [switch]$CriarPrimeiraChave
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml'))) { throw 'Informe a pasta do projeto DayToDay.' }
$manifestText = Get-Content -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml') -Raw
$versionMatch = [regex]::Match($manifestText, '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$')
if (-not $versionMatch.Success) { throw 'Versao do pubspec deve ter o formato X.Y.Z+codigo.' }
$versionName = $versionMatch.Groups[1].Value
$versionCode = $versionMatch.Groups[2].Value
$artifactPrefix = "DayToDay-$versionName-$versionCode"
$SigningDirectory = [IO.Path]::GetFullPath($SigningDirectory)
if ($SigningDirectory.StartsWith($ProjectRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'A chave deve ficar fora do repositorio.' }
$jdk = Join-Path $env:ProgramFiles 'Android/Android Studio/jbr'
$keytool = Join-Path $jdk 'bin/keytool.exe'
if (-not (Test-Path -LiteralPath $keytool)) { throw 'Instale o JDK do Android Studio.' }
$key = Join-Path $SigningDirectory 'daytoday-upload.jks'
$protectedPassword = Join-Path $SigningDirectory 'upload.password.dpapi'
$aliasName = 'daytoday-upload'
$oldJavaHome = $env:JAVA_HOME
$previousKey = $env:DAYTODAY_UPLOAD_KEY
$previousAlias = $env:DAYTODAY_UPLOAD_ALIAS
$previousPassword = $env:DAYTODAY_UPLOAD_PASSWORD
try {
    if ($CriarPrimeiraChave) {
        if ((Test-Path -LiteralPath $key) -or (Test-Path -LiteralPath $protectedPassword)) { throw 'Ja existe material de assinatura. Nao sera substituido.' }
        New-Item -ItemType Directory -Force -Path $SigningDirectory | Out-Null
        # Restrict secrets to the current Windows user and SYSTEM before writing.
        $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        & icacls.exe $SigningDirectory '/inheritance:r' '/grant:r' "*${sid}:(OI)(CI)F" '*S-1-5-18:(OI)(CI)F' | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Falha ao restringir a pasta privada.' }
        $randomBytes = New-Object byte[] 48
        $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
        try { $rng.GetBytes($randomBytes) } finally { $rng.Dispose() }
        $env:DAYTODAY_UPLOAD_PASSWORD = [Convert]::ToBase64String($randomBytes)
        $secure = ConvertTo-SecureString $env:DAYTODAY_UPLOAD_PASSWORD -AsPlainText -Force
        $secure | ConvertFrom-SecureString | Set-Content -LiteralPath $protectedPassword -Encoding ASCII
        & $keytool '-genkeypair' '-noprompt' '-keystore' $key '-storetype' 'JKS' '-storepass:env' 'DAYTODAY_UPLOAD_PASSWORD' '-keypass:env' 'DAYTODAY_UPLOAD_PASSWORD' '-alias' $aliasName '-keyalg' 'RSA' '-keysize' '3072' '-validity' '10000' '-dname' 'CN=DayToDay Upload, OU=DayToDay, O=Thales Melo da Silva, C=BR'
        if ($LASTEXITCODE -ne 0) { throw 'Falha ao criar a chave. Preserve os arquivos e confira antes de repetir.' }
    }
    if (-not (Test-Path -LiteralPath $key) -or -not (Test-Path -LiteralPath $protectedPassword)) { throw 'Chave exclusiva ausente. Use -CriarPrimeiraChave apenas na primeira publicacao, nunca para substituir uma chave existente.' }
    $secure = Get-Content -LiteralPath $protectedPassword | ConvertTo-SecureString
    $credential = New-Object System.Management.Automation.PSCredential('upload', $secure)
    $env:DAYTODAY_UPLOAD_PASSWORD = $credential.GetNetworkCredential().Password
    $env:DAYTODAY_UPLOAD_KEY = $key
    $env:DAYTODAY_UPLOAD_ALIAS = $aliasName
    $env:JAVA_HOME = $jdk
    $destination = Join-Path $ProjectRoot 'PLAYSTORE/04_BUILD'
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
    & $keytool '-exportcert' '-rfc' '-keystore' $key '-storepass:env' 'DAYTODAY_UPLOAD_PASSWORD' '-alias' $aliasName '-file' (Join-Path $destination 'CERTIFICADO-PUBLICO-UPLOAD.pem')
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao exportar certificado publico.' }
    Push-Location -LiteralPath (Join-Path $ProjectRoot 'android')
    try {
        & .\gradlew.bat '--offline' '--no-daemon' ':app:bundleRelease' ':app:assembleRelease' "-Ptarget=$ProjectRoot/lib/main.dart" '-Ptarget-platform=android-arm,android-arm64,android-x64' "-Pdaytoday.versionName=$versionName" "-Pdaytoday.versionCode=$versionCode" '-Ptree-shake-icons=true'
        if ($LASTEXITCODE -ne 0) { throw 'Build de producao falhou.' }
    } finally { Pop-Location }
    $bundle = Join-Path $destination "$artifactPrefix-PRODUCAO.aab"
    # Re-sign using the same upload key so JAR metadata comes first for both
    # JarFile and JarInputStream readers. No remote timestamp or paid service.
    & (Join-Path $jdk 'bin/jarsigner.exe') '-keystore' $key '-storepass:env' 'DAYTODAY_UPLOAD_PASSWORD' '-keypass:env' 'DAYTODAY_UPLOAD_PASSWORD' '-signedjar' $bundle (Join-Path $ProjectRoot 'build/app/outputs/bundle/release/app-release.aab') $aliasName
    if ($LASTEXITCODE -ne 0) { throw 'Assinatura final do AAB falhou.' }
    Copy-Item -LiteralPath (Join-Path $ProjectRoot 'build/app/outputs/apk/release/app-release.apk') -Destination (Join-Path $destination "$artifactPrefix-PRODUCAO-TESTE.apk")
    & (Join-Path $jdk 'bin/jarsigner.exe') '-verify' $bundle
    if ($LASTEXITCODE -ne 0) { throw 'Verificacao da assinatura falhou.' }
    (Get-FileHash -LiteralPath $bundle -Algorithm SHA256).Hash.ToLowerInvariant() | Set-Content (Join-Path $destination 'AAB-SHA256.txt')
    Write-Output 'AAB de producao assinado. Chave e senha protegida ficam somente na pasta privada; nunca no ZIP ou Git.'
} finally {
    $env:JAVA_HOME = $oldJavaHome
    $env:DAYTODAY_UPLOAD_KEY = $previousKey
    $env:DAYTODAY_UPLOAD_ALIAS = $previousAlias
    $env:DAYTODAY_UPLOAD_PASSWORD = $previousPassword
    $credential = $null
    $secure = $null
}
