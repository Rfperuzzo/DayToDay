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
- O alarme toca até uma resposta explícita: **Concluir**, **Agora não** ou
  **Pular hoje**.
- **Agora não** encerra o toque e o motor escolhe automaticamente o próximo
  espaço livre.
- O dia útil padrão vai de 07h a 22h.
- O motor respeita prioridade e duração, evita sobreposições, tenta no máximo
  três reagendamentos no mesmo dia e depois leva a ocorrência para o próximo
  dia disponível.
- A recorrência original nunca é deslocada por um reagendamento; somente a
  ocorrência atual muda.
- Tocar em uma tarefa abre ações para editar ou cancelar. A edição de nome e
  horário vale para a atividade e suas próximas repetições, substituindo os
  alarmes antigos. O cancelamento exige confirmação, desativa a atividade e
  remove todos os alarmes futuros.
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
```

Cada funcionalidade pode ter `domain`, `application`, `data` e
`infrastructure`. Código do domínio não importa Flutter, plugins, SQLite ou APIs
Android.

### Contratos centrais

- `ActivityRepository`: grava e consulta atividades.
- `OccurrenceRepository`: grava ocorrências e seus estados.
  Também expõe uma observação reativa por intervalo para alimentar o painel.
- `ActivityEventRepository`: mantém o histórico de decisões.
- `AlarmGateway`: agenda, cancela e reconcilia alarmes sem expor o plugin.
- `AlarmPermissionGateway`: relata capacidade exata, notificações, tela cheia
  e Não Perturbe.
- `AlarmResponseService`: aplica **Concluir**, **Agora não** e **Pular hoje**,
  encerra o toque, registra o histórico e reconcilia o Resgate de rotina.
- `RoutinePlanner`: gera recorrências e encontra o próximo espaço livre.
- `ActivityCreator`: salva uma atividade, materializa o horizonte de ocorrências
  e tenta reconciliar os alarmes sem perder o cadastro em caso de degradação.
- `Clock`: torna cálculos temporais determinísticos nos testes.

Implementações atuais: Riverpod 3.4.2, Drift 2.34.3, `alarm` 5.12.0,
`permission_handler` 12.0.1 e banco de fusos IANA 2025c.

## Dados locais

O schema inicial possui cinco conjuntos:

1. `activities`: descrição, duração, prioridade, recorrência e estado ativo.
2. `occurrences`: horário planejado, horário atual, tentativa e estado.
3. `activity_events`: histórico append-only das ações da usuária e do sistema.
4. `user_preferences`: janela do dia e política de reagendamento.
5. `app_metadata`: versão do schema e última reconciliação dos alarmes.

Horários únicos são persistidos como instantes UTC. Recorrências guardam horário
local e dias da semana para continuarem no mesmo horário após mudança de fuso.

## Regras de alarmes

- Usar um horizonte móvel de 30 dias, limitado aos próximos 200 alarmes.
- Agendamento e cancelamento devem ser idempotentes.
- Reconciliar após inicialização, reinício, atualização, alteração de relógio ou
  fuso e após cada ação em um alarme.
- Não permitir que deslizar a notificação silencie acidentalmente um alarme.
- Alarmes simultâneos devem tocar sequencialmente, nunca misturar áudios.
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
de empacotamento e instalação está em `docs/INSTALADOR_DEBUG.md`.

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
- [x] Edição de nome/horário e cancelamento a partir da tarefa no painel.

## Última validação

Executada em 29/08/2026:

- `flutter analyze`: nenhum problema encontrado.
- `flutter test --no-pub`: 27 testes aprovados.
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
- APK debug independente para instalação direta, sem celular conectado ao
  Windows: assinatura APK v2 verificada, 182.461.163 bytes e SHA-256
  `DC0368AFE252A48BED617D2A690DEFB8B3C5D8D2F55E5651EC462CA590BA36C1`.
- Edição e cancelamento: testes de domínio, substituição de alarmes, folha de
  opções, formulário e toque na tarefa aprovados; análise estática sem erros.

Os APKs e o ZIP existentes foram gerados antes da edição/cancelamento e não
contêm essa funcionalidade. Um novo debug deve ser criado somente após o
comando explícito do responsável pelo projeto.

Existe um aviso não bloqueante: os plugins `alarm` e `flutter_timezone` ainda
aplicam o Kotlin Gradle Plugin tradicional. A versão atual compila; antes de uma
futura atualização grande do Flutter, revisar os changelogs desses plugins.

## Próxima etapa recomendada

Criar uma página de diagnóstico dos acessos do alarme, validar um APK release
assinado e ampliar a matriz para fabricantes com políticas agressivas de
bateria. Depois, evoluir a explicação do Resgate para nomear qual compromisso
foi protegido.
