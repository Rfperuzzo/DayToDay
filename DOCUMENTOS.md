# Memória viva — DayToDay

## Avisos de início, final e troca — 16/11/2026

Versão1.1.0+2, schema4 aditivo: notifyAtStart/notifyAtEnd/usesBoundaryAlarms nas
atividades e ocorrências; endAcknowledgedAtUtc separado. Migrações1/2/3 preservam
IDs, duração, horário, progresso, ciência antiga, subtarefas, preferências e histórico.
Legado mantém usesBoundaryAlarms=false, inícioON/finalOFF e sequência anterior.
Blocos novos ou explicitamente salvos na UI usam avisos independentes por horário.

Cadastro/edição mostram início/final, dia seguinte e duração calculada. AmbosOFF
salva bloco silencioso sem pedir permissões. Lembretes continuam simples, sem fim.
Os seletores forçam24h para corrigir a incompatibilidade do SDK entre localeptBR
e relógioAndroid12h (rejeição de13/15). Durações antigas não são truncadas ao editar.

IDs de início preservados; final usa chave #end:occurrenceId com hash nativo
estável/validação de colisão. Fusão somente entre duas pontas habilitadas no mesmo
instante: o aviso de troca usa a identidade do próximo início e referencia o final
anterior. Silenciar início preserva final; troca confirma duas pontas e não conclui
nenhuma atividade. End/troca orientam conclusão separada na rotina; novos blocos
não ficam bloqueados pela sequência legada. Eventos nativos de falha não movem
intervalos explícitos nem concluem/cancelam atividades automaticamente.

137 testes aprovados e análise limpa. Ensaio nativo com repositórios reais/banco
em memória e gatewayAndroid em segundo plano disparou início/troca/final/endonly;
nenhuma atividade concluída automaticamente. Ver docs/UX_INICIO_FIM_20261116.md.
AAB/APK de produção usam lib/main.dart, mesma chave exclusiva já protegida e
backupjáconferido; entrypoint diagnóstico sob tool/ não é enviado à loja.
Nenhum serviço pago nem acesso ao fitness. Abrir PR para revisão; não publicar na loja.

## Preparação para envio à loja — 15/11/2026

Primeira publicação confirmada pelo titular: gratuito, Brasil, público 13+ sem
direcionamento infantil. O publicador/contato continuam Thales Melo da Silva /
thalesmelodasilva@gmail.com conforme dados públicos já autorizados. Não abrir fitness.

Política própria em https://rfperuzzo.github.io/DayToDay/privacidade.html, hospedada
no GitHub Pages público do DayToDay. Mesma política offline em Privacidade e suporte
no final do painel; link fixo abre navegador externo sem enviar dados de rotina.
A página pública de demonstração também usa esse site. Não há deploy de app na loja.

Manifesto release usa SCHEDULE_EXACT_ALARM mediante concessão do usuário e remove
USE_EXACT_ALARM. Gateway pede um acesso especial por vez; retorno mostra estado
real e fechamento da revisão reconcilia alarmes. Sem migração ou exclusão de dados.

Primeira chave de upload exclusiva criada por autorização, RSA3072/10.000 dias,
fora do repositório. Senha aleatória protegida por DPAPI do Windows/usuário e ACL
privada. Só certificado público no Git/kit. Gradle release não usa Android Debug e
recusa falta de chave salvo opção explícita de diagnóstico unsigned. Scripts de
build e backup portátil em PLAYSTORE; backup exige senha própria do titular.

AAB e APK PRODUCAO assinados e verificados, bundletool1.18.3 validate aprovado,
manifesto API36/mínimo24 sem INTERNET, ELF64/ZIP16KB PASS. 107 testes e análise limpa.
APK da mesma fonte/certificado testado no AVD exclusivo; lembrete criado pela UI
assinada disparou em segundo plano, com serviço foreground e notificação reais.
Parar no app manteve progresso 0 de 1. Vídeo sem edição/áudio e prints na entrega.
MONSTRUX aprovou revalidação visual/factual; não teve acesso à chave privada.

O kit anterior sem assinatura foi substituído por instruções e binário assinados.
Os binários permanecem ignorados no Git e estão na cópia local/ZIP; não confundir
checkout do repositório com entrega que inclui o AAB. A publicação, conta,
Play App Signing, IARC, declarações e relatório de pré-lançamento ficam com o titular.
Execução16KB, aparelhos físicos e eventual teste fechado continuam no checklist;
checagens estáticas/UX não equivalem à aprovação Google. Sem API paga ou nova taxa.

