# Registro verificável de evidências

Use este formato quando a revisão produzir muitas capturas/testes ou uma
comparação antes/depois que justifique checagem automática. Não é obrigatório
para uma revisão curta sem implementação. O arquivo e suas evidências ficam
em diretório ignorado, por exemplo `.dart_tool/ux-review-AAAAMMDD/`.

Execute com o Python disponível, a partir do projeto:

```powershell
python .cursor/skills/monstro-ux-audit/scripts/check_review_evidence.py .dart_tool/ux-review-AAAAMMDD/evidence.json
```

O comando só lê arquivos. Saída 0 significa que o plano declarado tem registros
compatíveis e resultados posteriores aprovados; 2 indica pendências do plano;
1 indica formato/referência/integridade inválidos. Nenhum desses resultados
certifica o app, a verdade do conteúdo ou a abrangência do plano. Interprete
manualmente logs, capturas e assertivas. Não preencher “pass” só para validar JSON.

## Campos do manifesto (schemaVersion 1)

- `scope`: limite real da comparação, por exemplo componente e jornadas afetadas.
- `baselines`: objetos `before` e `after`, cada um com `commit` Git completo e
  `worktree`: `clean` ou `sha256:` seguido do hash de um snapshot das mudanças
  relevantes. Registre como o snapshot foi produzido; hash não prova execução.
- `cases`: lista com `id` único, `criterion`, `conditions` e `requiredChecks`.
  Cada caso é uma combinação intencional de estado e condições. Inclua o estado
  no id/critério. O inventário heurístico não preenche os casos automaticamente.
- `evidence`: lista com `id` único, `path` relativo à pasta do manifesto,
  `sha256` dos bytes e `method`. Evidência fora dessa pasta é recusada.
- `records`: lista com `caseId`, `phase` (`before`/`after`), `baseline`,
  `conditions` realmente usados e `checks`. Baseline e condições devem coincidir
  com o plano; comparações divergentes precisam de plano separado e explicação.

`conditions` contém exatamente estes campos. Números: `widthDp`, `heightDp`,
`dpr`, `textScale` positivos. Textos não vazios: `platform`, `locale`, `palette`,
`brightness`, `font`, `sdk`, `os`, `renderer`, `fixture`, `clock`, `animation`,
`assets`, `buildMode`. Informe versões e identidades concretas quando conhecidas.
Use `not-applicable: motivo` quando um campo não se aplicar; “unknown” explicita
limite, não demonstra controle da variável. Compare dimensões lógicas, não a
resolução física da screenshot. O helper não mede essas condições por si só.

Os checks aceitos são `layout`, `interaction`, `semantics`, `assistive`, `content`
e `performance`. O record contém exatamente os checks planejados, por exemplo:

```json
{
  "interaction": {
    "status": "pass",
    "evidenceIds": ["cardio-share-widget-test"]
  },
  "assistive": {
    "status": "blocked",
    "reason": "TalkBack não disponível neste ambiente"
  }
}
```

Resultados `pass`/`fail` exigem evidência existente e método compatível.
`blocked`, `not-run` e `not-applicable` exigem motivo. Não substituir uma falha
por não aplicável para concluir a revisão. Alterações do plano precisam de
justificativa no registro de decisões; o helper não reconstrói esse histórico.
Falha reproduzida no `before` é válida como linha de base; falha no `after`
impede declarar o plano registrado sem pendências.
Falha anterior convertida em `not-applicable` posterior também mantém pendência:
exclusão não é revalidação. Se a função foi retirada com autorização, explique a
mudança de escopo e seu critério em um plano próprio; não marque o contrato
anterior como corrigido.

## O que cada método consegue sustentar

- `screenshot`: aparência/conteúdo; não demonstra toque, semântica ou ganho de tempo.
- `widget-test`/`integration-test`: somente as assertivas realmente executadas;
  o log isolado não prova teste físico de tecnologia assistiva.
- `manual-interaction`: passos e resultado observados em execução; nomeie o ambiente.
- `semantics-dump`: árvore semântica, não experiência real de leitor de tela.
- `assistive-test`: execução real identificada com leitor/tecnologia assistiva.
- `static-inspection`: conteúdo/código; não comprova execução.
- `measurement`: medição com unidade, método e condições; não usar para porcentagem
  de melhora sem linha de base comparável e controle de ruído.

O verificador recusa usar apenas screenshot para aprovar interação e apenas
árvore semântica para aprovar teste assistivo. Ele não consegue detectar um log
falso ou um método rotulado incorretamente. Esse julgamento continua obrigatório.
Não existe nota automática de qualidade UX nem selo de perfeição.
