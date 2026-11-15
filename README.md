# DayToDay

**Sua rotina, no seu ritmo.**

DayToDay é um organizador de rotinas para Android. Planeje atividades, acompanhe
seu progresso e reorganize o dia quando os planos mudarem — tudo offline, sem
conta e com os dados armazenados no próprio aparelho.

## Funcionalidades

- **Lembrete simples por padrão:** horário e repetição, sem reserva de tempo.
- **Reservar tempo, opcional:** blocos com duração e proteção contra sobreposição.
- **Repetição flexível:** uma vez, todo dia, dias úteis ou dias específicos.
- **Painel diário:** calendário, progresso, próxima ação e filtro Só pendentes.
- **Parar alarme separado de Concluir:** silenciar mantém a atividade pendente.
- **Lembrar em 10 minutos:** adia somente o lembrete, sem mover outras tarefas.
- **Subtarefas:** organize cada atividade em etapas e acompanhe a conclusão.
- **Sequência dos blocos:** conclua, pule ou cancele o bloco atual para liberar o próximo;
  lembretes funcionam independentemente dessa sequência.
- **Alarmes:** execução única do som, vibração e tela cheia quando autorizada.
- **Reorganização:** blocos podem buscar outro intervalo livre; sua duração é
  reserva de agenda, não tempo de toque. Lembretes não provocam cascata.
- **Widget Android:** modos, horários e estados aparecem no resumo do dia.

Atividades existentes são preservadas como blocos na migração para schema 3.
Sem conta, assinatura ou serviço pago. A comparação com apps atuais, a revisão
independente e os ensaios estão em [UX de lembretes](docs/UX_LEMBRETES_20261114.md).

A identidade visual combina verde-petróleo, superfícies claras e acentos pêssego, com um ícone de
calendário e marca de conclusão. Os alarmes dependem dos acessos concedidos e das
restrições do Android e do fabricante.

## Desenvolvimento

O kit de publicação está em [PLAYSTORE](PLAYSTORE/00_LEIA_PRIMEIRO.md), com seis
imagens, ícone, destaque, textos, política própria e checklist. Materiais prontos
não significam liberação para upload: assinatura, URL/acesso à privacidade e
declarações/ensaios da loja permanecem indicados no kit.

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