Atualize este documento no mesmo commit de qualquer mudança que altere regras,
arquitetura, dependências importantes ou escopo.

## Objetivo

Construir um aplicativo Android, offline e sem conta, para ajudar qualquer pessoa:
organizar suas rotinas e atividades. Cada atividade pode gerar um alarme forte
e a rotina pode ser reorganizada automaticamente sem enviar dados para a nuvem.

## Decisões confirmadas

- Revisão de lembretes de 14/11/2026: schema 3 aditivo, dados antigos como
  timeBlock, novos lembretes sem reserva, ciência separada de conclusão.
  102 testes, análise limpa e ensaio nativo Android35 com fila/stop/cleanup.
  A fonte atual é docs/UX_LEMBRETES_20261114.md; a rodada cromática abaixo é
  histórica e suas contagens não incluem estas mudanças.

- Revisão MONSTRUX de 14/11/2026: fontes completas e sete jornadas revisadas;
  melhorias e nova paleta revalidadas em capturas sintéticas 1x/2x. Resultado:
  73 testes aprovados, análise limpa e dois builds debug. Evidências e condições
  Android/assinatura ainda pendentes estão em docs/UX_REVIEW_20261114.md.

- Android primeiro; a arquitetura não deve impedir uma futura versão iOS.
- Flutter 3.44.2 e Dart 3.12.2.
- Nome oficial: **DayToDay**.
- Application ID: `com.senhoritajhenifer.rotina`.
- Android mínimo 24; compile/target SDK 36.
- Dados somente locais, sem conta, backend, anúncios ou telemetria.
- A distribuição de testes usa um instalador portátil para Windows com APK
  debug e ADB incluídos; Flutter e Android Studio não são necessários na
  máquina que fará a instalação por USB.
- Identidade acolhedora autorizada em 14/11/2026: verde-petróleo, verdes claros e
  pêssego/terracota em apoio; vermelho apenas para erros e ações destrutivas.
- Ícone oficial: calendário com check, gerado por scripts/generate_daytoday_icons.ps1 em todas as densidades Android. Arte anterior preservada como referência histórica.
- A mudança para DayToDay preserva Application ID, pacote Dart, banco, canais nativos e URI do widget para manter dados em atualizações compatíveis.
- O primeiro layout de produto é o painel diário, com calendário mensal
  contínuo, progresso, próxima atividade e conclusão rápida.
- O cadastro nasce da ação inferior rotulada Nova atividade e cobre título, observação, dia,
  horário, reserva de tempo opcional, prioridade e repetição.
- Repetições: uma vez, todo dia, dias úteis e seleção de dias específicos. A
  edição preserva exatamente a máscara personalizada existente.
- Permissões do alarme são explicadas e solicitadas no contexto do primeiro
  cadastro. A atividade continua salva se algum acesso for negado.
- Quando o plugin informa que um alarme está tocando, o app substitui o painel
  pela tela de resposta e impede voltar sem uma decisão explícita.
- O resultado de **Adiar atividade** mostra o novo horário e quantas atividades foram
  ajustadas antes de retornar ao painel.
- Atividades podem ser únicas, diárias ou repetidas em dias da semana.
- O som executa uma vez, com vibração e tela cheia quando autorizada. O fim
  nativo limpa a fila e o serviço sem concluir nem registrar ciência da tarefa.
- **Parar alarme** no app silencia e registra ciência, mantendo pendência.
  **Concluir** registra realização; **Pular somente hoje** afeta só a ocorrência.
  A notificação Android também permite parar, sem inventar conclusão/ciência.
- **Adiar atividade** reorganiza um bloco para intervalo livre; num lembrete,
  adia dez minutos sem mover outras atividades. O menu do lembrete oferece
  **Lembrar em 10 minutos** mesmo depois de silenciar.
- Duração não controla toque, confirmação nem conclusão. O Timer antigo do
  Router que interpretava o fim da reserva como omissão foi retirado.
- O dia útil padrão vai de 07h a 22h.
- O motor respeita prioridade e duração, evita sobreposições, tenta no máximo
  três reagendamentos no mesmo dia e depois leva a ocorrência para o próximo
  dia disponível.
- Cadastro padrão é lembrete, sem intervalo reservado. **Reservar tempo na
  agenda** ativa duração positiva para um bloco. Lembretes têm kind explícito e
  duração técnica zero, são ignorados pelos conflitos nos dois sentidos e não
  deslocam blocos. Não existe duração oculta de trinta minutos.
