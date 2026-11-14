# Piloto MONSTRUX no DayToDay — 28/10/2026

## Estado após as análises e implementação

Duas chamadas concluíram sem cobrança adicional: a primeira limitada usou 8.368 tokens; a segunda avaliou a síntese das sete jornadas e usou 8.731. A revisão ampliada priorizou as quatro frentes confirmadas pelo supervisor. O modelo avaliou a linha de base, não a implementação final. O aplicativo recebeu ajustes de calendário com texto ampliado, identificação dos campos, área de toque, ação de adicionar e nome da edição. A análise estática passou, 54 testes passaram e um novo APK debug compilou. Veja a cobertura e os limites em [ux-review.md](monstrux/ux-review.md).

Os registros abaixo descrevem a preparação inicial e são mantidos como histórico.

## Instalação e estado inicial

O piloto usa a candidata MONSTRUX 0.9.0, instalada localmente com adapter Flutter
na branch `codex/monstrux-pilot`. O DayToDay é público; a fonte privada do
MONSTRUX e as evidências ficam excluídas localmente do Git. Não publicar
`.monstrux/`, `.evidence/`, autenticação ou diretórios de controle.

Nenhuma dependência MONSTRUX foi adicionada ao Flutter/Android. Os controles,
as chaves e a memória ficam fora do aplicativo. O app continua offline;
esta preparação não adiciona telemetria, rede ou inferência ao APK.

## Primeira tarefa preparada

Revisão somente de hierarquia e consistência de botões a partir dos trechos
verbatim de `docs/monstrux/pilot-evidence.md`: tema compartilhado, ação de adicionar
atividade e botão de salvar. Os hashes completos e as linhas estão no registro
local `.evidence/pilot-source-map.json`. Trata-se de amostra, não de todos os
arquivos nem de uma auditoria visual completa.

O escopo do modelo permite ler apenas essa evidência; não permite escrita ou
preparação de candidato. Método `actions`, uma sessão, orçamento de 12 mil tokens,
pacote de 17.408 bytes dentro do limite de 18 mil. Propostas e preferências precisam
de evidência e revisão; diferença de tamanho por função não é defeito automático.

## Bloqueio inicial de consumo — histórico

A consulta informou 95% de uso da janela Codex, acima do limite conservador de 80%.
O próprio preflight do runtime negou com `quota_safety_margin_reached`.
Nessa preparação, nenhuma inferência MONSTRUX havia sido iniciada; nenhuma API paga foi
habilitada e nenhum modelo local foi baixado/executado.

A janela informou reset em 28/10/2026 às 20:27:05, horário de São Paulo. É preciso
consultar novamente antes de executar; não há retomada automática ou agendamento.
As instruções completas para a máquina do operador estão no arquivo privado
`.evidence/RESUME_MONSTRUX.txt`; o CLI exige revisão da tarefa e confirmação do hash.

## Validação executada pelo supervisor

- Flutter 3.44.2 / Dart 3.12.2: versões compatíveis com o projeto.
- Dependências obtidas com o lockfile exigido, sem upgrade.
- Análise estática: nenhum problema encontrado.
- Testes Flutter: 52 aprovados.
- APK debug compilado com sucesso.
- Instalação no AVD dedicado `DayToDayMonstrux35`, Android 35, sem dados de pessoa.
- Painel vazio observado e formulário Nova atividade aberto pela ação acessível
  Adicionar atividade, com screenshot e hierarquia reais.
- Não foi concluído um ciclo criar/salvar/editar/alarme/subtarefas/widget nesta rodada.
  O emulador foi encerrado após as capturas; a tentativa posterior de validação
  do formulário não executou porque o dispositivo já estava desconectado.

Essas observações são do supervisor. Não atribuí-las a um relatório do runtime
MONSTRUX, que ficou bloqueado pela franquia.

## Achado funcional fora do escopo visual

**D-001 — inicialização falha com o fuso GMT.** Em um emulador novo, o app
permaneceu na splash e registrou `Location with the name "GMT" doesn't exist`
em `IanaTimeZoneService.create`, linha 15. A consulta do fuso é repassada a
`tz.getLocation` antes de `runApp`, sem tratar esse identificador.

Configurar apenas o emulador para `America/Sao_Paulo` permitiu iniciar o painel.
Isso é uma condição de teste, não correção do bug. Nenhum tratamento de fuso,
regra de negócio ou arquivo Dart foi alterado. Uma correção funcional exige
escopo separado e teste de regressão antes de declarar o problema resolvido.

## Ocorrências de ambiente

- A primeira execução de testes falhou ao resolver GitHub para obter a DLL
  SQLite. O artefato oficial sqlite3-3.5.2 foi obtido e conferido contra o SHA256
  publicado no pacote, abastecendo somente o cache de build. O hook manteve sua
  própria validação de hash. Não houve troca de biblioteca ou redução de checks.
- O criador de AVD encontrou Java antigo. Foi usado o JDK do Android Studio
  apenas no processo de criação do emulador; não houve alteração global de Java.
- O build informou aviso de compatibilidade futura de KGP em `alarm` e
  `flutter_timezone`. O build atual passou; plugins não foram atualizados.

## Próximas jornadas

Após liberar a franquia, executar e avaliar a primeira análise limitada antes de
ampliar o acesso. Depois revisar painel, cadastro, edição/cancelamento, subtarefas,
alarme/recuperação e widget em rodadas com orçamento e cobertura explícitos.

O operador navega, testa e fornece evidências; o runtime atual não navega pelo app
nem recebe screenshots. Não usar essa sessão administrativa como prova de que
um agente com shell é isolado. Mudanças visuais aprovadas terão comparação antes/
depois e testes proporcionais; regras de rotina, dados e alarmes serão preservados.

Issues/PRs automáticos em clientes ainda não são capacidade do runtime. Não houve
push, issue, PR, merge ou operação de workflows no DayToDay nesta preparação.
