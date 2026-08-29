# Memória viva — Rotina da Jhenifer

Atualize este documento no mesmo commit de qualquer mudança que altere regras,
arquitetura, dependências importantes ou escopo.

## Objetivo

Construir um aplicativo Android, offline e sem conta, que ajude a senhorita
Jhenifer a organizar suas atividades. Cada atividade pode gerar um alarme forte
e a rotina pode ser reorganizada automaticamente sem enviar dados para a nuvem.

## Decisões confirmadas

- Android primeiro; a arquitetura não deve impedir uma futura versão iOS.
- Flutter 3.44.2 e Dart 3.12.2.
- Nome provisório: **Rotina da Jhenifer**.
- Application ID: `com.senhoritajhenifer.rotina`.
- Android mínimo 24; compile/target SDK 36.
- Dados somente locais, sem conta, backend, anúncios ou telemetria.
- A distribuição de testes usa um instalador portátil para Windows com APK
  debug e ADB incluídos; Flutter e Android Studio não são necessários na
  máquina que fará a instalação por USB.
- A experiência visual parte da referência Stitch **Vibrant Momentum**: rosa
  energético, superfícies claras, formas arredondadas e pouco ruído visual.
- A ilustração recebida da Jhenifer é o ícone oficial do aplicativo. A fonte
  original fica preservada em `assets/branding/`, e o Android recebe variantes
  legada, redonda e adaptativa em todas as densidades.
- O primeiro layout de produto é o painel diário, com semana navegável,
  progresso, próxima atividade e conclusão rápida.
- O cadastro nasce do botão flutuante central e cobre título, observação, dia,
  horário, duração, prioridade e repetição.
- Repetições disponíveis no primeiro fluxo: única, diária e dias úteis.
- Permissões do alarme são explicadas e solicitadas no contexto do primeiro
  cadastro. A atividade continua salva se algum acesso for negado.
- Quando o plugin informa que um alarme está tocando, o app substitui o painel
  pela tela de resposta e impede voltar sem uma decisão explícita.
- O resultado de **Agora não** mostra o novo horário e quantas atividades foram
  ajustadas antes de retornar ao painel.
- Atividades podem ser únicas, diárias ou repetidas em dias da semana.
- Todo alarme é forte: áudio em loop, vibração, tela cheia quando autorizada e
  tentativa de tocar durante Não Perturbe.
- O alarme toca até uma resposta explícita — **Concluir**, **Agora não** ou
  **Pular hoje** — ou até o fim da duração reservada. Se a duração terminar sem
  resposta, a tarefa entra automaticamente na recuperação por importância.
- **Agora não** encerra o toque e o motor escolhe automaticamente o próximo
  espaço livre.
- O dia útil padrão vai de 07h a 22h.
- O motor respeita prioridade e duração, evita sobreposições, tenta no máximo
  três reagendamentos no mesmo dia e depois leva a ocorrência para o próximo
  dia disponível.
- A duração é obrigatória no cadastro e editável depois. O intervalo inteiro
  fica reservado; o app recusa um horário cuja duração invada outra tarefa e
  informa o próximo horário livre.
- As tarefas pendentes de cada dia formam uma sequência. Apenas a primeira fica
  disponível para conclusão e recebe alarme; as seguintes permanecem bloqueadas
  até a anterior ser concluída, pulada ou cancelada.
- Uma tarefa disponível pode ser concluída antes do horário ou do fim estimado.
  A conclusão antecipada libera imediatamente a próxima tarefa e reconcilia os
  alarmes do Android.
- Quando a tarefa atual perde sua janela sem confirmação, ela é comparada com a
  próxima. Se sua importância for maior, ocupa o próximo horário e desloca a
  outra; a tarefa deslocada repete a comparação com o restante da fila.
- Importância igual ou menor não toma o lugar de uma tarefa mais importante. Ao
  chegar ao fim da sequência, a tarefa ainda não posicionada é marcada para 10
  minutos depois do fim da fila — ou 10 minutos após a detecção quando não há
  próxima tarefa. Todas as durações continuam protegidas contra sobreposição.