- Somente blocos pendentes formam a sequência: o primeiro é liberado; os outros
  aguardam conclusão/pulo/cancelamento. Lembretes podem avisar e ser concluídos
  independentemente. Silenciar um bloco não o conclui nem libera o seguinte.
- Silenciados continuam na lista como **Aviso silenciado · Pendente**, sem mudar
  progresso. Lembretes silenciados não monopolizam o cartão de próxima ação.
- Filtro **Só pendentes** afeta apenas a lista; conserva dados e progresso total.
- Uma tarefa disponível pode ser concluída antes do horário ou do fim estimado.
  A conclusão antecipada libera imediatamente a próxima tarefa e reconcilia os
  alarmes do Android.
- Quando um bloco é detectado como expirado após reinício, ele é comparado com a
  próxima. Se sua importância for maior, ocupa o próximo horário e desloca a
  outra; a tarefa deslocada repete a comparação com o restante da fila.
- Importância igual ou menor não toma o lugar de uma tarefa mais importante. Ao
  chegar ao fim da sequência, a tarefa ainda não posicionada é marcada para 10
  minutos depois do fim da fila — ou 10 minutos após a detecção quando não há
  próxima tarefa. Todas as durações continuam protegidas contra sobreposição.
- A recorrência original nunca é deslocada por um reagendamento; somente a
  ocorrência atual muda.
- Tocar em uma tarefa abre ações para editar, gerenciar subtarefas ou cancelar.
  A edição permite alterar nome, horário, reserva opcional e repetição entre
  **Uma vez**, **Todo dia**, **Seg–sex** e **Dias específicos**. A nova regra vale para a atividade e suas
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
- O horizonte móvel de ocorrências é renovado na inicialização de forma
  idempotente, sem sobrescrever conclusões, pulos, adiamentos ou reagendamentos
  já persistidos. A manutenção nunca cria tarefas retroativas.
- O calendário preserva os cartões diários originais e mostra sete dias por vez
  em uma faixa contínua entre 2000 e 2100. O título acompanha o mês visível,
  enquanto as tarefas só mudam após a seleção explícita de uma data. Meses
  futuros são preparados ao navegar ou selecionar; meses passados exibem apenas
  o histórico existente.
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
- `OccurrenceHorizonMaintainer`: renova os próximos 30 dias e prepara meses
  futuros consultados sem duplicar ocorrências nem reverter estados existentes.
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
- Para cada dia, agendar lembretes independentes e o primeiro bloco pendente,
  respeitando limite de 200. Não rearmar silenciado ou horário passado; conservar
  binding pendente já iniciado durante a reconciliação de outro item.
- Payload antigo com duração continua legível, mas não define prazo de toque.
  Um bloco expirado após reinício pode acionar recuperação; lembrete expirado
  permanece pendente sem deslocar a agenda. Recusa técnica da plataforma não é tratada como omissão da
  usuária.
- Permissão negada é um estado operacional degradado, não uma exceção fatal.
- Nunca afirmar que um alarme é garantido quando o fabricante ou o Android o
  bloqueou.

## Ideias inovadoras preservadas

- **Resgate de rotina:** reconstrói o restante do dia após **Agora não**.
- **Memória da rotina:** aprende durações reais usando somente histórico local.
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
A navegação de datas está descrita em `docs/CALENDARIO_MENSAL.md`.

## Estratégia de Git

