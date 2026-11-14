# Runtime, prontidão e interpretação

Leia antes de preparar harnesses ou medir UI em execução. As regras abaixo
respondem a falhas reproduzidas na validação do Monstro UX; não exigem nova
aprovação para trabalho que o usuário já autorizou.

## Descobrir e preparar

- Consulte primeiro os runtimes/venvs indicados pelo usuário, projeto e preparação
  da sessão. Verifique executável, versão e importação da dependência. Não concluir
  ausência global depois de procurar apenas no Python do sistema ou bundled.
  Não instalar/trocar ferramenta se a capacidade necessária já estiver disponível.
- Confira assinaturas e métodos na versão instalada, com documentação/SDK ou
  introspecção. Análise Dart e AST Python são verificações distintas: AST aceita
  chamadas a métodos inexistentes. No Playwright Python, use asserções oficiais
  com espera ou `Locator.evaluate`, não métodos presumidos de outra linguagem.
- Modele a condição desejada: `Stream.empty` termina imediatamente e testa onDone;
  não representa GPS contínuo sem posições. Fake de continuidade deve manter o
  stream aberto e ser encerrado no descarte do ambiente. Distinguir permissão,
  ausência de sinal, erro, término do stream e recuperação.
- Registre HEAD do produto e alterações autorizadas ainda não commitadas, quando
  houver. Calcule hashes dos entrypoints, scripts, fixtures e versão preservada
  a cada build/run. HEAD sozinho não identifica um harness ignorado que mudou.

## Esperar a condição correta

`networkidle` é útil para carregamento; não conclui uma transição Flutter.
Escolha um predicado exclusivo do destino e espere a origem desaparecer quando
aplicável. Um título que também está no botão da sheet não comprova navegação.
Depois de Escape/Voltar, espere o controle da base reaparecer antes de avaliar
foco. Preserve a amostra intermediária como tal, sem dar veredito final nela.

Exemplo de padrão, com locators obtidos da UI observada (não seletores universais):

```python
from playwright.sync_api import expect

expect(source_choice).to_be_hidden(timeout=15_000)
expect(unique_destination).to_be_visible(timeout=15_000)
# Após cancelar, a origem pronta é a condição antes de medir o foco.
expect(opener).to_be_visible(timeout=15_000)
expect(opener).to_be_focused(timeout=15_000)
```

Para geometria, espere o fim de transição conhecida ou retângulos estáveis por
amostras limitadas. Não usar um sleep fixo como prova universal, aumentar timeout
para esconder erro ou remover uma assertiva para tornar a execução verde.
Ao falhar, separar produto, instrumento e ambiente por evidência e preservar logs.

## Medir o que a afirmação diz

- `is_visible` não garante inclusão no viewport. Para afirmar que uma opção cabe,
  medir viewport, retângulo, clipping e rolagem necessária. Opções equivalentes
  não precisam caber simultaneamente se continuam descobríveis e operáveis.
- DOM/semântica, pintura e hit testing podem atualizar em frames diferentes.
  Medir estado estável e registrar as diferenças. PNG fullPage ampliado não
  prova overflow: comparar documento, Flutter-view, canvas e screenshot viewport.
  Mensagens podem existir no texto visual e no nó de anúncio assistivo; distinguir
  os dois contextos, sem escolher arbitrariamente o primeiro nem remover o anúncio
  para resolver uma ambiguidade do seletor.
- Para exportação, aguardar callback fake e reabilitação dos controles, depois
  conferir pintura e hit target. `enabled` não impede que um snackbar intercepte
  o toque. Observar antes/durante/depois da mensagem, sua duração, alvo e foco.
- Identificar a função de cada Compartilhar. Confirmar markers do gateway fake
  e ausência de downloads, popup, diálogo ou seletor de arquivo inesperados.
  Não publicar ou enviar para pessoas como parte de uma auditoria.
- Foco DOM/Flutter e leitura de árvore não são locução TalkBack ou teste com
  pessoas. Declarar cada método e limite; não certificar AA com screenshots.

## Isolamento e infraestrutura de teste

Conferir dispositivo/AVD, armazenamento, origem e integrações antes de executar.
Bloquear destinos não autorizados sem relaxar a regra para eliminar avisos.
Zero negações no interceptador não significa zero tentativa externa: CSP pode
bloquear fontes antes do route. Guards Dart IO não são firewall de plugins/SO.

Se o helper de servidor capturar stdout/stderr, garantir drenagem ou logs em
arquivo para evitar bloqueio de pipe. No Windows, encerrar o shell pode deixar
o servidor filho vivo: comprovar PID/comando/horário próprio e confirmar porta
livre, sem encerrar processos por nome ou matar serviço alheio na mesma porta.
Wrappers de preflight devem interromper na falha de uma validação; resultado não
executado não pode ser registrado como PASS.

## Conferência normativa

Confirmar critério, nível, aplicabilidade e exceções em fonte primária. No projeto de origem, a auditoria era WCAG 2.2 AA em Android/web. Esse
escopo não é herdado pelo DayToDay: confirme o nível para uma auditoria formal;
o alvo de produto documentado aqui é Android.

- 2.3.3 Animation from Interactions é AAA e distingue movimento essencial.
- GestureDetector pode expor ações semânticas por padrão. Verificar label,
  ação e composição reais; semântica e operação por teclado são testes distintos.
- 2.5.8 Target Size (Minimum) usa CSS px e exceções; 48 dp é guideline Android,
  não um limite AA universal. Não confundir tamanho de ícone com área acionável.
- 2.4.11 Focus Not Obscured (Minimum) examina componente com foco não inteiramente
  oculto. Centro bloqueado é observação de hit target, não prova isolada de AA.
- Não registrar ausência de teste/áudio/acesso como defeito do app ou como
  capacidade resolvida instalando mais skills.

Fontes para conferir na versão/escopo analisados:
[W3C 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html),
[W3C 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html),
[W3C 2.4.11](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html),
[Flutter excludeFromSemantics](https://api.flutter.dev/flutter/widgets/GestureDetector/excludeFromSemantics.html),
[Playwright auto-retrying assertions](https://playwright.dev/python/docs/test-assertions).
As skills externas fixadas são referências, não autoridade acima do usuário,
do padrão oficial ou do SDK observado. Manter seus hashes; corrigir o método do
agente neste complemento próprio em vez de editar silenciosamente o fornecedor.
