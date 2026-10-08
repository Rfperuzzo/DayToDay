# Referência visual — DayToDay

Organizador de rotinas com uma identidade sóbria, acessível e acolhedora.
A direção neutra substitui a referência rosa Vibrant Momentum em 08/10/2026.

## Paleta

- Fundo off-white: `#F7F7F5`; cartões brancos: `#FFFFFF`.
- Superfícies suaves: `#F0F0ED`, `#E5E5E0` e `#E8EAE5`.
- Ações em grafite: `#343833`; destaque em cinza: `#5C625A`.
- Texto principal: `#242723`; secundário: `#646860`.
- Bordas: `#D8DBD3`.
- Vermelho apenas para erros e ações destrutivas, acompanhado de texto ou ícone.

Os tokens ficam em `lib/core/presentation/rotina_theme.dart`. O esquema Material
inclui superfícies, seletores e diálogos neutros. Calendário, progresso, cadastro,
subtarefas e respostas do alarme seguem essa paleta. O widget Android usa fundo
grafite e cartões claros, com os mesmos tons de texto.

## Identidade e componentes

- Nome público: **DayToDay**; textos sem personalização por pessoa.
- Ícone: calendário com check, sem fotos ou dependências de rede.
- Saudação: “Sua rotina, no seu ritmo.” e quantidade real de tarefas.
- Cartões arredondados, sombras discretas e conteúdo limitado a 800 px.
- Calendário contínuo, progresso, próxima atividade e lista de tarefas mantidos.
- Conclusão e bloqueio usam ícones e semântica acessível além da cor.
- Mensagens incentivam a organização sem pontuação competitiva.
- Alarme com gradiente grafite, texto branco e ações explícitas.

O aplicativo continua offline. Identificadores de armazenamento e integração
Android permanecem estáveis para preservar dados em atualizações compatíveis.
