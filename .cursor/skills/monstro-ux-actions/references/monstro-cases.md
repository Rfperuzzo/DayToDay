# Casos concretos para decisões de ações

Referências estáticas lidas em 24/10/2026, base `34a87ad6`. Confirme código e
testes no commit da revisão; isso não registra execução nem defeitos visuais.
Use como briefs para avaliação ou quando a tarefa afetar esses fluxos. Uma
proposta pode divergir em posição se a justificativa preservar o contrato.

## Cardio GPS

Fonte: `lib/src/features/workouts/presentation/cardio_gps_page.dart`, `CardioGpsPage`.

O controle alterna iniciar, pausar e retomar. Salvar/encerrar só aparecem depois
de existir sessão e respeitam busy. Mapa é opt-in anterior à sessão, separado da
permissão GPS. Descarte tem confirmação; sair e concluir dependem de checkpoint.
Falha de checkpoint mantém a tela para nova tentativa. Configurações é contextual.

Brief: proponha a organização pré-início, ativo, pausado, permissão negada e
falha de checkpoint. Cubra tela pequena/texto ampliado, estabilidade, funções
condicionais e diferença entre salvar, descartar e sair. Compare persistência
de controles só se justificar; não afirmar vantagem ergonômica sem observação.

## Conclusão do cardio

Fonte: `lib/src/features/workouts/presentation/cardio_completion_page.dart`.

Compartilhar atividade e compartilhar com foto usam caminhos diferentes; foto
tem busy próprio. Progresso e início retornam destinos diferentes. Mapa opcional
pode anteceder os botões. Atividade descartada não oferece compartilhamento.

Brief: organize as quatro ações com/sem mapa, ao abrir foto e em descarte.
Preserve cada destino e compartilhar sem foto. Justifique o destaque sem presumir
qual ação é mais usada. Registro prévio não deve ser apresentado como dependente
de compartilhar; duplicação de rótulos não significa duplicação de contratos.

## Montagem de treino

Fonte: `lib/src/features/workouts/presentation/workout_builder_page.dart`.

Seleção usa pesquisa/filtros e lista; o CTA de revisão depende da seleção e
fica oculto com teclado. A revisão final permite adicionar mais e salvar/usar
no desafio conforme contexto. Busy bloqueia salvar. Voltar com dirty preserva
confirmação de descarte e continuar editando.

Brief: compare busca com teclado aberto/fechado, quantidade insuficiente/suficiente
e revisão no desafio. Classifique explicitamente a proposta de tornar o CTA
sempre visível: altera uma interação atual coberta por teste, não só espaçamento.
Não sugerir mudança no mínimo de exercícios ou no descarte como ajuste visual.

## Entrada e manual/IA

Fontes: `workouts_page.dart`, `workout_creation_method_sheet.dart` na mesma pasta
de apresentação; calistenia reutiliza o seletor pelo `app_shell.dart`.

Treino, Calistenia e Cardio são entradas distintas. Ênfase de Treino varia com
estado vazio/conteúdo. O seletor manual/IA é compartilhado, respeita disponibilidade
independente e retorna escolha ou cancelamento sem perder modalidade.

Brief: proponha organização nos estados vazio, com fichas e opção indisponível,
em PT/EN/ES e texto ampliado. Não priorizar IA por tendência, remover alternativa,
mesclar modalidade ou eliminar a etapa existente sem declarar alteração funcional.

## Avaliação das propostas

Conferir cobertura das ações/estados do brief, local recomendado e justificativa,
invariantes, adaptação e teste observável. Verificar se o agente identifica
incerteza e diferencia hipótese de execução. Posição exata não tem gabarito
universal: avalie a coerência do raciocínio e os efeitos sobre a tarefa.
