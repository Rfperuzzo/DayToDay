# Referência visual — Vibrant Momentum

Este documento preserva o contexto visual recebido para o projeto **Rotina da
Jhenifer**. Ele descreve uma referência de produto, não código a ser executado
nem uma dependência do aplicativo.

## Origem

O arquivo `stitch_rotina_da_jhenifer.zip`, recebido em 29/08/2026, contém:

- `screen.png`: composição mobile do painel diário;
- `DESIGN.md`: tokens e princípios do sistema visual;
- `code.html`: protótipo web estático usado apenas para interpretar componentes.

O HTML usa Tailwind, fontes remotas, Material Symbols e uma imagem externa.
Esses recursos não entram no app Flutter, que continua offline e sem chamadas
de rede. Ícones e tipografia usam recursos compilados no aplicativo.

## Direção adotada

- Ícone oficial: ilustração fornecida da Jhenifer, preservada em
  `assets/branding/` e exportada para ícones Android legados, redondos e
  adaptativos.
- Personalidade: produtividade calorosa, feminina e enérgica, sem infantilizar.
- Fundo principal: `#FFF8F7`.
- Rosa de ação: `#BA0034`; destaque: `#E51245`.
- Texto principal: `#321017`; texto secundário: `#6B5A60`.
- Superfícies suaves: `#FFF0F1`, `#FFE1E4` e `#F4DCE4`.
- Bordas discretas: `#E6BCBD`.
- Cartões com raios entre 20 e 28 px; botões e seletores em formato pílula.
- Profundidade por borda e sombra rosa difusa, sem sombras pesadas.
- Conteúdo central limitado a 800 px para manter leitura confortável em telas
  grandes.

Os tokens de código ficam em `lib/core/presentation/rotina_theme.dart`.

## Componentes já traduzidos para Flutter

- cabeçalho com identidade da Jhenifer, sem depender de foto externa;
- saudação e quantidade de tarefas do dia escolhido;
- calendário horizontal localizado em português, com sete cartões visíveis,
  continuidade entre meses e título do mês em foco;
- cartão de progresso com anel animado;
- cartão da próxima atividade;
- lista diária com anel circular de conclusão e feedback tátil;
- estado vazio acolhedor;
- botão flutuante de nova atividade;
- formulário em folha inferior com campos de alto contraste e alvos de toque
  amplos.
- menu de opções ao tocar na tarefa, com edição de nome, horário e repetição em
  folha inferior e ação de cancelamento visualmente destrutiva, protegida por
  confirmação.
- seletor de duração também disponível na edição da atividade;
- folha de subtarefas com inclusão rápida, progresso, conclusão, reabertura e
  remoção de etapas;
- estado bloqueado para tarefas posteriores, com cadeado e explicação de que a
  tarefa anterior precisa ser concluída primeiro.
- widget nativo da tela inicial com fundo rosa, cartões claros, data, progresso,
  horário, duração e importância de até quatro tarefas.

## Adaptações conscientes

- Os rótulos em inglês do protótipo foram substituídos por português.
- O painel nunca mostra tarefas fictícias: tudo vem do banco local.
- A conclusão tem semântica acessível, não apenas cor.
- O progresso não cria culpa: comunica ritmo, dia livre ou conclusão.
- O cadastro explica os limites de permissões do Android e preserva os dados
  mesmo quando o alarme opera de forma degradada.

## Próximas extensões visuais

Manter os mesmos tokens ao criar a tela do alarme, a agenda completa e as
configurações. A tela do alarme pode ser mais contrastante, mas deve continuar
oferecendo decisões claras: **Concluir**, **Agora não** e **Pular hoje**.