- A recorrência original nunca é deslocada por um reagendamento; somente a
  ocorrência atual muda.
- Tocar em uma tarefa abre ações para editar, gerenciar subtarefas ou cancelar.
  A edição permite alterar nome, horário, duração e repetição entre **Só este
  dia**, **Todo dia** e **Seg–sex**. A nova regra vale para a atividade e suas
  próximas ocorrências, substituindo os alarmes antigos. O cancelamento exige
  confirmação, desativa a atividade e remove todos os alarmes futuros.
- Subtarefas são etapas persistentes vinculadas à atividade principal. Podem
  ser adicionadas, concluídas, reabertas e removidas; não criam alarmes próprios
  nem alteram a recorrência da atividade.
- O Android oferece o widget **Tarefas de hoje**, com data, progresso e até
  quatro tarefas. Tocar em uma tarefa abre sua ocorrência no app para concluir
  ou editar; uma tarefa bloqueada continua impedida de ser concluída fora da
  ordem.
- O widget recebe sete dias de resumo offline e escolhe o dia atual no Android,
  permitindo a virada da data sem depender de o Flutter estar aberto à
  meia-noite. Alterações no banco atualizam o resumo quando o app está ativo.
- Edições e cancelamentos ficam registrados no histórico local. Se a
  sincronização com o Android falhar, a alteração permanece salva e o app
  comunica o estado degradado.

## Arquitetura

O código segue organização por funcionalidade, com dependências apontando para
o domínio:

```text
lib/
  app/                 bootstrap e composição de dependências
  core/                relógio, identificadores, erros e utilitários
  features/
    activities/        atividade, recorrência e ocorrências
    alarms/            contratos e adaptadores de alarmes/permissões
    routine_engine/     conflitos e reagendamento automático
    history/            eventos imutáveis da rotina
    settings/           preferências locais
    dashboard/          leitura do dia, progresso e ações rápidas
    home_widget/        resumo nativo e abertura direcionada da tarefa
```

Cada funcionalidade pode ter `domain`, `application`, `data` e
`infrastructure`. Código do domínio não importa Flutter, plugins, SQLite ou APIs
Android.

### Contratos centrais

- `ActivityRepository`: grava e consulta atividades.
- `SubtaskRepository`: observa e mantém as etapas vinculadas a uma atividade.
- `OccurrenceRepository`: grava ocorrências e seus estados.
  Também expõe uma observação reativa por intervalo para alimentar o painel.
- `ActivityEventRepository`: mantém o histórico de decisões.
- `AlarmGateway`: agenda, cancela e reconcilia alarmes sem expor o plugin.
- `AlarmPermissionGateway`: relata capacidade exata, notificações, tela cheia
  e Não Perturbe.
- `AlarmResponseService`: aplica **Concluir**, **Agora não** e **Pular hoje**,
  encerra o toque, registra o histórico e reconcilia o Resgate de rotina.
- `MissedTaskRecoveryService`: detecta a perda da janela, persiste a cascata por
  importância, registra os deslocamentos e reconcilia o próximo alarme.
- `RoutinePlanner`: gera recorrências e encontra o próximo espaço livre.
- `ActivityCreator`: salva uma atividade, materializa o horizonte de ocorrências
  e tenta reconciliar os alarmes sem perder o cadastro em caso de degradação.
- `Clock`: torna cálculos temporais determinísticos nos testes.
- `DayWidgetGateway`: sincroniza o resumo de sete dias com o widget Android e
  entrega ao Flutter a tarefa tocada na tela inicial.

Implementações atuais: Riverpod 3.4.2, Drift 2.34.3, `alarm` 5.12.0,
`permission_handler` 12.0.1 e banco de fusos IANA 2025c.

## Dados locais

O schema atual, versão 2, possui seis conjuntos:

1. `activities`: descrição, duração, prioridade, recorrência e estado ativo.
2. `occurrences`: horário planejado, horário atual, tentativa e estado.
3. `activity_events`: histórico append-only das ações da usuária e do sistema.
4. `user_preferences`: janela do dia e política de reagendamento.
5. `app_metadata`: versão do schema e última reconciliação dos alarmes.
6. `subtasks`: etapas relacionadas à atividade, ordem, conclusão e datas.

