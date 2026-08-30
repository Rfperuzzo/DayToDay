# Calendário mensal contínuo

O painel diário mantém os mesmos cartões compactos da faixa semanal original,
mas permite navegar continuamente por todas as datas entre 2000 e 2100.

## Comportamento

- sete dias permanecem visíveis por vez;
- o gesto horizontal atravessa o fim do mês e a virada do ano;
- o título acompanha o mês localizado no centro da faixa;
- apenas tocar em uma data altera o dia selecionado e as tarefas exibidas;
- uma seleção externa, como a abertura de uma tarefa pelo widget, reposiciona a
  faixa para revelar a data correspondente;
- os cartões preservam cores, dimensões, abreviações e destaque da seleção.

## Tarefas futuras

Quando um mês futuro fica visível ou uma data dele é selecionada, o
`OccurrenceHorizonMaintainer` prepara suas ocorrências locais. A operação é
idempotente: não duplica tarefas nem sobrescreve conclusão, pulo, adiamento,
toque em andamento ou reagendamento.

Meses anteriores mostram somente ocorrências que realmente foram persistidas;
o calendário não fabrica histórico retroativo. A manutenção funciona sem rede,
não modifica o schema do banco e não amplia a janela de alarmes ativos além da
política configurada.

## Estado degradado

Se a preparação de um mês falhar, a navegação e as tarefas já persistidas
continuam disponíveis. Uma nova visita ao mês tenta novamente.
