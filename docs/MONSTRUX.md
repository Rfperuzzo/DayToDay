# MONSTRUX no DayToDay

Importado em 14/11/2026 a pedido do responsável, a partir do agente de UX do
Projeto Monstro. A importação lê a origem e modifica apenas este repositório.

## Como usar

Peça ao agente da sessão para usar `.cursor/agents/monstro-ux.md` no DayToDay.
Ele deve ler o perfil e carregar as skills locais conforme a tarefa:

- `.cursor/skills/monstro-ux-audit/SKILL.md`: jornadas, estados e evidências.
- `.cursor/skills/monstro-ux-actions/SKILL.md`: organização de ações.

O arquivo do perfil segue o formato de agente de projeto em `.cursor/agents`.
Em um host que não descubra esse diretório automaticamente, indicar o caminho
explicitamente; a existência do arquivo não comprova execução do agente.

## Experiência preservada

Foram mantidos o perfil Sênior++, as referências de runtime, composição,
comparação visual, decisões de produto e os cenários de calibração históricos.
As lições transferíveis e os novos casos estão em
`references/experience-transfer.md` e `references/daytoday-cases.json`, dentro
da skill de auditoria. Exemplos do fitness continuam identificados como
históricos; não são funcionalidades, requisitos ou testes aprovados do DayToDay.

`UX_SKILLS_LOCK.json` conserva as versões e os hashes dos 19 pins externos.
As 19 skills externas foram copiadas integralmente para `.cursor/skills`, com
131 arquivos e os mesmos hashes revisados na origem. Somadas às duas próprias,
são 21 skills locais. Licenças e referências de origem foram preservadas; não
houve download, instalação, atualização ou alteração global. Os recursos de
projeto são cópias independentes. Ferramentas como Flutter/Python continuam
sendo requisitos do ambiente; não foram empacotados compiladores ou modelos.

Verificação local, sem inferência:

```powershell
python -B tool/validate_ux_skill_pack.py --smoke
```

O verificador confere 19 árvores fixadas e as duas skills próprias, e o smoke
exercita buscas locais e a ajuda do helper web. Não é teste de UX do aplicativo.
A regra Git em `.cursor/skills/.gitattributes` preserva os bytes dos recursos
entre checkouts para evitar que conversão LF/CRLF invalide os hashes.

A adaptação substitui jornadas, caminhos e invariantes específicos do fitness
pelos do DayToDay: organização de rotina Android/PT-BR, offline, sem conta,
identidade neutra, dados locais, recorrência, prioridade, duração, sequência,
histórico, alarmes e widget. DOCUMENTOS.md e o código continuam sendo a fonte
das regras atuais.

## Origem e limites

`.cursor/monstrux-origin.json` registra o commit de origem e os hashes dos
arquivos importados, incluindo o conteúdo adaptado. Há adições locais para
contexto e experiência, identificadas separadamente. O manifesto não é uma
assinatura, avaliação de qualidade ou autorização de execução.

Este perfil é orientação de um agente na sessão Codex. Não substitui, instala
ou altera o runtime `.monstrux` do piloto, suas credenciais, confirmações,
orçamento ou registros. Não habilita API paga, créditos pagos, modelos locais,
download automático ou publicação. O consumo segue a franquia da sessão.

Esta rodada importa e adapta o agente. Não modifica o app e não declara uma
nova revisão visual concluída. A revisão para loja exige observação das telas e
jornadas, implementação autorizada, testes, comparação e registro das pendências.
Nenhum resultado de teste do app fitness é herdado como validação do DayToDay.
