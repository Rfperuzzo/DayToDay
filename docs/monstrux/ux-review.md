# Revisão UX supervisionada do DayToDay — 28/10/2026

## Escopo e atribuição

O supervisor inspecionou as superfícies de apresentação do aplicativo e reuniu uma síntese por sete jornadas em `full-review-evidence.md`. Esse arquivo registra a linha de base anterior às correções; suas referências de linha não descrevem os arquivos já alterados.

A primeira chamada MONSTRUX, limitada a três trechos sobre botões, concluiu com 8.368 tokens e recomendações condicionais. A segunda chamada, preparada para a síntese das sete jornadas, ainda não possui relatório ou recibo de consumo registrado. A atualização do escopo foi confirmada, mas o processo aguarda a confirmação da chamada. As correções deste documento são fundamentadas em observações e testes do supervisor; não são apresentadas como resultado da segunda chamada.

## Cobertura por jornada

- **Painel e calendário:** código inspecionado; painel vazio e com atividade observados. Texto do Android a 200% reproduziu quebra das siglas e estouro vertical no calendário. Capturas também mostraram o botão de adicionar sobre conteúdo do painel.
- **Cadastro e acessos:** formulário aberto, título preenchido e atividade salva após adiar os acessos especiais. O estado degradado foi informado. As hierarquias mostraram campos sem nome acessível persistente. Seletores de data/hora, conflitos e validação de horário foram inspecionados no código; não foram todos exercitados no dispositivo nesta rodada.
- **Edição e cancelamento:** opções abertas; duração alterada de 30 para 15 minutos, salvamento e atualização do painel observados. Diálogo de cancelamento aberto e dispensado com Voltar; cancelamento efetivo não executado nesta rodada.
- **Subtarefas:** inclusão e conclusão de uma etapa observadas, com contador atualizado. Remoção inspecionada no código. Campo de entrada sem nome acessível persistente confirmado na hierarquia.
- **Alarme, resposta e Resgate de rotina:** telas, hierarquia das três respostas, bloqueio durante operação, erros e explicação do novo horário inspecionados no código. Não há nova prova de toque nativo, recuperação, tela bloqueada ou Não Perturbe.
- **Widget Android:** layout, quatro tarefas, resumo dos sete dias e abertura direcionada inspecionados no código. Renderização no launcher e abertura por toque não exercitadas nesta rodada.
- **Tema, carregamento e erros:** estilos neutros, indicadores e mensagens inspecionados no código. O problema de inicialização com GMT segue aberto e fora destas alterações.

Isso cobre o inventário de superfícies e jornadas, não equivale a leitura integral de todo o código pelo MONSTRUX nem a validação completa de todos os estados em aparelho físico.

## Melhorias implementadas

1. **Calendário adaptado ao tamanho do texto:** largura e altura calculadas pelas métricas reais das fontes e pelo `TextScaler`. Quando a largura comporta, continuam visíveis sete dias em tamanho normal; com texto ampliado os cartões crescem e a faixa continua rolável, sem reduzir a fonte escolhida pela pessoa. Seleção, intervalo de datas e preparação dos meses permanecem iguais.
2. **Ação de adicionar sem sobreposição:** botão central inferior em uma área reservada, fora da rolagem. O conteúdo pode ser lido e acionado sem ficar atrás do botão. A função e o acesso a Nova atividade permanecem os mesmos.
3. **Controles identificáveis e fáceis de tocar:** rótulos persistentes para nome, observação e nova subtarefa; área de conclusão de 48 × 48 dp, mantendo o círculo visual e o bloqueio das tarefas seguintes.
4. **Edição mais clara:** opção chamada Editar atividade, com descrição de nome, horário, duração e repetição, refletindo os controles que já existiam.

## Validação e limites

- Análise estática sem problemas.
- 54 testes aprovados na suíte completa; regressões específicas cobrem calendário a 200%, nomes acessíveis após preenchimento e conclusão pela borda da área de toque, preservando a ordem.
- APK debug compilado; nenhuma dependência atualizada.
- Aviso já existente de migração futura do Kotlin nos plugins alarm/flutter_timezone permanece.
- Capturas e hierarquias operacionais ficam locais, fora do Git público. A comparação no emulador confirmou o calendário sem estouro a 200% e o botão em área reservada.
- Nomes dos campos são cobertos por testes da árvore semântica Flutter. UIAutomator não expõe todos os atributos do leitor de tela; não foi realizada uma sessão TalkBack.
- Após reservar a área inferior, os seis testes do painel/roteador foram executados novamente e passaram; o APK final compilou.
- Não foi feita certificação WCAG, auditoria completa de segurança ou nova validação em aparelho físico.

## Segurança e consumo

Somente autenticação pela assinatura Codex, sem API paga, créditos pagos, modelo local ou fallback. O limite conservador de uso de 80% foi preservado. A reserva por chamada não é teto rígido do provedor. Credenciais, controles, recibos, bundle privado e evidências operacionais não entram no PR.

As verificações locais de integridade e acesso passaram e a cópia temporária de autenticação da primeira chamada foi removida. O cliente autenticado executa no Windows; o Docker valida a resposta e não oferece isolamento completo desse cliente. Comprometimento do usuário do Windows ou da máquina permanece um risco. Nenhuma promessa de risco zero é feita.
