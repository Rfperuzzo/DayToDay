# Decisões de produto, inclusão e evolução de padrões

Use para propostas cujo benefício dependa de comportamento, medição, pesquisa ou
adoção transversal. Não impor esse processo inteiro a uma correção de espaçamento.
São adaptações de práticas públicas, não requisitos universais de uma big tech
nem prova de equivalência profissional do agente.

## Resultado observável antes de escolher indicador

Defina objetivo da pessoa → sinal observável → medida que permite decidir.
Exemplo de plano: descobrir treino manual sem ajuda → primeira escolha correta
e conclusão da tarefa → tentativas elegíveis concluídas sem ajuda / tentativas
elegíveis observadas, registrando também erros e pedidos de ajuda. Não há dados
reais desse exemplo. Um teste automatizado verifica execução, não descoberta humana.

Para uma decisão relevante, registre definição da tarefa, população/contexto,
fonte e método, unidade, numerador/denominador quando aplicáveis, período e
baseline real ou ausente. Diferencie eventos, tentativas, sessões e pessoas;
trate duplicatas, perdas, ausências e exclusões antes de comparar números.
Fixe o critério de decisão antes de olhar resultados; revise-o explicitamente
se o objetivo mudar. Não inventar limite numérico ou significância.

Escolha só os aspectos úteis do [Google HEART e Goals–Signals–Metrics](https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/).
Mais cliques, engajamento ou tempo no app não são necessariamente melhores para
a pessoa treinando. Não preencher todas as categorias por formalidade nem
introduzir analytics/SDK como efeito colateral de uma proposta visual.

## Ganho, proteção e validade são decisões diferentes

Para cada proposta de maior risco/alcance, escolha:

- Resultado principal que representaria melhora da tarefa.
- Proteções pertinentes: evitar toque errado, perda de sessão, consentimento
  alterado, cancelamento quebrado, inacessibilidade e regressão de desempenho.
- Qualidade da evidência: versão, condições, definição da medida, dados faltantes,
  duplicação e comparação equivalente.

Não compensar uma falha séria de persistência, acesso ou consentimento com uma
média de rapidez ou conversão. Defina condições de interromper/reverter antes
de uma mudança autorizada; qualquer reversão de produto segue seu próprio escopo
e decisão humana. Isso não autoriza deploy, feature flags ou experimento de produção.

A [taxonomia do Microsoft ExP](https://www.microsoft.com/en-us/research/articles/patterns-of-trustworthy-experimentation-during-experiment-stage/)
fundamenta essa separação. Os limites numéricos e decisões da organização de
origem não são transferíveis automaticamente ao Monstro.

## Inferir somente o que o método sustenta

Identifique inspeção heurística, teste técnico, pesquisa qualitativa, comparação
observacional ou experimento causal. Registre hipótese refutável, como escolher
entre alternativas e o que mudaria sua recomendação. As saídas possíveis incluem
manter, experimentar de forma autorizada, corrigir, investigar e inconclusivo.

Antes/depois em ordem fixa pode refletir aprendizagem; conveniência não representa
todo o público; média não apaga falha de um grupo; ausência de diferença não prova
equivalência. Um protótipo não comprova persistência, acessibilidade real ou uso
sustentado. Sem dados, entregar proposta e plano como hipótese ainda pode ser útil.
Um sintoma relatado não identifica sua causa. Não anunciar que uma alternativa
elimina o problema antes de reproduzir e revalidar; formular a causa e o efeito
esperado como hipóteses quando ainda não foram demonstrados.

Se um A/B real for solicitado, planejar alocação, unidade, amostra/poder,
qualidade dos dados e análise com a especialização adequada antes de interpretar
efeitos. [SRM e perdas desiguais](https://www.microsoft.com/en-us/research/articles/diagnosing-sample-ratio-mismatch-in-a-b-testing/)
podem invalidar inferências. Não aplicar SRM a pequenas entrevistas/fixtures nem
declarar causalidade por uma diferença percentual de cliques. Consultar também
[interpretação posterior do ExP](https://www.microsoft.com/en-us/research/articles/patterns-of-trustworthy-experimentation-post-experiment-stage/).

## Pesquisa inclusiva que pode ser executada

Use `user-research` para um plano proporcional. Defina pergunta e tarefa neutra,
critérios de seleção por experiência/capacidades/contextos relevantes, forma de
participação acessível, materiais, resultado observável e limites. Exemplos a
investigar no Monstro: iniciantes/experientes, literacia tecnológica, uso de
tecnologia assistiva, dispositivo e contexto de treino. Não inventar distribuição
ou personas, impor diagnóstico como proxy nem fixar cinco pessoas como cobertura total.

Planeje consentimento para participação/gravação, dados estritamente necessários,
acesso/retenção do material e anonimização. Prefira fixture sem localização ou
dados pessoais quando suficiente. Não recrutar, contatar, gravar ou instalar
coleta sem autorização correspondente. Planejamento não é pesquisa realizada.

Referência: [Microsoft Inclusive Design — screeners](https://inclusive.microsoft.design/articles/inclusive-design-for-cognition-screeners).
O princípio de seleção inclusiva precisa de adaptação ao nosso objetivo e público,
não reprodução de um formulário inteiro ou garantia estatística por template.

## De experimento local a padrão mantido

Para novo padrão compartilhado, registre problema recorrente, componentes atuais,
estado (proposta, piloto, adotado no escopo ou estável por decisão humana), usos
demonstrados, limites, responsável a confirmar, impacto de adoção/migração e
condição de reavaliação. Não inventar aprovador, cargo, consenso ou dono.

Confira revisão humana de produto/design, engenharia e acessibilidade conforme
o impacto; explicite divergências e a decisão que falta. Uma captura e preferência
de um designer não provam prontidão para migrar todos os consumidores. Um padrão
estável ainda pode evoluir. A aprovação local não autoriza merge ou publicação.

Referências: Primer [novos padrões](https://primer.style/product/contribute/handling-new-patterns/)
e [novos componentes](https://primer.style/product/contribute/adding-new-components/).
Aplicar esse ciclo quando há adoção compartilhada real, sem criar comitê ou
burocracia para cada ajuste local.

## Avaliar o próprio agente

Separar casos usados para desenvolver instruções de novos casos de avaliação.
Quando útil, comparar resposta genérica e configurada à mesma entrada, sem
respostas esperadas, e usar revisão independente com critérios definidos antes.
Verificar proposta útil, inferência proporcional, preservação de contratos e
validade da medição. Identificar erros que impedem uso e incertezas restantes.

Uma execução por condição em poucos casos é um piloto, não benchmark de produção
nem prova de superioridade. Modelo, ferramentas, contexto e variação entre runs
podem afetar resultado. Não converter aprovação de metadados/fixtures em nível
Big Tech. Reavaliar o agente com tarefas novas e resultados reais autorizados.

Fontes consultadas em 24/10/2026. Nenhum método ou documento foi apresentado como
política interna completa dessas empresas; nenhuma telemetria, experimento,
pesquisa humana ou publicação foi realizada ao acrescentar esta referência.
