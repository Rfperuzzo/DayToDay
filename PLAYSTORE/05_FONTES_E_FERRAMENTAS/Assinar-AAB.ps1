param(
    [Parameter(Mandatory=$true)][string]$KeyStore,
    [Parameter(Mandatory=$true)][string]$Alias,
    [string]$UnsignedBundle = (Join-Path (Split-Path $PSScriptRoot -Parent) '04_BUILD/DayToDay-1.0.0-1-SEM-ASSINATURA-NAO-ENVIAR.aab')
)
$ErrorActionPreference = 'Stop'
$KeyStore = (Resolve-Path -LiteralPath $KeyStore).Path
$UnsignedBundle = (Resolve-Path -LiteralPath $UnsignedBundle).Path
$packageRoot = (Resolve-Path -LiteralPath (Split-Path $PSScriptRoot -Parent)).Path
if ($KeyStore.StartsWith($packageRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Guarde a chave fora da pasta PLAYSTORE e do repositorio.' }
$projectRoot = Split-Path $packageRoot -Parent
if ((Test-Path -LiteralPath (Join-Path $projectRoot 'pubspec.yaml')) -and $KeyStore.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) { throw 'A chave nao pode ficar dentro do repositorio do app.' }
if ($Alias -match 'debug') { throw 'Nao use uma chave de depuracao para publicar.' }
$destination = Join-Path (Split-Path $UnsignedBundle -Parent) 'DayToDay-1.0.0-1-ASSINADO-REVISAR.aab'
if (Test-Path -LiteralPath $destination) { throw 'O destino ja existe. Preserve a versao anterior antes de continuar.' }
# jarsigner solicita a senha no terminal. Nenhuma senha e recebida como argumento ou salva.
$bundled = Join-Path $env:ProgramFiles 'Android/Android Studio/jbr/bin/jarsigner.exe'
$signer = if (Test-Path -LiteralPath $bundled) { $bundled } else { (Get-Command jarsigner -ErrorAction Stop).Source }
& $signer '-keystore' $KeyStore '-signedjar' $destination '-sigalg' 'SHA256withRSA' '-digestalg' 'SHA-256' $UnsignedBundle $Alias
if ($LASTEXITCODE -ne 0) { throw 'A assinatura falhou; nao envie o arquivo.' }
$verification = & $signer '-J-Duser.language=en' '-J-Duser.country=US' '-verify' '-verbose' '-certs' $destination 2>&1
if ($LASTEXITCODE -ne 0 -or (($verification -join "`n") -notmatch 'jar verified')) { throw 'A verificacao de assinatura falhou.' }
if (($verification -join "`n") -match 'CN=Android Debug') { throw 'O certificado e de teste. NAO envie esse arquivo.' }
$verification | Set-Content -LiteralPath ($destination + '.verification.txt') -Encoding utf8
Get-FileHash -LiteralPath $destination -Algorithm SHA256
Write-Output 'Assinatura criada. Confira o certificado/chave de upload da conta Play antes de enviar. Nenhum upload foi realizado.'
