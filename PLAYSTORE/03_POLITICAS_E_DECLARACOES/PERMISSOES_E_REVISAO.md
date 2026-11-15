# Declarações de permissões — respostas para copiar

Versão 1.0.0+1. O pacote final usa SCHEDULE_EXACT_ALARM, concedida pelo usuário.
USE_EXACT_ALARM é removida do manifesto mesclado. Não submeter justificativa de
permissão restrita USE_EXACT_ALARM para este binário. Se o Console ainda a mostrar,
confira se enviou o AAB PRODUCAO e se não existe outra versão ativa com a permissão.

## Serviço em primeiro plano: mediaPlayback

Tipo: reprodução de mídia/áudio. Se a lista pedir um caso mais específico e não
listar alarme, escolher Outro e descrever fielmente abaixo.

**Funcionalidade:** O DayToDay permite que o usuário agende lembretes de atividades
para horários escolhidos. Ao disparar um alarme autorizado, um serviço em primeiro
plano reproduz o aviso sonoro e apresenta uma notificação com controle de parada.
A reprodução é breve e visível ao usuário; o serviço encerra quando o aviso termina
ou quando o usuário o interrompe. Parar o som não marca a atividade como concluída.

**Como o usuário inicia:** O usuário cria uma atividade, escolhe o horário e salva.
O disparo futuro decorre desse agendamento explícito e das permissões concedidas.
Não há reprodução publicitária, monitoramento ou trabalho oculto contínuo.

**Se o início for adiado:** O aviso poderá chegar depois do horário escolhido e
perder a utilidade como lembrete pontual para aquela atividade.

**Se for interrompido:** O usuário poderá não ouvir o aviso completo. A atividade
permanece na rotina e pode ser consultada/concluída manualmente.

**URL pública do vídeo para copiar:**
https://rfperuzzo.github.io/DayToDay/demonstracao-alarme.html

MP4 direto: https://rfperuzzo.github.io/DayToDay/demonstracao-alarme.mp4
Cópia local: 02_VISUAIS/DEMONSTRACAO-ALARME.mp4. Gravação real, sem áudio e sem edição;
veja ROTEIRO_VIDEO.md para limites e atalhos. Não colar caminho local no campo URL.

## Intent para tela cheia

Uso: apresentar um aviso de atividade no horário programado pelo usuário, quando
o acesso estiver autorizado no Android. Sem autorização, o funcionamento fica
limitado pelos acessos disponíveis. Não é um app de chamadas.

Não solicitar concessão automática sob alegação de app dedicado de despertador.
O produto é um organizador de rotinas com alarmes: selecionar Outro/sem concessão
automática, quando essa opção for apresentada, e explicar que o acesso especial
é solicitado explicitamente ao usuário. O Google decide a elegibilidade final;
não marcar chamadas nem inventar qualificação para aprovação automática.

Texto descritivo: A tela cheia é usada exclusivamente para alarmes de atividades
agendadas pelo usuário, com ações para parar o aviso e responder à atividade.
Não é usada para anúncios, promoções ou interrupções sem agendamento do usuário.

## Demais permissões

POST_NOTIFICATIONS: avisos; RECEIVE_BOOT_COMPLETED: reagendamento após reinício;
WAKE_LOCK/VIBRATE: execução do aviso; ACCESS_NOTIFICATION_POLICY: integração com
Não Perturbe mediante autorização. READ_EXTERNAL_STORAGE e USE_EXACT_ALARM removidas.
AlarmReceiver não exportado. Release sem INTERNET. O navegador externo abre a
política somente após toque do usuário; não recebe dados de rotina.

Fontes: https://support.google.com/googleplay/android-developer/answer/16558241?hl=pt-BR
https://support.google.com/googleplay/android-developer/answer/13392821?hl=pt-BR
https://developer.android.com/about/versions/14/changes/schedule-exact-alarms