Horários únicos são persistidos como instantes UTC. Recorrências guardam horário
local e dias da semana para continuarem no mesmo horário após mudança de fuso.

## Regras de alarmes

- Usar um horizonte móvel de 30 dias, limitado aos próximos 200 alarmes.
- Agendamento e cancelamento devem ser idempotentes.
- Reconciliar após inicialização, reinício, atualização, alteração de relógio ou
  fuso e após cada ação em um alarme.
- Não permitir que deslizar a notificação silencie acidentalmente um alarme.
- Alarmes simultâneos devem tocar sequencialmente, nunca misturar áudios.
- Para cada dia, somente a primeira ocorrência pendente fica agendada no
  Android. Ao concluir antecipadamente, pular ou cancelar, a reconciliação
  remove o alarme anterior e prepara a próxima ocorrência liberada.
- O tempo de duração viaja no payload do alarme. A tela inicia a recuperação ao
  final desse período sem resposta; um alarme expirado após reinício também
  aciona a regra. Recusa técnica da plataforma não é tratada como omissão da
  usuária.
- Permissão negada é um estado operacional degradado, não uma exceção fatal.
- Nunca afirmar que um alarme é garantido quando o fabricante ou o Android o
  bloqueou.

## Ideias inovadoras preservadas

- **Resgate de rotina:** reconstrói o restante do dia após **Agora não**.
- **Memória da Jhenifer:** aprende durações reais usando somente histórico local.
- **Barreira anti-caos:** protege prioridades e impede cascatas de sobreposição.
- **Tempo de preparação:** aviso opcional antes da atividade e buffer de
  transição.
- **Pulso do dia:** futuro resumo de manhã e fechamento noturno.

O painel implementa desde já o conceito de **Pulso do dia** na forma de
progresso e mensagem de ritmo, sem pontuação competitiva ou envio de dados.

Detalhes de priorização estão em `docs/ROADMAP_PRODUTO.md`. A transcrição das
decisões da referência Stitch está em `docs/REFERENCIA_VISUAL.md`. A matriz e
as evidências do teste real estão em `docs/VALIDACAO_DISPOSITIVO.md`. O fluxo
de empacotamento e instalação está em `docs/INSTALADOR_DEBUG.md`. A instalação
e o comportamento do widget estão em `docs/WIDGET_TELA_INICIAL.md`.

## Estratégia de Git

