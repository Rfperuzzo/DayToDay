# Decisões de posicionamento e harmonia

Leia para escolher posição e tratamento de ações. São orientações contextuais
adaptadas ao Monstro, não um algoritmo que encontra a melhor coordenada.
Fontes primárias consultadas em 24/10/2026 estão abaixo.

## Conteúdo e grupos

Mantenha a ação local próxima do objeto afetado quando isso facilita entender
o resultado: adicionar item junto da seção, editar junto do registro. Em listas
repetidas, deixe claro qual item será afetado e conserve a mesma anatomia.
Uma ação global separada pode ser correta; não colar todo comando ao conteúdo
se isso o torna difícil de encontrar ou cria duplicação ambígua.

Agrupe por relação e separe decisões diferentes com espaço, alinhamento e, quando
necessário, região comum/título. Não exigir um card ou divisor para cada botão.
Peso visual coerente vem de tipografia, superfície, tamanho funcional e ritmo;
dar a todos a mesma cor não produz hierarquia. Controles do mesmo papel devem
ter família reconhecível sem impor o mesmo raio a todos os componentes do app.

## Depois do conteúdo ou persistente

Um CTA após o conteúdo favorece sequência de leitura e revisão. Um rodapé
persistente favorece disponibilidade durante rolagem/execução, mas consome espaço
e pode afastar o comando de seu contexto. Escolha pela tarefa e confira viewport
útil, teclado, safe area, navegação inferior e último conteúdo rolável.

Não tornar rodapé fixo por padrão. Se um formulário já esconde o CTA com teclado,
mantê-lo sempre visível altera disponibilidade e merece classificação explícita,
além de teste. Um rodapé com padding arbitrário não demonstra ausência de sobreposição.

## App bar, toolbar, FAB ou menu

- App bar: comandos de alcance de tela e utilidades, respeitando navegação/voltar.
  Evite promover um comando frequente de execução para um alvo distante sem teste.
- Toolbar: conjunto contextual, por exemplo uma seleção. Verifique mudança de
  contexto, informação da seleção e retorno ao estado normal.
- FAB: candidato a uma ação principal clara e recorrente, quando compatível com
  a tela. Não substituir Salvar, Pausar ou vários comandos por um FAB só por estética.
- Menu: candidato para ações secundárias cuja menor descoberta seja aceitável.
  Frequência desconhecida não demonstra que a ação é rara. Menu acrescenta passo
  e pode alterar interação; não esconder ação essencial para aliviar a composição.

Ícones precisam de sentido, label acessível e descoberta; tooltip/hover não
substituem rótulo em uma opção pouco conhecida no toque.

## Escolha equivalente, ação principal e risco

Em decisões equivalentes, preserve tratamento equilibrado e descrição suficiente
para escolher. Não dar ênfase a IA sem razão de produto comprovada. Uma tela pode
conter várias regiões legítimas; explique a hierarquia dentro do contexto ativo.

Separe Pausar, Concluir, Descartar e Sair pelas consequências reais. Não ordenar
só pelo nome ou usar vermelho como único significado. Comandos destrutivos não
são sempre de baixa importância: na confirmação final, a ação destrutiva pode
ser a decisão principal. Cancelar/continuar editando deve ser legível e alcançável.
Confirmação nova, undo, long press ou mudança de destino exigem escopo funcional.

## Adaptação e previsibilidade

Empilhar ou permitir wrap pode resolver rótulos longos; conserve relações, ordem
e áreas de toque. Em Flutter, `OverflowBar` usa regras diferentes para a sequência
horizontal e vertical: confira `textDirection`, `alignment`, `overflowAlignment`
e `overflowDirection` no SDK real. Não pressupor que virar coluna preserva ordem.
Não inverter esquerda/direita por regra web quando a plataforma usa outra convenção.

Durante iniciar/pausar/retomar e loading, preserve previsibilidade espacial das
ações sempre que pertinente. Se a composição muda legitimamente, avalie se um
toque repetido pode atingir outro comando. Não manter um controle habilitado
durante busy apenas para evitar mudança de aparência.

Alcance com uma mão depende de dispositivo, pegada, mão e movimento. Não tratar
mapa genérico de polegar ou Fitts como prova de preferência, distância medida ou
ganho percentual. Teste observável pode comparar localização do comando, erros
de acionamento e necessidade de reposicionar a mão, com participantes reais
quando a decisão depender de ergonomia. Sem esse teste, a vantagem é hipótese.

## Fontes e limites

- [Carbon — Button](https://www.carbondesignsystem.com/building-blocks/core/components/button/guidelines):
  hierarquia, agrupamento e alinhamento conforme a superfície. Suas convenções
  diferem entre página, wizard e diálogo; não importar CSS, alinhamento de label,
  nomes de variantes ou ordem como lei para o Monstro.
- [Fluent 2 — Button](https://fluent2.microsoft.design/components/web/react/core/button/usage):
  destaque relativo, escolhas equivalentes e rótulo que antecipa o resultado.
  Não importar a convenção de posição ou pressuposto de autosave do produto.
- [GOV.UK — Button](https://design-system.service.gov.uk/components/button/):
  agrupamento e warning proporcional à consequência. Não converter sua convenção
  de formulário à esquerda em uma regra global de aplicativo.
- [Material Android — toolbars](https://github.com/material-components/material-components-android/blob/66b0eeb53afeb6025ffbbd37734b08e5bce197ed/docs/components/DockedFloatingToolbars.md)
  (Apache-2.0): diferencia disponibilidade estável e ações contextuais.
  Não trocar widgets Flutter por Compose/Android Views ou adotar Expressive por efeito colateral.
- [Flutter — OverflowBar](https://github.com/flutter/flutter/blob/2541e508405f5d9728286d6ed3307163a5406e08/packages/flutter/lib/src/widgets/overflow_bar.dart)
  (BSD-3-Clause): comportamento verificável do reflow; conferir SDK do projeto.
- [WCAG — alvo mínimo](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)
  e [foco não encoberto](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html):
  tamanho/spacing e risco de barras fixas. 24 CSS px com exceções é critério web,
  não tamanho recomendado de botão Android. Não confundir AA, AAA e metas nativas.

Skills open source examinadas e aproveitadas como referências conceituais:

- [Dembrandt — Gestalt](https://github.com/dembrandt/dembrandt-skills/blob/c4ad177dea5b864f779f8c722f28cf04f760cb22/skills/gestalt-ui-organisation/SKILL.md),
  [família de componentes](https://github.com/dembrandt/dembrandt-skills/blob/c4ad177dea5b864f779f8c722f28cf04f760cb22/skills/component-family-consistency/SKILL.md)
  e [elementos persistentes](https://github.com/dembrandt/dembrandt-skills/blob/c4ad177dea5b864f779f8c722f28cf04f760cb22/skills/sticky-and-fixed-elements/SKILL.md)
  (MIT): agrupamento, anatomia e custo do espaço persistente. Não copiar absolutos
  LTR, fórmulas de raios, quantidade fixa de controles ou toolbar sempre sem texto.
- [Mobile Design](https://github.com/RubenGlez/mobile-design/blob/97474ed9b969d0c7f8a2acf712e30eeb0b9078d1/SKILL.md)
  (MIT): contexto móvel e decisão por estado. Não importar stack Expo/React Native,
  dials de estilo ou receitas de implementação para o Flutter existente.

Nenhum código, asset, launcher, CLI ou integração desses pacotes foi instalado.
O método é texto original específico do projeto; as referências não demonstram
eficácia da proposta com usuários do Monstro.
