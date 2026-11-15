# Contratos de componentes e experiência em execução

Consulte quando uma recomendação afetar componente compartilhado, janela,
controle de sessão ou apresentação de dados. São técnicas adaptadas de código
open source, não falhas constatadas no Monstro nem garantia de usabilidade.
Não crie uma ficha extensa para uma correção local simples.

## Quem garante cada parte

Para componentes alterados, separe garantia do widget, dever da tela consumidora
e teste da composição. Exemplo de diálogo: o componente pode fornecer barreira e
ordem de foco; a tela fornece título traduzido, dados e decisão de descarte.
Confira no código quem realmente garante essas partes. Um label correto no
componente não prova o nome do diálogo composto nem o retorno do foco.

Use um contrato curto com objetivo, entradas/saídas, estados, responsabilidades,
invariantes e oráculos. Em controles, verificar papel, nome, valor, enabled,
selected e ações disponíveis na árvore semântica. Aparência desabilitada e ação
semântica ativa podem divergir. Teste o padrão e as opções semânticas suportadas.

Origem: [contrato modular do Primer](https://github.com/primer/react/blob/190fafd94a5008b5b18a1dfc5fdb85a74a9faabc/.agent/skills/modular-ds-accessibility-contract/SKILL.md)
(MIT). Adaptação original ao Flutter; não instalar a arquitetura React ou copiar
ARIA como se fosse Semantics.

## Composição e ordem dos eventos

Ao afetar um overlay, exercite a composição realmente usada: tela → bottom sheet
→ menu/seletor/diálogo → teclado. Para Voltar, Escape e toque externo, confira
qual camada fecha, qual permanece, onde fica o foco e quais dados se preservam.
Não deduza contrato Android a partir do Escape no navegador.

Origem: [testes de modais compostos do Carbon](https://github.com/carbon-design-system/carbon/blob/a16813e1cdafe954597768566762e5310884c5eb/packages/react/src/components/ComposedModal/ComposedModal-test.js#L733-L878)
(Apache-2.0). O benefício é verificar a sequência e o resultado; não importar
seus eventos DOM ou alterar a navegação atual sem autorização.

## Sessão em movimento

Em transições relevantes, registre estado real, mensagem, ação permitida e
evidência de persistência. Se o layout mudar execução → pausa → descanso,
compare a geometria das ações sob o dedo e a leitura com números longos.
Movimento intencional pode ser correto; deslocamento não é defeito por definição.

Verifique também evento × canal × estado: tela, notificação, som e vibração,
com app aberto ou em segundo plano. Ausência de aviso e duplicação de aviso
exigem teste; não assumir que notificação está permitida ou foi percebida.

Origem: [testes geométricos do timer do Flex](https://github.com/brandonp2412/Flex/blob/5f2de9e122703790a9dfe6d050a72412cf0279b0/test/timer_page_test.dart#L246-L319)
e [feedback por plataforma](https://github.com/brandonp2412/Flex/blob/5f2de9e122703790a9dfe6d050a72412cf0279b0/lib/timer/timer_page.dart#L124-L155)
(MIT). Não copiar dimensões, lógica do relógio ou suposições de permissão.

## Verdade dos dados apresentados

Distinga conectividade, durabilidade local e sincronização. “Salvo neste aparelho”
e “enviado” precisam de oráculos diferentes. Uma fila desconhecida não é zero.
Em métricas, confira ausência versus zero, origem manual versus GPS, atualização
recente versus antiga e sessão ativa versus sinal disponível. Nunca preencher
uma lacuna com um número para deixar o card bonito.

Origem: [estados e pendências no wger](https://github.com/wger-project/flutter/blob/5dd00d6cb774b4bce5ff2a6a71dba5dd57c034f8/lib/core/widgets/sync_status_dialog.dart)
e [seus testes](https://github.com/wger-project/flutter/blob/5dd00d6cb774b4bce5ff2a6a71dba5dd57c034f8/test/core/widgets/sync_status_dialog_test.dart)
(AGPL-3.0-ou-posterior; exceção de lojas descrita upstream),
[origem/ausência de registros no Loop](https://github.com/iSoron/uhabits/blob/82c1ff287a8ac05321bfa95b61399fa8a2d1da5b/uhabits-core/src/commonMain/kotlin/org/isoron/uhabits/core/models/Entry.kt#L39-L65)
(GPL-3.0-ou-posterior). Usar os princípios; não foi copiado código, modelo,
dependência de sincronização ou regra de negócio desses projetos.

## Promover um padrão com contexto

Antes de tornar uma solução local regra global, confira se já existe um padrão,
se o problema se repete, quais consumidores existem e onde a solução foi testada.
Registre contexto comprovado e limitações; comece como experimento local quando
a evidência ainda for restrita. Uma aprovação em Cardio não cobre todos os treinos.
Não transformar gosto pessoal em regra nem exigir pesquisa fictícia para avançar.

Origem: [critérios de contribuição GOV.UK](https://github.com/alphagov/govuk-design-system/blob/83ef3622ff74d47170d642ea7811e4ea4a440ef9/src/community/contribution-criteria/index.md#L12-L95)
(MIT). Aproveitar o gate de utilidade, diferença e contexto, preservando a
identidade e o fluxo de aprovação do Projeto Monstro.

## Investigar também as limitações da referência

O [OpenTracks no GitHub](https://github.com/OpenTracksApp/OpenTracks) está
arquivado e informa migração. Seu [encerramento por pressão prolongada](https://github.com/OpenTracksApp/OpenTracks/blob/3c23a9f5400c7b5b914a221469d76cc019a18296/src/main/java/de/dennisguse/opentracks/TrackRecordingActivity.java#L136-L149)
(Apache-2.0) inspira investigar toques acidentais; não justifica impor gesto oculto.
Mudanças de gesto, confirmação, recuperação e notificações são funcionais.

Cada repositório foi consultado em 24/10/2026 nos commits dos links. Licenças
apontam a condição declarada upstream, não autorização para copiar assets/código
sem seus requisitos. Referência implementada não prova eficácia com usuários.
