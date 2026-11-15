# Permissões e declarações do Play Console

Não enviar respostas automáticas como se fossem aprovação do Google.

## Alarmes exatos

O AAB declara USE_EXACT_ALARM. É uma permissão restrita, avaliada segundo a função
principal. O DayToDay apresenta organização de rotina com alarmes e calendário;
essa descrição não prova enquadramento como app dedicado de alarme/calendário.
Confirmar elegibilidade no Play Console antes da submissão. Se não se enquadrar,
será necessária uma mudança técnica de permissão/solicitação ou de agendamento;
o kit não altera o app silenciosamente para contornar a revisão.

Justificativa factual para adaptar: o usuário escolhe horários de atividades;
o sistema agenda avisos e o usuário pode parar, concluir, pular ou adiar. Não
inventar que a função principal é despertador se isso não representar o produto.

## Tela cheia e serviço em primeiro plano

USE_FULL_SCREEN_INTENT e FOREGROUND_SERVICE_MEDIA_PLAYBACK requerem as declarações
aplicáveis no Console. Explicar o aviso de alarme iniciado por um horário escolhido
e a reprodução visível para o usuário. O serviço encerra ao parar/finalizar o som;
isso não conclui a atividade. A concessão automática de tela cheia tem escopo
restrito; não prometer elegibilidade automática ou aprovação garantida.

Preparar demonstração real no aparelho/AAB de produção: criar aviso, conceder os
acessos necessários, aguardar disparo, mostrar a notificação/tela, parar e mostrar
que a atividade fica pendente. O arquivo ROTEIRO_VIDEO.md contém a sequência.
Se o Console exigir link de vídeo, o responsável deve gravar/publicar a demonstração
adequada e informar a URL. As capturas estáticas não substituem essa prova.

## Outros acessos

POST_NOTIFICATIONS: exibir avisos; RECEIVE_BOOT_COMPLETED: tratamento de retorno
após reinício; WAKE_LOCK/VIBRATE: execução do aviso; ACCESS_NOTIFICATION_POLICY:
integração com Não Perturbe quando autorizada. Manifest do app remove leitura de
armazenamento e SCHEDULE_EXACT_ALARM e fecha a exportação do AlarmReceiver.

Fontes: [Permissões](https://support.google.com/googleplay/android-developer/answer/16558241?hl=pt-BR)
e [serviços/tela cheia](https://support.google.com/googleplay/android-developer/answer/13392821?hl=pt-BR).