- Uma funcionalidade ou mudança arquitetural por commit.
- Mensagens no padrão Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`,
  `chore:`).
- Testes e documentação da funcionalidade entram no mesmo commit sempre que
  possível.
- Não misturar layouts futuros com mudanças do motor de rotina.

O sandbox atual bloqueia escrita em diretórios chamados `.git`. Por isso, o
repositório real usa `.gitdata` como diretório Git separado:

```powershell
git --git-dir=.gitdata --work-tree=. status
git --git-dir=.gitdata --work-tree=. log --oneline
```

Fora do sandbox, a normalização consiste em remover o `.git` vazio protegido e
renomear `.gitdata` para `.git`; nenhum commit é perdido.

## Estado atual

- [x] Repositório e projeto Flutter Android criados.
- [x] Identidade visual e painel diário responsivo.
- [x] Ícone oficial da Jhenifer configurado para launchers Android.
- [x] Cadastro contextual de atividades e preparação de alarmes.
- [x] Identidade e versões Android configuradas.
- [x] Domínio e recorrência.
- [x] Persistência SQLite.
- [x] Motor de reagendamento.
- [x] Adaptador de alarmes Android.
- [x] Casos de uso das três respostas do alarme.
- [x] Tela dedicada do alarme e resultado explicável do Resgate de rotina.
- [x] Testes e build validados.
- [x] Ciclo físico validado com tela bloqueada, processo encerrado e Não
  Perturbe.
- [x] Instalador debug portátil para Windows e celulares Android por USB.
- [x] Edição de nome, horário, repetição e cancelamento a partir da tarefa no
  painel.
- [x] Subtarefas persistentes vinculadas à atividade principal.
- [x] Edição de duração e proteção contra intervalos sobrepostos.
- [x] Sequência diária com tarefas posteriores bloqueadas e conclusão
  antecipada liberando a próxima.
- [x] Recuperação automática de tarefa sem resposta, com cascata por
  importância e fallback de 10 minutos.
- [x] Widget Android com tarefas do dia e abertura direta para concluir ou
  editar.

## Última validação

Executada em 29/08/2026:

- `flutter analyze`: nenhum problema encontrado.
- `flutter test --no-pub`: 43 testes aprovados.
- `:app:compileDebugKotlin`: widget, recursos Android e canal nativo compilados
  com sucesso usando o JBR 21 do Android Studio; nenhum APK foi gerado.
- `flutter build apk --debug`: APK gerado com sucesso.
- Manifest mesclado contém `USE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`,
  notificações, reinício, vibração, wake lock, política de notificação e serviço
  de mídia.
- Manifest mesclado não contém `READ_EXTERNAL_STORAGE` nem
  `SCHEDULE_EXACT_ALARM`.
- Motorola edge 60 fusion com Android 16: cadastro, alarme exato, tela cheia,
  **Agora não**, segundo toque da mesma ocorrência, **Pular hoje**,
  **Concluir**, persistência e cold start aprovados.
- Não Perturbe em modo prioridade: `STREAM_ALARM` sem mute, volume 7/7 e rota
  para o alto-falante. O modo original foi restaurado após o teste.
- Instalador debug: pacote extraído e executado no Windows PowerShell 5 em modo
  simulado; instalação, abertura, aparelho não autorizado e seleção obrigatória
  entre múltiplos aparelhos apresentaram os resultados esperados.
- ZIP portátil gerado com APK e ADB incluídos: 79,7 MB e SHA-256
  `FC4320BE33017D4682F20AF6725DADFFB6DF289B893DDEC7BBDD74A11A96885B`.
- APK debug independente atualizado a partir do commit `a072074`, para
  instalação direta sem celular conectado ao Windows: assinatura APK v2
  verificada, 182.550.404 bytes e SHA-256
  `B1DA81EE9FC551145D6841A4EA543728E592F3990918DC59958DFA8DE47379A0`.
- Edição e cancelamento: testes de domínio, substituição de alarmes, troca entre
  tarefa diária e tarefa única, folha de opções, formulário e toque na tarefa
  aprovados; análise estática sem erros.
- Subtarefas, persistência do schema 2, conflito por duração, sequência diária,
  bloqueio visual, liberação por conclusão antecipada e alarme exclusivo da
  primeira tarefa pendente foram validados por testes automatizados.
- A recuperação de tarefa perdida foi validada para prioridade maior, menor,
  cascata entre várias tarefas, preservação de duração, persistência, histórico
  e ausência de próxima tarefa com reagendamento após 10 minutos.
- Widget: ordenação, progresso, bloqueio sequencial e ação **Concluir tarefa**
  foram validados no Flutter; manifesto, `RemoteViews`, troca automática entre
  os sete dias em cache e código Kotlin foram compilados sem erros.
- Ícone oficial: recursos legado, redondo e adaptativo foram processados com
  sucesso pelo Android Gradle Plugin em todas as densidades.

O APK `outputs/Rotina-da-Jhenifer-debug-android.apk` contém todas as
funcionalidades e a identidade visual listadas acima. O ZIP portátil para
Windows ainda pertence à compilação anterior e deve ser regenerado antes de ser
usado para instalar esta versão por USB.

Existe um aviso não bloqueante: os plugins `alarm` e `flutter_timezone` ainda
aplicam o Kotlin Gradle Plugin tradicional. A versão atual compila; antes de uma
futura atualização grande do Flutter, revisar os changelogs desses plugins.

## Próxima etapa recomendada

Criar uma página de diagnóstico dos acessos do alarme, validar um APK release
assinado e ampliar a matriz para fabricantes com políticas agressivas de
bateria. Depois, evoluir a explicação do Resgate para nomear qual compromisso
foi protegido.
