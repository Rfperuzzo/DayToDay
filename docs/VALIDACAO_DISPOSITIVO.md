# Validação em aparelho Android

Data: 29/08/2026  
Aparelho: Motorola edge 60 fusion  
Sistema: Android 16, API 36  
Aplicativo: build debug anterior à troca completa de identidade

> A identidade `com.senhoritaandriele.rotina` deve repetir esta validação em
> aparelho físico quando o próximo APK for autorizado e gerado.

## Resultado

O ciclo principal do alarme foi aprovado em aparelho físico. O app agenda um
`RTC_WAKEUP` exato, acorda a tela bloqueada, apresenta a interface em tela cheia
e mantém o toque ativo até uma resposta explícita.

Também foi aprovado o cold start: depois de enviar o app ao fundo e encerrar o
processo com `am kill`, o PID ficou ausente. No horário marcado, o Android
recriou o processo com um novo PID, acordou a tela e abriu **ALARME TOCANDO**.

## Matriz executada

- Cadastro único: salva atividade, ocorrência e alarme nativo.
- Permissões completas: notificações, alarme exato, tela cheia e acesso aos
  modos do Android.
- Tela bloqueada: o aparelho muda de `Asleep` para `Awake` no disparo.
- Tela cheia: as opções **Concluir**, **Agora não — reorganizar** e
  **Pular somente hoje** ficam disponíveis sem desbloquear o aparelho.
- **Agora não**: encerra o toque, move a ocorrência para o próximo múltiplo de
  cinco minutos e registra imediatamente um novo `RTC_WAKEUP`.
- Mesmo alarme reagendado: reaparece sozinho no segundo disparo, sem hot restart
  e sem confundir a tela de resultado anterior.
- **Pular somente hoje**: encerra o toque e não deixa outro alarme para a
  ocorrência única.
- **Concluir**: encerra o toque, persiste a conclusão e remove o agendamento.
- Persistência: depois de reiniciar o processo, o painel preservou a tarefa
  concluída e mostrou progresso de 50% no conjunto de teste.
- Fuso horário: os horários persistidos em UTC aparecem como 16:05, 16:21 e
  16:25 no fuso local, sem o deslocamento incorreto para 19:xx.
- Semana: os sete dias, de segunda a domingo, aparecem inteiros no aparelho.
- Não Perturbe: com o Android em modo prioridade (`zen_mode=1`), a tela cheia
  abriu, `STREAM_ALARM` permaneceu sem mute, roteado ao alto-falante e em 7/7,
  com atributos `USAGE_ALARM`. O modo foi restaurado para `zen_mode=0` após o
  teste.

## Defeitos encontrados e corrigidos

1. O `permission_handler` procurava `SCHEDULE_EXACT_ALARM`, mas o app usa
   `USE_EXACT_ALARM`; a capacidade agora é consultada diretamente no
   `AlarmManager.canScheduleExactAlarms()` (`51a5654`).
2. Um horário podia expirar durante o onboarding de permissões e salvar uma
   atividade sem ocorrência; há nova validação após o retorno (`8c77264`).
3. Telas de apresentação usavam `DateTime.toLocal()` em vez do serviço IANA e
   exibiam UTC como horário local; agora usam o fuso configurado (`316ebc4`).
4. Um reagendamento reutiliza a mesma ocorrência, e o roteador ignorava o novo
   toque quando a tela de resultado ainda estava ativa; o novo disparo agora
   assume a tela imediatamente (`acd1046`).
5. O sábado selecionado ficava cortado na faixa semanal; os sete dias agora se
   distribuem pela largura disponível (`9e70ecf`).

## Evidências automatizadas

- `flutter test --no-pub`: 23 testes aprovados.
- `flutter analyze --no-pub`: nenhum problema encontrado.
- APK debug recompilado e reinstalado no aparelho após as correções nativas.
- `dumpsys alarm`: agendamentos exatos com
  `exactAllowReason=policy_permission`.
- `dumpsys audio`: `STREAM_ALARM` sem mute e no volume máximo durante o teste
  com Não Perturbe.

## Limites desta rodada

- A automação confirma serviço de áudio, rota, uso e volume, mas não mede
  pressão sonora nem intensidade física da vibração.
- O comportamento foi comprovado neste Motorola. Fabricantes com políticas de
  bateria diferentes ainda merecem uma futura matriz de aparelhos.
- O teste usou build debug. A assinatura e o comportamento do APK release devem
  ser validados antes de distribuição externa.
