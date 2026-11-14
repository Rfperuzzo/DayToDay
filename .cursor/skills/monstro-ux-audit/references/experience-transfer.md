# Experiência transferida para o DayToDay

Importação autorizada em 14/11/2026. O perfil, as duas skills próprias e suas
referências vieram do Projeto Monstro. Os hashes de origem e de destino estão
em `.cursor/monstrux-origin.json`. O repositório de origem permanece intacto.

Esta experiência é conhecimento documentado: método, decisões, casos e cuidados
de execução. Copiar arquivos não treina um novo modelo nem transfere memória
oculta de conversas. Não atribuir ao DayToDay testes ou resultados do fitness.

## Lições que continuam válidas

- Inventário técnico gera candidatos; revisar três telas não prova cobertura
  completa. Declarar jornada, estado, versão e método de verificação.
- Conferir versão local e ambiente publicado antes de concluir regressão.
- Comparar capturas nas mesmas dimensões, escala, idioma, dados e estado.
- Corrigir constraints e composição; não ocultar texto nem diminuir fonte para
  esconder overflow. Testar fonte ampliada e teclado na composição real.
- Ação visível, semântica presente, hit target e interação concluída são
  verificações diferentes. Snackbar e overlays podem interceptar um controle.
- Aguardar o destino exclusivo e o fim da transição; um título compartilhado
  com a origem não comprova que a navegação terminou.
- Callback fake concluído não prova pintura final nem reabilitação do botão.
- Falha de instrumento, ambiente e produto têm causas diferentes. Conferir
  assinaturas do SDK e o contrato do fake antes de alterar o aplicativo.
- Verificar arredondamento entre pixels lógicos e físicos antes de concluir
  incompatibilidade de renderização; normalizar apenas o caso comprovado.
- Screenshot e inspeção semântica não certificam operação por TalkBack.
- Confirmar nível, plataforma e exceções de acessibilidade em fonte primária;
  não herdar o escopo AA Android/web do projeto de origem.
- Preservar dados reais, usar fixtures isoladas, manter tentativas anteriores e
  identificar processos próprios antes de encerrar infraestrutura de teste.
- Uma referência de mercado orienta uma hipótese; não comprova preferência de
  usuários e não autoriza copiar identidade, recursos ou regras de outro app.

As referências `runtime-validation.md`, `quality-oracles.md`,
`component-contracts.md` e `product-decisions.md` preservam o detalhamento.
`evaluation-cases.json` mantém os cenários históricos, inclusive os exemplos de
fitness, como calibração. `daytoday-cases.json` acrescenta situações deste app.

## Aplicação no produto atual

Preservar rotina offline, recorrência, duração, prioridade, sequência de tarefas,
histórico, dados locais e contratos de alarme. O alvo documentado é Android e
PT-BR, com identidade cromática aprovada. Consulte DOCUMENTOS.md e os testes para decisões
atuais; nenhum exemplo histórico substitui essas fontes.

Ao aprender algo novo nesta aplicação, registrar evidência, contexto, limite e
critério de revisão junto do checkpoint da rodada. Promover a padrão somente
quando o alcance e os consumidores estiverem verificados. Esta importação não
constitui uma nova auditoria ou aprovação para publicação na loja.
