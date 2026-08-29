# Instalador debug para celulares Android

## Objetivo

O instalador portátil permite que uma pessoa no Windows instale ou atualize a
versão debug da Rotina da Jhenifer em um celular Android por USB, sem precisar
configurar Flutter, Java ou Android Studio.

O ZIP contém:

- o APK debug mais recente;
- o ADB e as DLLs oficiais presentes no Android SDK local;
- um iniciador `.cmd` para uso por duplo clique;
- o instalador PowerShell e instruções de uso.

## Fluxo implementado

1. Localiza o ADB empacotado, o SDK Android local ou um `adb` disponível no
   `PATH`.
2. Detecta celulares conectados e separa estados autorizado, não autorizado e
   offline.
3. Permite escolher o destino quando há vários aparelhos.
4. Instala com atualização de dados (`adb install -r -d`).
5. Abre `com.senhoritajhenifer.rotina/.MainActivity` após o sucesso.
6. Opcionalmente acompanha o `logcat` do processo para depuração.

O instalador não desinstala versões incompatíveis automaticamente, pois isso
apagaria os dados locais. Nesse caso, ele explica a situação e deixa a decisão
com a pessoa responsável pelo teste.

## Gerar o pacote

Com um Android SDK instalado no Windows:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package_debug_installer.ps1
```

O empacotador executa `flutter build apk --debug --no-pub` e grava o ZIP em
`outputs/Rotina-da-Jhenifer-Debug-Windows.zip`.

Para reaproveitar um APK já validado:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package_debug_installer.ps1 -SkipBuild
```

Um SDK fora do local padrão pode ser informado por `-AdbDirectory`. O diretório
precisa conter `adb.exe`, `AdbWinApi.dll` e `AdbWinUsbApi.dll`.

## Executar sem empacotar

O instalador também pode ser usado diretamente no repositório:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/debug_installer/install_debug.ps1
```

Parâmetros úteis:

- `-Serial <id>`: escolhe um aparelho sem interação;
- `-SkipLaunch`: instala sem abrir o app;
- `-ShowLogs`: abre o `logcat` do processo após iniciar;
- `-ApkPath <arquivo>` e `-AdbPath <arquivo>`: substituem a detecção automática;
- `-NonInteractive`: falha de forma explícita se houver vários aparelhos.

## Segurança e limitações

- O processo é local e não usa rede ou telemetria.
- A Depuração USB concede acesso elevado ao computador; deve ser desativada ou
  ter a autorização revogada após os testes em aparelhos pessoais.
- O APK usa a chave debug do ambiente de desenvolvimento e não deve ser
  distribuído como versão de produção.
- O pacote atual é um instalador para Windows e celulares Android por USB.
