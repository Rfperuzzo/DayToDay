# DayToDay oi oi

**Sua rotina, no seu ritmo.**

DayToDay é um organizador de rotinas para Android. Planeje atividades, acompanhe
seu progresso e reorganize o dia quando os planos mudarem — tudo offline, sem
conta e com os dados armazenados no próprio aparelho.

## Funcionalidades

- **Painel diário:** calendário contínuo, progresso e próxima atividade.
- **Rotinas flexíveis:** atividades únicas, diárias ou em dias da semana, com
  horário, duração e prioridade.
- **Subtarefas:** organize cada atividade em etapas e acompanhe sua conclusão.
- **Sequência diária:** conclua a tarefa atual para liberar a próxima, inclusive
  antes do horário previsto.
- **Alarmes:** áudio em loop, vibração e tela cheia quando autorizada pelo Android.
- **Reagendamento inteligente:** ao escolher **Agora não** ou perder a janela de
  uma tarefa, o app reorganiza a fila por importância, protegendo as durações.
- **Widget Android:** veja as tarefas do dia e abra uma atividade na tela inicial.

A identidade visual combina off-white, branco, cinza e grafite, com um ícone de
calendário e marca de conclusão. Os alarmes dependem dos acessos concedidos e das
restrições do Android e do fabricante.

## Desenvolvimento

O projeto usa Flutter 3.44.2, Dart 3.12.2 e Android 7.0 (API 24) ou superior.
Configure o Flutter e o Android SDK antes de executar:

```powershell
git clone https://github.com/Rfperuzzo/DayToDay.git
cd DayToDay
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

O APK é gerado em `build/app/outputs/flutter-apk/app-debug.apk`.
Para criar o instalador portátil de testes para Windows, com ADB:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package_debug_installer.ps1
```

## Documentação

Leia [DOCUMENTOS.md](DOCUMENTOS.md) antes de alterar código: ele reúne as decisões,
a arquitetura, as regras de negócio e os próximos passos.

- [Identidade visual](docs/REFERENCIA_VISUAL.md)
- [Roadmap do produto](docs/ROADMAP_PRODUTO.md)
- [Calendário mensal](docs/CALENDARIO_MENSAL.md)
- [Widget da tela inicial](docs/WIDGET_TELA_INICIAL.md)
- [Instalador de testes](docs/INSTALADOR_DEBUG.md)
- [Validações anteriores em aparelho](docs/VALIDACAO_DISPOSITIVO.md)

## Compatibilidade

DayToDay é a evolução do projeto Rotina da Jhenifer. O histórico Git foi
preservado, assim como os identificadores técnicos do app e do banco local,
para manter os dados em atualizações com assinatura compatível.

## Repositório

[Rfperuzzo/DayToDay](https://github.com/Rfperuzzo/DayToDay)
