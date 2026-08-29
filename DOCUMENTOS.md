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
- Nenhum layout de produto nesta etapa; apenas bootstrap técnico vazio.
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
```

Cada funcionalidade pode ter `domain`, `application`, `data` e
`infrastructure`. Código do domínio não importa Flutter, plugins, SQLite ou APIs
Android.

### Contratos centrais

- `ActivityRepository`: grava e consulta atividades.
- `OccurrenceRepository`: grava ocorrências e seus estados.
- `ActivityEventRepository`: mantém o histórico de decisões.
- `AlarmGateway`: agenda, cancela e reconcilia alarmes sem expor o plugin.
- `AlarmPermissionGateway`: relata capacidade exata, notificações, tela cheia
  e Não Perturbe.
- `RoutinePlanner`: gera recorrências e encontra o próximo espaço livre.
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

As duas últimas ideias não serão ativadas antes de uma decisão de interface.

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
- [x] Bootstrap vazio, sem layout de produto.
- [x] Identidade e versões Android configuradas.
- [x] Domínio e recorrência.
- [x] Persistência SQLite.
- [x] Motor de reagendamento.
- [x] Adaptador de alarmes Android.
- [ ] Testes e build validados.
