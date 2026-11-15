# Oráculos e comparação visual

Leia ao preparar testes ou capturas de uma mudança autorizada. Um oráculo é o
resultado observável que permite julgar se a tarefa está correta. Escolha os
pertinentes; evite uma bateria universal sem relação com o risco da mudança.

## Uma screenshot tem alcance limitado

Defina o alvo sem ambiguidade. Existir na árvore, estar visível, aceitar toque e
ser anunciado são propriedades diferentes. Se há dois botões Compartilhar,
encontre o contexto correto; selecionar arbitrariamente o primeiro pode testar
outra função. Registre ação e resultado, não apenas quantidade de widgets.

Referência: [estratégia de testes do Primer](https://github.com/primer/react/blob/190fafd94a5008b5b18a1dfc5fdb85a74a9faabc/contributor-docs/testing.md#L65-L95)
e [limites de snapshots amplos](https://github.com/primer/react/blob/190fafd94a5008b5b18a1dfc5fdb85a74a9faabc/contributor-docs/adrs/adr-011-snapshot-tests.md#L38-L65)
(MIT). Não portar seletores DOM literalmente para Flutter.

## Contrato, imagem e semântica se complementam

Para uma ação: preparado → focado/pressionado → processando → resultado/erro →
recuperação. Confira a ação, exceções, destino e dados conforme o contrato
existente. Imagem sozinha não comprova resultado persistido ou recuperação.

O Alchemist contém [testes de interação](https://github.com/Betterment/alchemist/blob/a462226801e7d77dd0c71ab5293265a1c869e2a3/test/smoke_tests/interactions_smoke_test.dart)
e um [golden deliberado de ErrorWidget](https://github.com/Betterment/alchemist/blob/a462226801e7d77dd0c71ab5293265a1c869e2a3/test/smoke_tests/error_message_smoke_test.dart)
(MIT): correspondência de pixels pode preservar um estado indesejado. Isso não
é defeito upstream. Não instalar a biblioteca nem atualizar goldens apenas para
aceitar uma diferença.

Para controles afetados, os recursos nativos do `flutter_test` incluem
`ensureSemantics`, `getSemantics`, `matchesSemantics` e guidelines apropriadas
ao SDK instalado. Inspeção semântica não equivale a teste real de TalkBack.
Referências [matchers](https://github.com/flutter/flutter/blob/2541e508405f5d9728286d6ed3307163a5406e08/packages/flutter_test/lib/src/matchers.dart)
e [guidelines](https://github.com/flutter/flutter/blob/2541e508405f5d9728286d6ed3307163a5406e08/packages/flutter_test/lib/src/accessibility.dart)
(BSD-3-Clause). Conferir assinatura e disponibilidade no Flutter do projeto.

## Captura reproduzível e legível

Registre SDK/engine, SO, renderer, dimensões lógicas, DPR, idioma, escala de
texto, paleta/brilho, fonte carregada, fixture, relógio, animação e assets.
Espere uma condição observável e limitada; `pumpAndSettle` pode não terminar
com animação contínua/timer. Não esconder um erro esperando tempo arbitrário.

Um golden com fonte de teste/blocos pode avaliar estrutura, mas não legibilidade
da Roboto. Espere imagens e fontes quando forem parte do critério. Compare
antes/depois com condições equivalentes. Não mascarar botão/texto sob revisão.

Referência histórica: Gallery [carrega fontes](https://github.com/flutter-team-archive/gallery/blob/d12640d4b08ee6e706fd8c64a83fba0620c9aa8d/test_goldens/testing/font_loader.dart),
[prepara imagens](https://github.com/flutter-team-archive/gallery/blob/d12640d4b08ee6e706fd8c64a83fba0620c9aa8d/test_goldens/testing/precache_images.dart)
e [limpa estado de teste](https://github.com/flutter-team-archive/gallery/blob/d12640d4b08ee6e706fd8c64a83fba0620c9aa8d/test_goldens/testing/util.dart)
(BSD-3-Clause; projeto arquivado). Aproveitar a técnica sem portar APIs antigas.

## Recuperação tem mecanismos diferentes

Navegar para trás, alternar apps, restaurar árvore Flutter e reabrir dados após
recriar processo não provam a mesma coisa. Escolha o ensaio do contrato existente.
`restartAndRestore` só se aplica quando há restauração configurada; não autoriza
adicionar esse mecanismo. Para persistência, use DB/fixtures isolados e confira
valores ao reabrir. Nunca limpar o armazenamento normal para facilitar captura.

Referência: [testes de restauração do Gallery](https://github.com/flutter-team-archive/gallery/blob/d12640d4b08ee6e706fd8c64a83fba0620c9aa8d/test/restoration_test.dart)
e [contrato oficial de restartAndRestore](https://api.flutter.dev/flutter/flutter_test/WidgetTester/restartAndRestore.html).

## Referência visual exige crítica

O [botão compartilhado do Wonderous](https://github.com/gskinnerTeam/flutter-wonderous-app/blob/747b945a7e5239356bf2664261aa2f3b020b8898/lib/ui/common/controls/buttons.dart)
(MIT) mostra soluções de foco/semântica e também escolhas que pedem teste de
disabled, área mínima e texto ampliado. A [issue de clipping com zoom](https://github.com/gskinnerTeam/flutter-wonderous-app/issues/202)
é um relato upstream, não prova de defeito no Monstro. Avalie a implementação e
suas limitações, sem copiar estética, gestos ou wrappers automaticamente.

No Monstro já existem testes relevantes de navegação, conclusão cardio, limiar
de XP, paletas e escala. Reaproveite-os conforme o escopo; não apresentar essas
práticas como ausentes nem acrescentar testes redundantes só para somar números.

Fontes consultadas em 24/10/2026. Os textos acima são adaptações originais;
nenhum pacote, código de produto ou asset upstream foi incorporado.
