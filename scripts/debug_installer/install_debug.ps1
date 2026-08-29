[CmdletBinding()]
param(
    [string]$Serial,
    [string]$ApkPath,
    [string]$AdbPath,
    [switch]$SkipLaunch,
    [switch]$ShowLogs,
    [switch]$NonInteractive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$packageName = 'com.senhoritajhenifer.rotina'
$mainActivity = "$packageName/.MainActivity"

function Resolve-AdbPath {
    param([string]$RequestedPath)

    $candidates = [System.Collections.Generic.List[string]]::new()
    if ($RequestedPath) {
        $candidates.Add($RequestedPath)
    }

    $candidates.Add((Join-Path $PSScriptRoot 'platform-tools\adb.exe'))

    if ($env:LOCALAPPDATA) {
        $candidates.Add((Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe'))
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $command = Get-Command adb -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw 'ADB não encontrado. Use o pacote completo do instalador ou informe -AdbPath.'
}

function Resolve-ApkPath {
    param([string]$RequestedPath)

    $candidates = [System.Collections.Generic.List[string]]::new()
    if ($RequestedPath) {
        $candidates.Add($RequestedPath)
    }

    $candidates.Add((Join-Path $PSScriptRoot 'app-debug.apk'))
    $projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $candidates.Add((Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-debug.apk'))

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw 'APK debug não encontrado. Gere-o com "flutter build apk --debug" ou informe -ApkPath.'
}

function Invoke-Adb {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,
        [switch]$AllowFailure
    )

    $output = @(& $script:resolvedAdbPath @Arguments 2>&1 | ForEach-Object { "$_" })
    $exitCode = $LASTEXITCODE

    if (($exitCode -ne 0) -and (-not $AllowFailure)) {
        $details = ($output -join [Environment]::NewLine).Trim()
        if (-not $details) {
            $details = "ADB encerrou com código $exitCode."
        }
        throw $details
    }

    [pscustomobject]@{
        ExitCode = $exitCode
        Output = $output
    }
}

function Get-DeviceModel {
    param([string]$DeviceSerial)

    $result = Invoke-Adb -Arguments @('-s', $DeviceSerial, 'shell', 'getprop', 'ro.product.model') -AllowFailure
    $model = ($result.Output -join ' ').Trim()
    if ($result.ExitCode -ne 0 -or -not $model) {
        return 'modelo não identificado'
    }
    return $model
}

function Select-TargetDevice {
    param(
        [object[]]$AuthorizedDevices,
        [string]$RequestedSerial
    )

    if ($RequestedSerial) {
        $selected = @($AuthorizedDevices | Where-Object { $_.Serial -eq $RequestedSerial })
        if ($selected.Count -eq 0) {
            throw "O aparelho '$RequestedSerial' não está conectado e autorizado."
        }
        return $selected[0]
    }

    if ($AuthorizedDevices.Count -eq 1) {
        return $AuthorizedDevices[0]
    }

    if ($NonInteractive) {
        throw 'Há mais de um celular conectado. Execute novamente com -Serial <identificador>.'
    }

    Write-Host ''
    Write-Host 'Escolha o celular:' -ForegroundColor Cyan
    for ($index = 0; $index -lt $AuthorizedDevices.Count; $index++) {
        $device = $AuthorizedDevices[$index]
        $model = Get-DeviceModel -DeviceSerial $device.Serial
        Write-Host "  $($index + 1)) $model [$($device.Serial)]"
    }

    while ($true) {
        $answer = Read-Host "Digite um número de 1 a $($AuthorizedDevices.Count)"
        $chosenIndex = 0
        if ([int]::TryParse($answer, [ref]$chosenIndex) -and
            $chosenIndex -ge 1 -and
            $chosenIndex -le $AuthorizedDevices.Count) {
            return $AuthorizedDevices[$chosenIndex - 1]
        }
        Write-Host 'Escolha inválida.' -ForegroundColor Yellow
    }
}

try {
    Write-Host ''
    Write-Host 'Rotina da Jhenifer — instalador debug' -ForegroundColor Magenta
    Write-Host '====================================' -ForegroundColor DarkMagenta

    $script:resolvedAdbPath = Resolve-AdbPath -RequestedPath $AdbPath
    $resolvedApkPath = Resolve-ApkPath -RequestedPath $ApkPath

    Write-Host "APK: $resolvedApkPath"
    Write-Host 'Procurando celulares conectados...'

    $null = Invoke-Adb -Arguments @('start-server')
    $deviceResult = Invoke-Adb -Arguments @('devices')
    $devices = @()

    foreach ($line in $deviceResult.Output) {
        if ($line -match '^([^\s]+)\s+(device|unauthorized|offline)$') {
            $devices += [pscustomobject]@{
                Serial = $Matches[1]
                State = $Matches[2]
            }
        }
    }

    $unauthorized = @($devices | Where-Object { $_.State -eq 'unauthorized' })
    $offline = @($devices | Where-Object { $_.State -eq 'offline' })
    $authorized = @($devices | Where-Object { $_.State -eq 'device' })

    if ($authorized.Count -eq 0) {
        if ($unauthorized.Count -gt 0) {
            throw 'O celular foi encontrado, mas ainda não autorizou este computador. Desbloqueie a tela e aceite a mensagem "Permitir depuração USB".'
        }
        if ($offline.Count -gt 0) {
            throw 'O celular está offline. Reconecte o cabo USB, desbloqueie a tela e tente novamente.'
        }
        throw 'Nenhum celular foi encontrado. Ative as Opções do desenvolvedor e a Depuração USB, conecte um cabo de dados e tente novamente.'
    }

    $target = Select-TargetDevice -AuthorizedDevices $authorized -RequestedSerial $Serial
    $model = Get-DeviceModel -DeviceSerial $target.Serial

    Write-Host ''
    Write-Host "Celular: $model [$($target.Serial)]" -ForegroundColor Cyan
    Write-Host 'Instalando ou atualizando o aplicativo...'

    $installResult = Invoke-Adb -Arguments @('-s', $target.Serial, 'install', '-r', '-d', $resolvedApkPath) -AllowFailure
    $installText = ($installResult.Output -join [Environment]::NewLine).Trim()
    if ($installResult.ExitCode -ne 0 -or $installText -notmatch '(?m)^Success\s*$') {
        if ($installText -match 'INSTALL_FAILED_UPDATE_INCOMPATIBLE') {
            throw "Existe outra versão do app assinada com uma chave diferente. Desinstale-a manualmente se puder perder os dados e execute o instalador de novo.`n$installText"
        }
        throw "A instalação falhou.`n$installText"
    }

    Write-Host 'Aplicativo instalado com sucesso.' -ForegroundColor Green

    if (-not $SkipLaunch) {
        Write-Host 'Abrindo o aplicativo...'
        $launchResult = Invoke-Adb -Arguments @('-s', $target.Serial, 'shell', 'am', 'start', '-n', $mainActivity) -AllowFailure
        if ($launchResult.ExitCode -ne 0) {
            Write-Host 'O app foi instalado, mas não pôde ser aberto automaticamente.' -ForegroundColor Yellow
            Write-Host ($launchResult.Output -join [Environment]::NewLine)
        }
    }

    if ($ShowLogs) {
        Write-Host ''
        Write-Host 'Exibindo logs do app. Pressione Ctrl+C para encerrar.' -ForegroundColor Cyan
        $pidResult = Invoke-Adb -Arguments @('-s', $target.Serial, 'shell', 'pidof', $packageName) -AllowFailure
        $processId = ($pidResult.Output -join ' ').Trim().Split(' ')[0]
        if ($pidResult.ExitCode -eq 0 -and $processId) {
            & $script:resolvedAdbPath '-s' $target.Serial 'logcat' "--pid=$processId"
        } else {
            Write-Host 'O processo ainda não está ativo; mostrando o log geral do Flutter.' -ForegroundColor Yellow
            & $script:resolvedAdbPath '-s' $target.Serial 'logcat' '-s' 'flutter'
        }
    }

    Write-Host ''
    Write-Host 'Tudo pronto.' -ForegroundColor Green
    exit 0
} catch {
    Write-Host ''
    Write-Host 'Não foi possível concluir a instalação:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
