# MONSTRUX — revisão de lembretes, blocos e recorrência

Data:14/11/2026. Estado: revisão de contratos, evidência nativa e capturas finais concluída para este PR. Aprovação limitada ao escopo e condições descritos no fechamento; seções anteriores preservam o histórico incremental. Este arquivo
complementa monstrux-review.md, preservado como histórico da revisão anterior.

## Escopo autorizado e método

O usuário pediu que duração deixasse de ser obrigatória para simples avisos e
autorizou implementação, testes, prints e PR; depois pediu comparação com apps
atuais e melhorias úteis. Revisor MONSTRUX leu os diffs e caminhos de domínio,
DB/schema3, geração/repositórios, edição/cadastro, conflitos, sequência,
reconciliação, resposta/roteador de alarme, recuperação/planner e widget. Também
revisou patch nativo local e harness sintético. Não editou código do app, cache
Pub ou fitness, não usou API paga e não adicionou agentes/provedores.

## Comparação oficial, consultada diretamente

[TickTick — funcionalidades](https://ticktick.com/features) documenta filtros,
lembretes e recorrência customizada; lembrete contínuo é uma opção específica.
Isso respalda expor controles úteis sem impor toque contínuo a todo cadastro.
Não é evidência de que toda funcionalidade citada seja gratuita ou deva ser
replicada no DayToDay.

[Structured — recorrência](https://help.structured.app/en/articles/338114)
documenta seleção dos dias da semana; informa que recorrência exige Pro.
[Structured — tipos e edição](https://help.structured.app/en/articles/338050)
distingue itens de timeline e inbox e descreve duração nos itens de timeline.
A referência reforça separar intenções, mas não prova que Structured implemente
o mesmo modelo de lembrete pontual aqui proposto.

Decisão MONSTRUX inferida dessas referências e dos contratos locais: oferecer
Dias específicos com o motor WeeklyRecurrence já existente e preservar máscara
customizada na edição; Só pendentes é filtro simples que não altera progresso.
Não incorporar integrações, IA, localização, serviços externos ou cópia de toda
a suíte dos concorrentes. Não há conta/assinatura nova para o DayToDay.

## Contratos revistos

- Novo cadastro padrão reminder: não ocupa agenda e não exibe duração falsa.
  Reservar tempo cria timeBlock com duração positiva. Reminder normaliza zero
  explicitamente; conflitos ignoram reminders tanto candidatos quanto existentes.
- Dados legados recebem timeBlock na migração aditiva schema2→3; IDs, duração,
  vínculos, recorrência e histórico permanecem. Kind acompanha snapshots e DB.
- Som, ciência e realização ficam separados. Parar alarme no app salva ciência
  idempotente sem completed; Concluir registra realização. Stop nativo ou fim
  natural de áudio não inventam acknowledgedAt nem incremento de progresso.
- Apenas blocos pendentes entram no bloqueio sequencial. Lembretes avisam e são
  concluíveis independentemente; os já silenciados continuam pendentes na lista
  e não monopolizam nextAction. Reconciler combina lembretes com primeiro bloco
  de cada dia, respeitando limites de agendamento.
- Timer antigo vinculado à duração foi retirado do Router. Execução única do
  som é nativa; prazo de reserva não significa prazo de toque nem conclusão.
- Dias específicos preservam seleção custom ao editar. UI impede remover último
  dia; filtro Só pendentes não remove dados nem muda denominador do progresso.

## Achados enviados e revalidados em código

1. Reconcile cancelava binding já iniciado ao filtrá-lo como passado. Agora
   consulta bindings existentes antes, conserva pendente com binding e não
   recria horário vencido. Critério: agir num reminder não cancela outro aviso
   ainda pendente tocando. Coberto no lote de contratos registrado.
2. Evento moved tardio podia apagar ciência e rearmar item. Processor agora
   cancela/acknowledge evento de ocorrência com ciência sem sobrescrevê-la;
   terminais continuam protegidos. Critério: ciência persiste após evento tardio.
3. Resultado de adiar reminder descrevia busca de espaço livre inexistente.
   Código agora usa Lembrete adiado e explica que outras atividades não mudam;
   linguagem de reorganização fica para blocos.
4. Plugin original loopAudiofalse terminava mídia sem limpar ringing/fila.
   Vendor local5.12.0 com MIT preservada corrige completion pelo caminho normal
   handleStopAlarmCommand→unsave→FlutterStopped→cleanup/fila. Diff dirigido e
   hashes listados conferidos: somente AlarmService.kt alterado nos originais.
   Post main-thread verifica instância, foregroundID, ringingID e data salva
   antes de agir. Manifest do app restringe receiver exportedfalse, sem nova
   permissão. Parecer específico ao app com overlapfalse, não biblioteca geral.

## Evidência final conferida

reminders-tests-final.log:97 testes aprovados; reminders-analyze-final.log:
No issues found. Lotes específicos registram16 contratos e5 widgets aprovados.
Execução foi do implementador; revisor verificou logs e código, sem afirmar que
rodou esses comandos de teste pessoalmente.

Li reminders-native-result.json, logcat e services. SHA256 do harness e APK
foram recalculados e coincidem com o JSON. IDs910001–910004 aparecem no stream;
phase1Remaining e remaining estão vazios; dumpsys final não lista serviço.
Logcat desta execução mostra910001 tocando,910002 na fila, completion910001,
promoção910002 e completion910002. Segundo par:910003 toca, stop manual observado,
910004 toca e termina; não há completion natural de910003. Há transição breve
no stream com ambos IDs, compatível com callbacks de estado; logs nativos
mostram promoção após término, não prova de áudio simultâneo.

Concordo com PASS do cenário sintético descrito. Background via HOME antes do
primeiro aviso é condição registrada pelo implementador/metadata; este revisor
não controlou o AVD nem observou o botão Home. Tom sintético1.2s, Android35,
primeiro par simultâneo e segundo com intervalo2s/stop manual próximo do fim.
Não se deve descrever os dois pares como simultâneos. Os resultados demonstram
fila/cleanup/stop nesses cenários, não todas as condições de corrida possíveis.

## Limites e próxima validação

Screenshots do novo comportamento ainda não foram examinados neste relatório;
aguardando cadastro reminder/bloco, dias específicos, lista mista/silenciado e
alarme com ações separadas. As capturas color do relatório antigo não comprovam
esta implementação funcional nova. Não há bloqueio estático remanescente
identificado nesta passagem, mas aprovação visual continua pendente.

Não atestados: aparelho físico/OEM, tela bloqueada, force-stop, processo morto,
reboot, todos os acessos Android/loja, TalkBack completo ou conformidade WCAG.
Fim natural pode voltar ao painel com item pendente sem ciência: comportamento
intencional, não realização comprovada. A regra antiga de data inicial da
recorrência não ganhou startDate novo; não anunciar essa função. Vendor exige
manutenção/rebase consciente em atualizações futuras. Nenhum resultado aqui
constitui aceite da loja ou pacote release assinado.

## Primeiro lote visual do novo comportamento

Inspeção direta por view_image em reminders/painel.png, lembrete.png e
reservar-tempo.png. Painel identifica Beber água como Lembrete, sem0min; card,
Concluir e Nova atividade legíveis. Cadastro padrão mostra Reservar tempo
na agenda desligado e explicação de lembrete sem duração. Com switch ligado,
duração é revelada, escolhas e botão salvar aparecem legíveis. Reservar-tempo
é captura rolada: header fora da foto não é evidência de conteúdo inacessível.
Não identifiquei outro bloqueio visual concreto neste lote360dp/1x.

Ajuste de texto confirmado: intro ainda exige quanto tempo reservar e placeholder
Ler por30min enviesam o padrão de lembrete. Concordei com proposta do
implementador de trocar para Escolha a atividade e o horário. Reserve tempo se
precisar e Ex.: Beber água. Aguardando recaptura após ajuste para encerrar esse
achado e os demais destinos (custom/lista/alarme/silenciado). Sem código editado
pelo revisor e sem aprovação visual antecipada das telas ainda não recebidas.

## Revalidação visual — lista, dias e resposta ao alarme

Abri diretamente reminders/dias-especificos.png, lista-silenciado.png,
so-pendentes.png, alarme-acoes.png, silenciado.png e reabri lembrete.png e
reservar-tempo.png. Dias específicos mostra Seg/Qua/Sex selecionados e controles
legíveis. Lista mostra Planejar concluída, Beber água como Lembrete/Aviso
silenciado · Pendente, Estudar disponível com30min e Pausa bloqueada como bloco.
Progresso continua1/4; Só pendentes oculta concluída e mantém1/4. Alarme separa
Parar alarme de Concluir, Adiar e Pular; confirmação de silêncio explica
expressamente que a atividade permanece pendente. Sem0min nas fotos examinadas.
Alarme-acoes é captura rolada: relógio parcialmente fora do viewport não foi
classificado como overflow. Nenhum bloqueio visual novo nesse lote360dp/1x.

Essas imagens são fixture em memória/gateway fake. A foto confirma apresentação
coerente do estado, mas não prova gravação real de acknowledgedAt: esse contrato
foi verificado em fonte/testes, e o ensaio sonoro nativo é evidência separada.
As fotos atuais de lembrete ainda trazem intro quanto tempo reservar e exemplo
Ler30min; reabri o arquivo e informei ao implementador que o ajuste de texto não
estava na imagem recebida. Achado continua aberto até recaptura correta.

Ação pós-silêncio: Concluir e Editar já permitem realizar/remarcar; não considero
a falta de atalho Adiar um bloqueio crítico. Aprovo complemento pequeno proposto
Lembrar em10min somente para reminder pendente, com ajuda Sem mudar suas outras
atividades e mesmo response.nowNot. Critérios: ciência resetada pelo adiamento,
horário futuro rearmado, progresso inalterado, sem cascata em blocos; busyguard e
erro claro em falha. Ainda não implementado/revalidado por este agente.

Precisão de segurança comunicada pelo implementador: manifest mesclado debug
confirma receiver exportedfalse e PendingIntents nativos funcionaram. O ensaio
adb shell broadcast não distinguiu entrega/negação, e seu assert esperando erro
falhou. Portanto não é PASS de bloqueio dinâmico a terceiros nem prova de
exposição. Não contabilizar reminders-receiver-security.log como aprovação de
segurança; a evidência existente de restrição é estática no manifest.

Parecer incremental: contratos corrigidos e lote visual recebido são coerentes;
resta fechar texto recapturado e qualquer atalho adicional antes de declarar o
estado final dessas últimas alterações. Permanecem limites físicos/Android/loja
registrados acima. Nenhum app/código alterado por este agente.

## Fechamento — aprovado para PR revisável

Inspecionei as recapturas finais reminders/lembrete.png, reservar-tempo.png,
opcoes-lembrete.png, lista-silenciado.png e so-pendentes.png. Form agora diz
Escolha a atividade e o horário. Reserve tempo se precisar e Ex.: Beber água:
achado de texto encerrado. Reserva é opcional e duração só aparece com switch
ligado. A imagem de reserva foi tirada em posição rolada; descrição inferior
parcial não representa conteúdo inacessível. Menu mostra Lembrar em10minutos e
explica que muda somente o aviso, sem mudar repetição. Lista mantém ciência
separada de conclusão,1/4 de progresso e ausência de0min; Só pendentes mantém o
progresso e oculta somente a concluída. Somam-se aos destinos alarme/silenciado/
dias específicos já inspecionados acima. Não identifiquei bloqueio visual
concreto remanescente nas capturas recebidas360dp/1x.

Revisei wiring de ActivityOption.postpone em TodayScreen: chama o mesmo
AlarmResponseService.respond(nowNot) para reminder; sucesso informa horário,
falha dá mensagem explícita e falha de sincronização pede rever acessos. Menu
encerra antes da gravação e não contém rascunho a preservar. Teste novo cobre
presença do atalho; teste de contrato cobre adiar10min sem deslocar blocos e
limpar ciência. Não descrevo esses dois testes como ensaio E2E de toque do menu.

Conferi logs atualizados: reminders-tests-final.log termina em98 testes
aprovados; reminders-analyze-final.log sem issues; preview final e entrypoint
principal registram assembleDebug bem-sucedido. Hash de AlarmService.kt continua
919854a016df62d6110e780341eeab05b54bdf3d86b920f0320352ea0356678f, igual ao patch
nativo previamente revisado/ensaiado. Os ajustes finais de texto/menu não foram
apresentados como mudança Kotlin nem como novo ensaio nativo.

Parecer final MONSTRUX: aprovo o escopo para abrir PR e revisão humana, mantendo
os limites documentados. Lembretes sem reserva, blocos explícitos, silêncio sem
conclusão, dias específicos e filtro pendente estão coerentes com a decisão de
produto e com as evidências examinadas. Os quatro achados de contrato/nativo e
o texto inicial foram corrigidos e revalidados nesta rodada.

A aprovação não atesta publicação em loja, release assinado, todos os estados
320dp/2x do novo formulário, TalkBack completo, segurança dinâmica de terceiros,
aparelhos físicos/OEM, tela bloqueada, force-stop, processo morto ou reboot.
UI é fixture; o teste nativo sintético em background é evidência separada, com
condições registradas. Não alegar que97/98testes substituem esses ensaios.
Relatório anterior preservado, nenhum código de app editado pelo revisor e
nenhum acesso ao repositório fitness ou API paga.

### Ressalva final de roteamento identificada na coordenação

Antes de fechar o PR, implementador apontou e este revisor confirmou o risco de
_pendingAlarm receber o mesmo ID que está sendo respondido e sobreviver a stream
vazio. Com callbacks transitórios [A,B]→[] isso pode reabrir aviso já encerrado.
Concordei como correção necessária, sem expansão de funcionalidades: durante
resposta derivar pending da última lista com ID diferente do ativo, ou null;
quando lista vazia limpar pending sempre. Testar responderA com[A] (não reabrirA),
[A,B] (promoverBuma vez),[B]→[] (não reabrirB) e erro de resposta com retry.
O parecer anterior de visual permanece; encerramento de código fica condicionado
à correção e teste dirigido dessa ressalva de roteamento. Não alterei app.

### Encerramento da ressalva de roteamento

Revisei o diff final de AlarmRouter e fonte completa de
alarm_router_queue_test.dart. Lista vazia agora limpa pending sempre; durante
resposta o pending vem da última lista, selecionando primeiro ID diferente do
ativo ou null. Teste com Drift em memória real e cancel aguardando gate cobre
both/same/empty/failure, incluindo preservação de A/erro em falha e promoção B
sem reabrir A. reminders-router-tests.log registra4 aprovados. Achado de stale
route encerrado, sem pendência de correção de código nesta revisão.

Logs atualizados reminders-tests-final.log e reminders-analyze-final.log foram
reabertos:102 testes aprovados e análise sem issues. Builds debug das últimas
fontes estavam em execução pelo implementador nesta checagem; aprovação deste
parecer não substitui ele confirmar os dois resultados finais antes do PR.
Os builds98 anteriormente registrados preservam seu valor histórico, sem serem
reclassificados como build posterior do Router.

Precisão do cenário de adiamento: conforme informado pelo implementador, AVDUTC
cruzou15/11 enquanto fixture permaneceu14/11; adiar10min leva item ao dia seguinte
e altera denominador do dia1/4→1/3, sem aumentar completed. Não é comportamento
do filtro Só pendentes, cuja preservação1/4 foi vista diretamente. A captura
adiado-lista não foi usada aqui para demonstrar denominador constante.

Parecer final desta revisão permanece aprovado para PR revisável, agora sem a
ressalva de roteamento; mantêm-se apenas limites de plataforma/evidência já
registrados e confirmação operacional dos builds finais pelo implementador.


## Fechamento operacional do implementador

102 testes aprovados; flutter analyze sem issues. APKs debug da fixture e de
lib/main.dart compilados com as últimas fontes. O APK principal foi instalado
no AVD e abriu o painel, sem menu de fixture. Logs conclusivos privados:
reminders-tests-final.log, reminders-analyze-final.log,
reminders-preview-build-final.log e reminders-production-build.log.
Logs intermediários com falhas de lint/captura são tentativas preservadas.

Migrações de schemas1/2 para3 preservam dados preenchidos, IDs, nativeAlarmId,
histórico, duração, subtarefas e preferências; antigos viram timeBlock.
Editar não sobrescreve conclusão futura de mesmo ID. Parar é idempotente e
separado de completar; adiar limpa ciência e não desloca blocos. Datas e
horários do teste são sintéticos; não houve leitura de dados pessoais.

Ensaio Android35 real do plugin, separado da fixture: primeiro par simultâneo,
segundo com intervalo2s e parada manual aos1.15s de áudio sintético1.2s. HOME
antes do primeiro disparo. Os quatroIDs apareceram; o primeiro par drenou FIFO,
o segundo confirmou stopmanual e completion seguinte; lista final vazia e sem
AlarmService restante. O emulador roda sem saída de áudio: verificamos MediaPlayer,
callbacks, fila e serviço, sem afirmar audição humana do som. Ver JSON com hashes.
Não generalizar para processo morto, tela bloqueada, boot ou fabricantes.

A origem de uma única dependência mudou, offline: alarm5.12.0 agora é a cópia
versionada em third_party/alarm.71 arquivos runtime/metadata têm hashes originais;
só AlarmService.kt foi alterado no código da dependência, mantendo MIT. O cache
compartilhado não foi modificado. Ajuste de completion libera fila via stop
normal; som não conclui tarefa. Manifest mesclado confirma AlarmReceiver
exported=false; ADBshell privilegiado não forneceu prova de bloqueio de outro app.

[Prints e método](ux/20261114-reminders/README.md). Dados do painel são quatro
atividades com uma concluída; captura pós-silêncio mantém1/4. Só pendentes
oculta uma linha sem mudar1/4. Durante o adiamento manual, o relógio UTC do AVD
cruzou o dia da fixture: o item foi para outro dia e o denominador da data
selecionada mudou para3, sem nova conclusão. Essa foto não é prova de filtro.
Telas de alarme/reserva roladas não representam overflow; testes320dp/2x cobrem
reflow e mínimo de um dia selecionado. Não há certificação WCAG/TalkBack.

Pesquisa em páginas oficiais de TickTick e Structured sustentou os recursos
Dias específicos e Só pendentes; não foi comprado plano ou copiada integração.
Nenhum serviço pago, crédito, provedor novo ou acesso ao repositório fitness.
Sem merge, workflow, publicação ou assinatura release de produção.
