# Instalador debug — Rotina da Andriele

Este pacote instala ou atualiza o aplicativo em um celular Android conectado ao
Windows por USB. Flutter e Android Studio não precisam estar instalados: o ADB
necessário já acompanha o pacote.

## Instalação rápida

1. Extraia todo o conteúdo do ZIP para uma pasta.
2. No celular, ative **Opções do desenvolvedor > Depuração USB**.
3. Conecte o celular com um cabo USB de dados e desbloqueie a tela.
4. Execute `Instalar-Rotina-Debug.cmd`.
5. Se o Android perguntar, aceite **Permitir depuração USB**.

O instalador detecta o aparelho, instala o APK e abre o aplicativo. Quando há
mais de um celular conectado, ele permite escolher o destino.

## Diagnóstico

- **Celular não encontrado:** mude o modo USB para transferência de arquivos e
  confira se o cabo suporta dados.
- **Não autorizado:** desbloqueie o celular e aceite a autorização RSA de
  depuração USB.
- **Assinatura incompatível:** há outra versão do app com assinatura diferente.
  Desinstalá-la resolve, mas também apaga os dados locais dessa instalação.

Opções avançadas podem ser passadas ao arquivo `.cmd`:

```powershell
Instalar-Rotina-Debug.cmd -Serial IDENTIFICADOR
Instalar-Rotina-Debug.cmd -SkipLaunch
Instalar-Rotina-Debug.cmd -ShowLogs
```

Este é um APK de desenvolvimento. A instalação é local, não publica o app e
não envia arquivos ou dados para a internet.
