---
name: monstro-ux-actions
description: Propõe hierarquia, agrupamento e posicionamento de botões e ações no DayToDay, com justificativa por tarefa, estado, objeto afetado e adaptação Flutter. Use para harmonizar controles ou sugerir onde cada ação deve ficar; não é uma reformulação automática de navegação, funcionalidades ou identidade.
---

# Organização de ações do Monstro UX

O objetivo é produzir uma organização recomendada e implementável para as ações
da tela, não apenas dizer que os botões estão desalinhados. Leia DOCUMENTOS.md, o AGENTS.md se existir,
o perfil `.cursor/agents/monstro-ux.md` e os componentes/tokens atuais. Preserve
a identidade neutra, os tokens, PT-BR, funções, dados e autorizações da tarefa.

## Entender a ação antes de escolher o lugar

Confirme versão, tela, tarefa e estados. Observe a interface quando disponível e
confira callbacks, destinos e guards no código. Com código/descrição apenas,
entregue proposta preliminar e indique o que precisa de validação visual; não
invente overflow, preferência de usuários ou áreas de alcance medidas.

Mapeie ações distintas por contexto, não somente por texto do botão:

- Identificador, rótulo e objeto afetado: atividade, ocorrência, subtarefa,
  alarme, rotina inteira ou navegação. Dois Compartilhar podem ter contratos diferentes.
- Resultado/destino, pré-requisitos, disponibilidade e feedback em cada estado.
- Local atual, relação com conteúdo e comandos vizinhos, duplicatas e origem.
- Importância para a tarefa, risco/reversibilidade e frequência conhecida ou
  hipotética. Sem dados, não classificar uma função como rara por conveniência.

Confira estados relevantes: vazio/conteúdo, selecionado, ativo/pausado, ocupado,
erro, indisponível, teclado aberto e textos longos. Preserve ações condicionais;
uma ação não aplicável no estado atual não precisa aparecer só por simetria.

## Separar decisões que costumam ser confundidas

1. **Papel:** ação, navegação, escolha equivalente, toggle ou encerramento.
2. **Alcance:** objeto local, grupo/seleção ou tela/sessão inteira.
3. **Ênfase:** o que precisa se destacar naquela decisão, não no produto inteiro.
4. **Consequência:** risco e reversibilidade, independentes da ênfase visual.
5. **Disponibilidade:** quando precisa estar à vista e alcançável.

Prefira foco visual claro por região de decisão, sem impor um primário por tela
como lei. Manual e IA podem ser escolhas equivalentes; não promover IA por moda.
Uma confirmação de exclusão pode ter ação destrutiva proeminente, sem tornar
todo botão destrutivo primário nem escondê-lo sempre como terciário.
Em sessão ativa, avaliar pausa/retomada separadamente de salvar e descartar.

## Recomendar posição e agrupamento

Leia [as decisões de posicionamento](references/placement-decisions.md) quando
escolher entre conteúdo, rodapé, app bar, toolbar, FAB e menu. Avalie proximidade
com o objeto, sequência da tarefa, descoberta, visibilidade durante uso, risco
de toque acidental e espaço real. Não existe regra universal esquerda/direita,
topo/baixo ou região do polegar válida para todos os dispositivos e pessoas.

Compare a composição no estado atual e nas transições. Mantenha anatomia,
alinhamento, espaçamentos e estados coerentes entre controles do mesmo papel;
não tornar funções diferentes indistinguíveis. Prefira tokens e componentes
existentes. Não criar paleta, raios, tamanhos ou fontes paralelos por gosto.

Escolha uma organização recomendada. Mostre alternativa quando houver trade-off
real, explicando em qual condição ela seria preferível. Se a evidência não decidir,
indique o teste que diferencia as opções, sem inventar uma pontuação ou vencedor.

## Entregar sugestões por ação

Apresente primeiro a mudança de organização com maior efeito esperado na tarefa.
Para cada ação/grupo afetado, entregue:

- Onde fica hoje e onde deve ficar: ancoragem semântica, por exemplo após o
  resumo ou junto à série; evite coordenadas absolutas sem layout real.
- Papel, destaque, agrupamento e visibilidade por estado.
- Motivo ligado à tarefa e ao objeto, efeito esperado e evidência/hipótese.
- Invariantes, custo de descoberta/rolagem e eventual alternativa relevante.
- Critério de aceitação e classificação visual/funcional da proposta.

Não omita ações só porque não foram priorizadas: registre mantida, reorganizada
ou pendente com motivo. Em revisão ampla, use o artefato visual previsto pela
skill canvas, com capturas reais ou wireframes explicitamente identificados.
Uma sugestão de arranjo não é uma alteração já realizada no app.

## Fronteira de implementação

Mover ou alinhar controles na mesma superfície pode estar dentro de uma autorização
visual quando preserva ação, conteúdo, estados e disponibilidade. Reorganizar
em menu, esconder opção, acrescentar etapa, mudar foco/navegação intencionalmente,
impor gesto, trocar defaults ou alterar confirmação/salvamento muda interação.
Relate esses efeitos e aguarde autorização específica quando fora do escopo.
Não pedir novamente autorização já dada para o mesmo grupo de ajustes visuais.

Para exemplos de contratos reais do projeto e ensaios de decisão, consulte
[os casos do Monstro](references/monstro-cases.md). São referências de código,
não diagnósticos visuais ou resultados de teste do aplicativo.

## Verificar a proposta quando a implementação for autorizada

- 320/360dp e larguras maiores pertinentes; fonte ampliada e PT-BR. Permitir
  composição/empilhamento sem reduzir texto nem impor altura que recorte rótulos.
- Ordem visual, foco e leitura após reflow; região real de toque e separação
  entre ações. Ícone menor não autoriza hit region menor ou sobreposta.
- Teclado, safe areas, rolagem final, mapa, snackbar e overlays. Um CTA fixo não
  pode encobrir o campo focado, a última linha ou comandos essenciais.
- Tocar o alvo correto, feedback/ocupado, cancelamento e destino. Verificar
  transições para que outro comando não ocupe inesperadamente o próximo toque.
- Carga e contraste nos temas atuais, estados enabled/disabled/selecionado;
  rótulo visível e semântica coerentes. Não depender só de cor, hover ou tooltip.

Selecione testes existentes e acrescente assertivas relevantes ao risco. Use
`monstro-ux-audit` para cobertura/evidências da jornada; `material-theming` e
`flutter-build-responsive-layout` para implementação, `ux-copy` para linguagem
e `accessibility` para auditoria formal com seu escopo definido. Nenhuma dessas
referências exige carregar todo o pacote ou modificar o produto durante preparação.

Avalie esta skill por propostas e justificativas em casos reais/sintéticos, não
por repetir seus termos. Mantenha incertezas explícitas e ajuste o método com
evidência nova; não declare o agente completo ou sem mais nada a aprender.
