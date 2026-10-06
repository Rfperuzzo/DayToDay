# Widget de tarefas do dia

O app fornece o widget Android **Tarefas de hoje**. Ele funciona somente com
dados locais e não exige conta, rede ou uma dependência Flutter adicional.

## Como adicionar no celular

1. Abra o aplicativo ao menos uma vez para preparar a agenda local.
2. Toque e segure um espaço vazio da tela inicial do Android.
3. Escolha **Widgets**.
4. Procure **Rotina da Jhenifer** e selecione **Tarefas de hoje**.
5. Arraste o widget para a tela inicial e ajuste seu tamanho se desejar.

## Comportamento

- mostra data, progresso e até quatro tarefas do dia;
- quando há mais tarefas, informa a quantidade restante e abre o painel;
- diferencia tarefas concluídas e bloqueadas;
- mostra horário, duração e importância;
- tocar em uma tarefa abre exatamente essa ocorrência no aplicativo;
- a primeira tarefa disponível oferece **Concluir tarefa** e **Editar**;
- tarefas ainda bloqueadas podem ser editadas, mas não concluídas antes da
  anterior;
- qualquer alteração observada no banco local atualiza o resumo nativo;
- o app mantém sete dias no cache do widget, permitindo a virada automática do
  dia mesmo quando o Flutter não estiver aberto naquele instante.

O Android solicita uma atualização periódica a cada 30 minutos, mas o horário
real pode variar conforme o fabricante e as políticas de bateria. Quando o app
está aberto, cadastro, edição, conclusão, cancelamento e reagendamento enviam o
novo resumo imediatamente.

## Implementação

- `DayWidgetBridge` observa sete dias de ocorrências no Drift e cria resumos
  sem acessar a rede.
- `AndroidDayWidgetGateway` envia JSON por `MethodChannel`.
- `RotinaDayWidgetProvider` usa `AppWidgetProvider` e `RemoteViews`, armazenando
  somente o resumo necessário em `SharedPreferences` privadas do aplicativo.
- `MainActivity` entrega o identificador da tarefa ao Flutter tanto em abertura
  fria quanto quando o aplicativo já está aberto.

Não existe ação destrutiva direta no widget: o toque sempre abre o app antes de
concluir ou editar, evitando confirmações acidentais na tela inicial.
