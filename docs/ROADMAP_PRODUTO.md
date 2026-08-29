# Roadmap de produto e soluções inovadoras

O princípio central é simples: o app deve ajudar Jhenifer a retomar o dia, não
apenas avisar que um horário passou. Todo aprendizado permanece no aparelho.

## Entregue no MVP atual

- painel reativo do dia e navegação pela semana;
- progresso diário e próxima atividade em destaque;
- conclusão rápida com vibração curta;
- cadastro de atividade única, diária ou de segunda a sexta;
- duração e prioridade usadas pelo motor de rotina;
- rejeição de horários cuja duração invade uma tarefa já reservada, com sugestão
  do próximo horário livre;
- solicitação contextual dos acessos de alarme;
- tela de toque com **Concluir**, **Agora não** e **Pular hoje**;
- confirmação do novo horário após o Resgate de rotina;
- toque na tarefa com edição de nome, horário e repetição ou cancelamento
  confirmado;
- edição da duração da atividade;
- subtarefas persistentes relacionadas à tarefa principal, com conclusão,
  reabertura e remoção;
- fila diária: apenas a primeira tarefa pendente pode ser concluída e recebe
  alarme; concluir antecipadamente libera a próxima imediatamente;
- dados locais, sem conta, nuvem, anúncios ou telemetria.

## Próxima prioridade

### 1. Tela de alarme com decisão real — entregue

Substituir a ação genérica da notificação por uma tela bloqueada e legível com:

- **Concluir**: encerra e registra a realização;
- **Agora não**: encerra e inicia o Resgate de rotina;
- **Pular hoje**: encerra apenas a ocorrência atual.

O fluxo Flutter já fecha o ciclo entre o alarme e o motor. A validação final em
aparelho físico continua necessária para diferentes fabricantes Android.

### 2. Resgate de rotina explicável — primeira versão entregue

Depois de **Agora não**, a tela já mostra o novo horário e a quantidade de
atividades ajustadas. A próxima evolução é nomear qual compromisso importante
foi protegido para aumentar a confiança na decisão.

### 3. Radar de energia

Uma pergunta opcional de um toque — baixa, média ou alta energia — permite
sugerir tarefas compatíveis sem alterar compromissos fixos. A seleção não deve
ser obrigatória nem virar avaliação de desempenho.

### 4. Memória de duração local

Comparar duração estimada e real para sugerir ajustes: “Seus treinos costumam
durar 72 min; deseja atualizar de 60 para 75?”. Só aplicar após confirmação.

### 5. Barreira anti-caos — primeira versão entregue

Exibir buffers entre deslocamento, preparação e atividade; limitar cascatas de
reagendamento e proteger tarefas importantes. Quando o dia não comportar tudo,
o app deve dizer isso claramente em vez de criar sobreposições invisíveis.

A primeira versão já reserva toda a duração, recusa sobreposição, sugere o
próximo horário livre e mantém as tarefas do dia em sequência. A evolução
seguinte é permitir buffers configuráveis de preparação e deslocamento.

### 6. Pulso do dia sem culpa

Resumo matinal com três prioridades e fechamento noturno privado: concluído,
adiado e removido. Evitar sequências punitivas; celebrar retomadas e constância
flexível.

## Critérios para novas funcionalidades

Uma ideia só entra no produto quando:

1. resolve uma decisão real do dia de Jhenifer;
2. funciona offline;
3. não compromete a confiabilidade do alarme;
4. explica alterações automáticas;
5. tem estado degradado honesto quando o Android limita o comportamento;
6. recebe teste e atualização em `DOCUMENTOS.md` no mesmo commit.
