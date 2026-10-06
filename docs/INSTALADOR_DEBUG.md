# Instalador debug para celulares Android

## Instalação direta sem conectar o celular ao Windows

O arquivo `Rotina-da-Jhenifer-debug-android.apk` pode ser enviado ao celular por
Drive, WhatsApp, e-mail, cabo ou outro meio. Não é necessário conectar o
aparelho ao computador durante a instalação.

No celular:

1. Baixe ou copie o APK.
2. Abra o arquivo pelo gerenciador de arquivos ou pelo aplicativo que o recebeu.
3. Quando o Android solicitar, autorize **Instalar apps desconhecidos** apenas
   para esse aplicativo de origem.
4. Confirme **Instalar** e depois abra **Rotina da Jhenifer**.

Depois da instalação, a autorização para instalar apps desconhecidos pode ser
desativada novamente. O pacote `com.senhoritajhenifer.rotina` representa a nova
identidade e é instalado separadamente de apps com outro Application ID; os dados locais
não são migrados automaticamente.

## APK atual

Gere o APK com `flutter build apk --debug --no-pub`. O resultado fica em
`build/app/outputs/flutter-apk/app-debug.apk`. Distribua-o com o nome
`Rotina-da-Jhenifer-debug-android.apk`.

Pacote: `com.senhoritajhenifer.rotina`, versão `1.0.0`.
A assinatura é de desenvolvimento. Hashes e tamanhos de builds históricos
não descrevem esta nova compilação.

Build validado em 05/10/2026: 162.807.156 bytes, assinatura APK v2 verificada.
SHA-256: `38C42A1EF305DA346DFF22C6F06EE2931519545444C62305B29CDF3D430ACCBC`.

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
