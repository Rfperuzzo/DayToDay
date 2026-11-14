---
name: monstro-ux-audit
description: Conduz revisões UX do DayToDay por jornadas, superfícies e estados, com rastreabilidade de cobertura, invariantes funcionais, comparação visual e critérios de aceitação. Use na revisão por jornadas do DayToDay e na preparação de melhorias para Android.
---

# Revisão UX do DayToDay

Leia DOCUMENTOS.md, o AGENTS.md se existir e a definição `.cursor/agents/monstro-ux.md`. Esta skill
organiza a execução; as especializações são carregadas somente por necessidade.
Comece por investigação se não houver implementação autorizada. Não mude regras,
rotas, dados, prioridade, recorrência, alarmes ou permissões como se fossem decoração.

Ao preparar testes, capturas ou auditoria assistiva, leia
[validação de runtime e prontidão](references/runtime-validation.md). Ela trata
descoberta de ferramentas, contratos de fixtures, espera por rota/semântica,
medição de alvos e conferência normativa. Use a autorização e o escopo atuais;
pendências de uma rodada anterior não impedem correções agora autorizadas.

Leia [a experiência transferida](references/experience-transfer.md) ao iniciar
uma rodada; preserve as lições documentadas e use os
[casos DayToDay](references/daytoday-cases.json) para calibrar o contexto.

## Preparar o mapa de trabalho

1. Fixe commit/branch e ambiente analisados; não confunda PWA publicado atrasado
   com a main local. Confira alterações de terceiros e disponibilidade real de
   emulador, navegador e backend de teste.
2. Gere candidatos técnicos com
   `python tool/ux_surface_inventory.py --output .dart_tool/ux-review-AAAAMMDD/inventory.json`.
   O script é uma busca heurística em código, não um crawler exaustivo. Complete
   com navegação real, fluxos condicionais, menus, overlays e componentes sem classe
   própria. Nenhum candidato gerado é automaticamente considerado revisado.
3. Organize por jornadas: inicialização/permissões, painel/calendário, cadastro,
   edição/cancelamento, subtarefas, respostas/recuperação de alarme e widget Android.
   Preserve sequência, conflitos, recorrência, histórico e dados locais.
4. Identifique invariantes no código/testes: valores e parâmetros, persistência,
   cancelamento, retomada, destinos, permissões e sequência. Não congele uma regra
   antiga só porque está citada num relatório histórico.

## Cobertura com evidência

Para cada superfície, registre:

- Identificador estável, tarefa, entrada/saída e fonte de código.
- Estados aplicáveis: conteúdo, vazio, carregando, erro, offline, sucesso,
  cancelamento, retomada e permissão negada. Marque não aplicável com justificativa.
- Plataforma, tamanho lógico, escala de texto, paleta, claro/escuro, idioma e
  entrada por toque/teclado/leitor assistivo realmente verificados.
- Evidência, data/commit e resultado: não revisado, revisado, problema observado,
  corrigido e revalidado. Esses estados não são intercambiáveis.

Priorize riscos e depois amplie combinações. Use valores longos, fonte ampliada,
teclado e poucos/muitos registros. Não afirme cobertura do produto inteiro com
base em alguns screenshots ou numa média de notas. Denominadores devem informar
o inventário e as condições consideradas. Mudança de commit invalida evidências
afetadas, não necessariamente todas as verificações anteriores.

## Julgamento de produto

Faça uma passagem por tarefa e outra transversal por componentes. Na primeira,
avalie descoberta, clareza, feedback, esforço, erros e recuperação. Na segunda,
compare hierarquia, tokens, alinhamento, ritmo, campos, botões, janelas, mensagens
e áreas de toque. O uso diário com distração e interrupções informa hipóteses, não pesquisa
com pessoas já realizada.

Quando a proposta depender de resultado com usuários ou virar padrão compartilhado,
leia [decisões de produto, inclusão e evolução](references/product-decisions.md).
Defina objetivo → sinal → medida com baseline/fonte/denominador, proteção contra
dano e validade da evidência. Planeje participação inclusiva e responsabilidade
humana de adoção, sem inventar dados nem instalar coleta por iniciativa.

Classifique cada achado por impacto, evidência e alcance. Uma preferência de
gosto não é um defeito comprovado. Uma mudança que remove opções ou altera seu
significado não se torna visual só por reduzir a quantidade de botões.

