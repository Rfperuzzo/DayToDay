param(
    [Parameter(Mandatory=$true)][string]$Destino,
    [string]$SigningDirectory = (Join-Path $env:USERPROFILE '.codex/signing/daytoday')
)
$ErrorActionPreference='Stop'
$Destino=[IO.Path]::GetFullPath($Destino)
$kitRoot=[IO.Path]::GetFullPath((Split-Path $PSScriptRoot -Parent))
$repoRoot=Split-Path $kitRoot -Parent
if ($Destino.StartsWith($repoRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Guarde o backup fora do projeto e da pasta PLAYSTORE.' }
if (Test-Path -LiteralPath $Destino) { throw 'O destino ja existe; nao sera substituido.' }
if (-not (Test-Path -LiteralPath (Split-Path $Destino -Parent))) { throw 'Crie e selecione uma pasta privada existente para backup.' }
$sourcePass=Get-Content (Join-Path $SigningDirectory 'upload.password.dpapi') | ConvertTo-SecureString
$backupPass=Read-Host 'Escolha uma senha forte exclusiva para o backup e guarde-a no seu gerenciador de senhas' -AsSecureString
$backupConfirmation=Read-Host 'Repita a senha do backup' -AsSecureString
$sourceCred=New-Object Management.Automation.PSCredential('upload',$sourcePass)
$backupCred=New-Object Management.Automation.PSCredential('backup',$backupPass)
$confirmCred=New-Object Management.Automation.PSCredential('confirm',$backupConfirmation)
$oldSource=$env:DAYTODAY_BACKUP_SOURCE_PASSWORD
$oldDestination=$env:DAYTODAY_BACKUP_DEST_PASSWORD
try {
    if ($backupCred.GetNetworkCredential().Password.Length -lt 16) { throw 'Use pelo menos 16 caracteres na senha do backup.' }
    if ($backupCred.GetNetworkCredential().Password -cne $confirmCred.GetNetworkCredential().Password) { throw 'As senhas nao coincidem.' }
    $env:DAYTODAY_BACKUP_SOURCE_PASSWORD=$sourceCred.GetNetworkCredential().Password
    $env:DAYTODAY_BACKUP_DEST_PASSWORD=$backupCred.GetNetworkCredential().Password
    $tool=Join-Path $env:ProgramFiles 'Android/Android Studio/jbr/bin/keytool.exe'
    & $tool '-importkeystore' '-noprompt' '-srckeystore' (Join-Path $SigningDirectory 'daytoday-upload.jks') '-srcalias' 'daytoday-upload' '-srcstorepass:env' 'DAYTODAY_BACKUP_SOURCE_PASSWORD' '-srckeypass:env' 'DAYTODAY_BACKUP_SOURCE_PASSWORD' '-destkeystore' $Destino '-deststoretype' 'PKCS12' '-destalias' 'daytoday-upload' '-deststorepass:env' 'DAYTODAY_BACKUP_DEST_PASSWORD' '-destkeypass:env' 'DAYTODAY_BACKUP_DEST_PASSWORD'
    if ($LASTEXITCODE -ne 0) { throw 'Exportacao falhou; preserve a chave original.' }
    & $tool '-list' '-keystore' $Destino '-storetype' 'PKCS12' '-storepass:env' 'DAYTODAY_BACKUP_DEST_PASSWORD' '-alias' 'daytoday-upload'
    if ($LASTEXITCODE -ne 0) { throw 'Verificacao do backup falhou.' }
    Write-Output 'Backup PKCS12 protegido e verificado. Guarde duas copias privadas e a senha separadamente. Nunca envie esse backup para o GitHub, ZIP de publicacao ou terceiros.'
} finally {
    $env:DAYTODAY_BACKUP_SOURCE_PASSWORD=$oldSource
    $env:DAYTODAY_BACKUP_DEST_PASSWORD=$oldDestination
    $sourceCred=$null; $backupCred=$null; $confirmCred=$null
}
