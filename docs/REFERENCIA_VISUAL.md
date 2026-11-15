# Referência visual — DayToDay

Organizador de rotinas com uma identidade sóbria, acessível e acolhedora.
A direção neutra adotada em 08/10/2026 foi ampliada em 14/11/2026, a pedido
do responsável: verde-petróleo, superfícies claras e acentos pêssego/terracota.

## Paleta

- Fundo off-white: `#F6F8F5`; cartões brancos: `#FFFFFF`.
- Superfícies suaves: `#EEF5F1`, `#DCECE4` e `#DCEFE6`.
- Ações em verde-petróleo: `#145A52`; variação de verde: `#176B64`.
- Texto principal: `#172F2B`; secundário: `#4F6862`.
- Bordas: `#CADBD3`.
- Acentos de apoio: terracota `#A74F32` e pêssego `#FFE7D6`.
- Vermelho apenas para erros e ações destrutivas, acompanhado de texto ou ícone.

Os tokens ficam em `lib/core/presentation/rotina_theme.dart`. O esquema Material
inclui superfícies, seletores e diálogos coerentes com os papéis de cor. Calendário, progresso, cadastro,
subtarefas e respostas do alarme seguem essa paleta. O widget Android usa fundo
verde-petróleo e cartões claros, com os mesmos tons de texto.

## Identidade e componentes

- Nome público: **DayToDay**; textos sem personalização por pessoa.
- Ícone: calendário com check, sem fotos ou dependências de rede.
- Saudação: “Sua rotina, no seu ritmo.” e quantidade real de tarefas.
- Cartões arredondados, sombras discretas e conteúdo limitado a 800 px.
- Calendário contínuo, progresso, próxima atividade e lista de tarefas mantidos.
- Conclusão e bloqueio usam ícones e semântica acessível além da cor.
- Mensagens incentivam a organização sem pontuação competitiva.
- Alarme com gradiente verde-petróleo, texto branco e ações explícitas.

O aplicativo continua offline. Identificadores de armazenamento e integração
Android permanecem estáveis para preservar dados em atualizações compatíveis.


## Hierarquia refinada em 14/11/2026

Cabeçalho compacto sem avatar de conta inexistente. Data/calendário preservados,
próxima atividade antes do progresso compacto, lista com estado e horário, ação
inferior Nova atividade rotulada. Componentes deixam o texto ampliar e rolar;
recorrência usa opções que quebram linha. A rodada inicial manteve a paleta neutra;
a autorização cromática seguinte está registrada abaixo e a substitui.


## Cor e acolhimento — 14/11/2026

Proposta do MONSTRUX autorizada pelo responsável: ações e seleção em
verde-petróleo, verdes claros no calendário/formulários, progresso e marca com
pêssego/terracota. O calor aparece em superfícies de apoio, além da troca do
antigo cinza. O ícone mantém o calendário com check e foi regenerado no novo
primário por script local, sem assets externos ou geração paga.

Tokens em RotinaColors/ColorScheme; XML do widget e fundos adaptativos recebem
os equivalentes, pois não herdam ThemeData. Testes conferem contraste dos pares
de texto e correspondência das superfícies nativas. Vermelho continua exclusivo
de falhas/destruição. Isso não equivale a certificação de acessibilidade.


## Lembretes e reserva opcional — 14/11/2026

O formulário começa com Reservar tempo desligado, exemplo Beber água e ajuda
explícita. Duração aparece somente no bloco. Dias específicos usa chips que
quebram linha, mantendo pelo menos um dia. A lista distingue Lembrete de minutos
reservados e mostra ciência pendente sem tratar como concluída. Só pendentes não
altera o progresso. No alarme, Parar é a ação primária e Concluir é separada.
Evidências desta rodada: ux/20261114-reminders/README.md.