Para sugerir onde cada botão deve ficar e como harmonizar grupos, use
[`monstro-ux-actions`](../monstro-ux-actions/SKILL.md). Ela exige proposta por
ação/estado, posição recomendada, motivo, invariantes e critério de verificação.
Decisões equivalentes e risco não podem ser reduzidos a uma cor ou posição fixa.

Para pesquisa com pessoas, planeje tarefas neutras e critérios observáveis com
`user-research`. Sem participantes ou dados reais, entregue plano/hipóteses;
não invente entrevistas, citações ou percentuais. Use `research-synthesis`
somente sobre material fornecido/acessível com autorização, protegendo dados.
Tamanhos de amostra de templates são exemplos, não garantias estatísticas.

## Proposta pronta para implementar

Para cada recomendação, forneça problema, evidência, hipótese causal, mudança
proposta, invariantes, componentes afetados e critério verificável de aceitação.
Compare alternativas apenas quando existe trade-off relevante. Quando houver
autorização visual, prefira o menor grupo coerente com maior benefício.

Use `design-critique` para feedback estruturado, `design-system` para padrões
existentes, `ux-copy` para linguagem consistente e `design-handoff` para critérios
de implementação. Eles não autorizam publicar em wikis, criar tickets, convidar
pessoas, conectar contas ou reformular o produto. Preserve o idioma PT-BR e somente declare idiomas presentes no projeto.

Em componentes compartilhados, overlays e sessões ativas, consulte
[contratos de componentes e execução](references/component-contracts.md).
Defina o que o widget garante e o que a tela precisa fornecer; teste a composição,
não só as peças. A referência reúne técnicas de projetos reais com commits
fixados e contrapontos. Um padrão local só se torna global com contexto e evidência.

## Executar e verificar quando autorizado

- Corrija a causa: constraints, composição, semântica, estado ou token. Evite
  diminuir fonte, ocultar texto, bloquear zoom ou recortar conteúdo para esconder
  overflow. Não atualize goldens para simplesmente aceitar uma regressão.
- Compare antes/depois com os mesmos dados, dimensão, tema, idioma e escala.
  Para testes visuais, estabilize fontes, relógio e animações no ambiente de teste,
  sem mascarar estados reais. Mudanças de pixels exigem interpretação e interação.
- Em tokens/componentes compartilhados, confira consumidores e variantes antes
  de propagar. Em mudanças de apresentação com risco de toque/foco, teste a ação
  completa, a saída, o cancelamento e a volta ao destino esperado.
- Reaproveite test/features/dashboard, activities, alarms, home_widget e
  routine_engine. Use fixtures locais e não mude dados pessoais para testar.
- Meça desempenho em condições adequadas. Animação mais rápida não prova uma
  tarefa mais fácil; emulador debug não prova custo em release. Explique limites.

Ao definir assertivas ou comparar capturas, leia
[oráculos e comparação visual](references/quality-oracles.md). Distingue pixel,
interação, semântica, teste assistivo e persistência; um golden pode aprovar uma
imagem que ainda contém erro. Aproveite as ferramentas já disponíveis no projeto.

Para comparações extensas, use o [registro verificável](references/evidence-format.md)
e `scripts/check_review_evidence.py`. Ele confere metadados, arquivos, métodos e
pendências do plano declarado sem executar o app. Resultado válido não prova
verdade das evidências, completude do plano ou qualidade UX. Não exigir esse
formato para uma observação simples nem usá-lo como selo automático de aprovação.

## Encerrar sem esconder pendências

Entregue síntese, achados priorizados, decisões, evidências, cobertura e pendências.
Relatório amplo usa o formato visual previsto pela skill canvas. Não crie gráficos
ou notas de qualidade sem dados/método. Só marque corrigido após revalidação.
Mantenha continuidade e logs conforme a definição do agente; PR, revisão remota e
autorização de merge/publicação seguem as regras do projeto. Actions fica pausado.

Use [os cenários de calibração](references/evaluation-cases.json) quando atualizar
este agente. Avalie classificação e justificativa, não só palavras-chave. São
casos de preparação e regressão das instruções; não certificam expertise nem
substituem observação do agente em tarefas reais do app.
