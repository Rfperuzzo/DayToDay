# Avisos de início, final e troca — DayToDay 1.1.0+2

## Comportamento

Reservar tempo mostra início e horário final, opção de terminar no dia seguinte
e duração calculada. Avisar no início e Avisar no final são independentes.
Defaults: início ativado e final desativado. Ambos desligados salvam um bloco
silencioso, sem consultar/pedir permissões de alarme. Lembretes continuam simples.
Intervalos novos precisam ter início futuro e final posterior; não há registro
retroativo nesta alteração. Repetições mantêm a duração calculada no cadastro.

Quando um final habilitado coincide exatamente com um início habilitado de outro
bloco, um único aviso identifica a troca. Silenciar início preserva final;
silenciar a troca registra ciência das duas pontas, sem concluir atividades.
Final/troca não mostram botões ambíguos de concluir, adiar ou pular: a conclusão
continua disponível separadamente na rotina. Os blocos novos não ficam bloqueados
pela sequência legada. Concluir/cancelar antes do horário remove os avisos afetados
e reconcilia uma eventual troca com o próximo bloco.

## Preservação e compatibilidade

Schema4 somente adiciona notifyAtStart/notifyAtEnd/usesBoundaryAlarms às atividades
e ocorrências e endAcknowledgedAtUtc às ocorrências. Migrações1/2/3 preservam IDs,
horários, duração, status, ciência antiga, subtarefas, preferências e histórico.
Legado recebe inícioON/finalOFF e usesBoundaryAlarms=false: não começa a tocar
no fim nem muda a sequência sem edição explícita. Edição mantém durações antigas
exatas, inclusive47min e50h17min, até alteração deliberada do término.

IDs nativos de início preservados; finais recebem chave #end:occurrenceId. Fusão
usa identidade do próximo início e referencia a ocorrência anterior. Hashes são
estáveis, positivos e verificados contra colisão antes de agendar. Payload nativo
antigo continua sendo interpretado como início. O roteador distingue duas pontas
da mesma ocorrência por alarmKey. Falha/retry nativo em bloco explícito afeta o
aviso, sem deslocar/cancelar/concluir a atividade por conta própria.

## Validação

- 137 testes aprovados e flutter analyze sem problemas.
- Matriz início/finalON/OFF, fusão, pontas desligadas, ciência independente,
  conclusão antecipada, cancelamento/edição (inclusive resposta a troca já ativa),
  virada do dia, eventos nativos e idempotência cobertos em testes.
- Migrações1/2/3 e persistência dos novos campos cobertas com repositórios reais.
- Corrigida incompatibilidade do TimePicker do SDK em localeptBR com relógio12h:
  os3seletores usam24h; regressões de digitação13h/15h aprovadas.
- Ensaio nativo no AVD exclusivo DayToDayMonstrux35: início, troca combinada, final
  e somente final dispararam em segundo plano. GatewayAndroid e repositórios
  reais com banco isolado em memória; nenhuma atividade concluída automaticamente.
  tool/boundary_alarm_probe.dart é diagnóstico opt-in, não importado pelo app.
- AAB/APK de produção usam lib/main.dart e a mesma chave de upload já existente.
  Assinaturas, certificado, bundletool, manifesto e alinhamento estático16KB
  conferidos. Capturas e resultado da jornada visual constam em PLAYSTORE/06_VALIDACAO.

O ensaio usa Android15 com páginas4KB. Não equivale a execução16KB, áudio em
aparelho físico, todos os fabricantes, bloqueio/boot/force-stop ou aprovação Play.
Nenhum serviço pago, SDK de inferência ou repositório fitness foi usado.
A publicação e o merge deste PR ficam para revisão do responsável.