- Uma funcionalidade ou mudança arquitetural por commit.
- Mensagens no padrão Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`,
  `chore:`).
- Testes e documentação da funcionalidade entram no mesmo commit sempre que
  possível.
- Não misturar layouts futuros com mudanças do motor de rotina.

O repositório usa Git convencional (`.git`) e preserva o histórico original.
Repositório: https://github.com/Rfperuzzo/DayToDay

## Estado atual

- [x] Repositório e projeto Flutter Android criados.
- [x] Identidade visual e painel diário responsivo.
- [x] Ícone oficial DayToDay configurado para launchers Android.
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
- [x] Manutenção idempotente do horizonte móvel de ocorrências recorrentes.
- [x] Calendário mensal contínuo com seleção diária e preparação de meses
  futuros.

## Identidade DayToDay — 08/10/2026

- Produto reposicionado como organizador de rotinas para qualquer pessoa.
- Marca atualizada no painel, cadastro, Android, widget e instalador.
- Paleta neutra aplicada também ao calendário, formulários e alarme.
- Identificadores técnicos e regras de rotina preservados.
- Registros abaixo descrevem versões históricas.

## Retorno à identidade original — 05/10/2026 (histórico)

- Nome oficial restaurado para **Rotina da Jhenifer** em todas as telas, testes e documentação.
- Pacote Dart: `rotina_jhenifer`; Android: `com.senhoritajhenifer.rotina`.
- Banco, canais nativos, URI do widget e instaladores usam a identidade original.
- Ícone original e suas variantes Android restaurados do commit `1894729`.
- O aplicativo com outro Application ID permanece separado, sem migração automática.
- Uma instalação antiga da Jhenifer só pode ser atualizada se a assinatura for compatível.
- `flutter analyze --no-pub`: nenhum problema encontrado.
- `flutter test --no-pub`: 52 testes aprovados.
- `flutter build apk --debug --no-pub`: APK compilado com sucesso.
- APK inspecionado: nome Rotina da Jhenifer, pacote original, versão 1.0.0, Android mínimo 24.
- Assinatura APK v2 verificada; scripts PowerShell sem erros de sintaxe.
- Nenhuma referência à identidade substituída nos arquivos atuais versionados.
- O teste em aparelho físico não foi repetido nesta revisão; as evidências abaixo são históricas.

## Validação física anterior

Executada em 29/08/2026, antes da troca completa de identidade:

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
- APK debug independente atualizado a partir do commit `7cc4604`, para
  instalação direta sem celular conectado ao Windows: assinatura APK v2
  verificada, 182.562.582 bytes e SHA-256
  `7989BE8FDEFC99D6F3F1C10EBB4EEBD5D6E3F0143DA334228A946243739C8D4D`.
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
- Calendário mensal: meses de 28, 29, 30 e 31 dias, virada de ano, título do mês
  visível, seleção explícita e consulta isolada das tarefas do dia foram
  validados por testes automatizados.

Os APKs antigos não fazem parte da entrega atual. Gere novos artefatos a partir
deste repositório; não renomeie binários anteriores como se fossem novos builds.

Existe um aviso não bloqueante: os plugins `alarm` e `flutter_timezone` ainda
aplicam o Kotlin Gradle Plugin tradicional. A versão atual compila; antes de uma
futura atualização grande do Flutter, revisar os changelogs desses plugins.

## Próxima etapa recomendada

Criar uma página de diagnóstico dos acessos do alarme, validar um APK release
assinado e ampliar a matriz para fabricantes com políticas agressivas de
bateria. Depois, evoluir a explicação do Resgate para nomear qual compromisso
foi protegido.

Validação desta mudança: análise estática sem problemas, 52 testes aprovados e APK debug compilado. Painel renderizado em teste visual; teste em aparelho físico não realizado nesta revisão.


## Piloto local MONSTRUX — 28/10/2026

- Instalação de desenvolvimento isolada do APK, sem dependência Flutter/Android nova.
- Código, dados e regras de rotina preservados; esta rodada prepara uma auditoria UX supervisionada.
- Na preparação inicial, a proteção da franquia bloqueou a sessão. Depois, a primeira análise limitada concluiu com 8.368 tokens e a revisão da síntese ampliada com 8.731. Nenhuma API paga ou modelo local.
- Plano, validações e falha de inicialização em GMT documentados em [MONSTRUX_PILOT.md](docs/MONSTRUX_PILOT.md).
- MONSTRUX privado e controles não são publicados neste repositório público.


## Ajustes UX supervisionados — 28/10/2026

- Calendário dimensionado pelas fontes e escala do sistema: sete dias no tamanho normal e faixa rolável com cartões maiores para texto ampliado, sem limitar a preferência de texto da pessoa.
- Ação central de adicionar em área inferior reservada, sem cobrir a rolagem do painel.
- Nome, observação e nova subtarefa com rótulos persistentes; conclusão com área de toque de 48 dp, mantendo a ordem de liberação das tarefas.
- Menu de edição descreve nome, horário, duração e repetição já disponíveis.
- Paleta, identificadores, banco, regras, motor de rotina e integração de alarmes preservados. O achado GMT permanece aberto.
- Análise estática sem problemas, 54 testes aprovados e APK debug compilado. Escopo, atribuição e limites da revisão em [ux-review.md](docs/monstrux/ux-review.md).


## Agente UX importado — 14/11/2026

- MONSTRUX do Projeto Monstro copiado para `.cursor/agents/monstro-ux.md`,
  com duas skills locais e referências, sem alterar o repositório de origem.
- Contexto adaptado ao DayToDay; método, lições e calibração históricos
  preservados. `docs/MONSTRUX.md` explica uso e limites;
  `.cursor/monstrux-origin.json` registra origem e hashes.
- As 19 skills externas foram copiadas integralmente para `.cursor/skills`,
  preservando pins/hashes e licenças; são 21 skills locais com as duas próprias.
  Não houve alteração global. O perfil não altera o runtime `.monstrux`, seus
  controles ou registros. `python -B tool/validate_ux_skill_pack.py --smoke`
  verifica o pacote sem executar inferência.
- A importação não muda a aplicação e não equivale a revisão de UX executada
  ou aprovação para loja. Testes/resultados do fitness não são herdados.


## Revisão MONSTRUX no DayToDay — 14/11/2026

- Revisão independente com o perfil e as 21 skills locais, selecionadas por
  necessidade. Leitura completa de 52 fontes Dart/Kotlin e 12 arquivos de
  configuração/layout, organizada nas sete jornadas. O repositório fitness
  não foi consultado ou modificado nesta rodada.
- O painel prioriza a próxima ação; progresso compacto, ação Nova atividade
  rotulada, navegação de semana/Hoje e estados com horário, duração e prioridade.
- Criação/edição impedem saída e alteração durante gravação. O editor mantém
  o rascunho e o erro de conflito para corrigir e tentar novamente. As escolhas
  de recorrência são equivalentes e adaptáveis ao texto; regras não mudaram.
- Subtarefas usam rolagem por slivers, inclusive com teclado/texto ampliado.
  Feedback tátil não bloqueia a conclusão da gravação local.
- Localização PT-BR usa flutter_localizations do próprio SDK e intl em cache;
  nenhum SDK foi atualizado. A confirmação de reagendamento inclui a data.
- A revisão dos acessos de alarmes fica disponível no painel e nas respostas
  degradadas. A interface comunica o estado verificado, sem prometer superar
  as restrições do Android/fabricante. Permissões continuam dependentes de ação
  explícita da pessoa e das APIs existentes.
- Inicialização oferece nova tentativa. GMT/UTC são tratados explicitamente;
  fuso desconhecido continua erro, sem fallback silencioso. Identificadores de
  app/banco e contratos do motor, repositórios e dados permanecem estáveis.
- O widget vazio recebe a ação de abrir que anuncia; deep link obsoleto é
  recusado antes das opções. Cancelamento é identificado no resumo nativo.
- Fixtures de UI usam banco em memória e gateways fake, no alvo opcional
  tool/ux_preview.dart. Não integram o entrypoint de produção e não comprovam
  entrega nativa de alarme. Capturas v1/v2 foram descartadas por cache de build;
  v3 foi validada por conteúdo do APK e condição visível do destino.
- Resultados e cobertura detalhados em docs/UX_REVIEW_20261114.md. A rodada não
  certifica WCAG nem substitui ensaios de aparelho, tela bloqueada/boot, launcher
  e revisão de publicação. A release ainda requer assinatura de produção pelo
  responsável; a configuração atual aponta para a chave debug.

- Complemento visual autorizado em 14/11/2026: paleta acolhedora proposta pelo
  MONSTRUX, aplicada ao tema, progresso, marca, ícones e widget nativo. A regra
  anterior de paleta neutra foi substituída por esta decisão do responsável.


## Evolução funcional — lembretes e blocos (14/11/2026)

Schema 3 acrescenta kind com default timeBlock nas duas tabelas e
acknowledgedAtUtc opcional em ocorrências; preserva IDs, vínculos, duração,
recorrência, progresso e histórico. Migrações de schemas 1 e 2 foram testadas.
Geração/edição não sobrescrevem ocorrências já concluídas de mesmo ID; histórico
de realização permanece distinto do evento alarmSilenced.

Biblioteca alarm 5.12.0 copiada do cache para third_party/alarm, com licença MIT,
hashes originais e patch de completion documentado. Somente o Kotlin de
AlarmService foi modificado no pacote; a resolução offline mudou só essa origem.
Cache compartilhado e repositório fitness não foram modificados. A aplicação
sobrescreve AlarmReceiver para exported=false, mantendo PendingIntents internos.
Ver ensaio nativo e limites no relatório específico; ADB shell não é teste de
um app terceiro sem privilégios.

Sem promessa de duração fixa do som: uma execução depende do arquivo/Android.
Native stop/fim natural não são prova de ciência humana nem conclusão.
Recorrência semanal ainda não tem startDate separado; a escolha de dias passa
a estar disponível, sem inventar essa outra função. Ensaios em aparelhos reais,
tela bloqueada, boot/force-stop, launcher/TalkBack e assinatura release continuam
pendentes antes da loja. Nenhum merge, upload ou serviço pago foi executado.
