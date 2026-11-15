# Registro histórico da primeira preparação

Este relatório antecede a assinatura e a política pública. Para o estado atual,
leia ENTREGA_PRODUCAO.md nesta pasta e VERIFICACAO_TECNICA.json.

# MONSTRUX — revisão de apresentação para Play Store

Data15/11/2026. Escopo: claims, narrativa e revisão visual de materiais locais;
sem publicação, pagamento, criação de chave ou alteração de código. Estado:
revisão visual dos oito assets e dos claims concluída; correção de privacidade revalidada. Parecer aprovado para o kit preparatório, com pendências de publicação explícitas no fechamento.

## Argumento do produto

DayToDay organiza a rotina por lembretes e blocos opcionais de tempo. O valor
central é lembrar sem obrigar a reservar30min para uma ação pontual, permitindo
reservar tempo quando fizer sentido. O usuário distingue parar um aviso de
marcar a tarefa como realizada. Paleta teal/mint/peach aprovada na revisão
anterior; manter identidade do calendário/check e títulos curtos nos materiais.

Claims apoiados no código/revisão atual: organização offline salva localmente,
sem conta no app; lembretes sem reserva; blocos com duração e proteção de
intervalos entre blocos; repetição diária/seg–sex/dias específicos; subtarefas;
atalho Lembrar em10minutos; filtro Só pendentes; progresso de conclusão;
widget Android existente. Áudio toca uma vez na configuração atual com patch
nativo ensaiado, mas depende de acessos/restrições Android. Não transformar
ensaio Android35 em garantia para todos os aparelhos.

Claims a evitar: IA que aprende rotina/durações; alarmes infalíveis ou nunca
perca um aviso; funcionamento garantido em Não Perturbe/force-stop/reboot;
conclusão automática ao silenciar; sincronização em nuvem/GoogleCalendar;
criptografia/segurança certificada; todos os recursos acessíveis em qualquer
escala/aparelho; acessibilidade certificada; publicação já aprovada; app líder
ou comparações de superioridade sem evidência.

Não afirmar dados nunca saem deste aparelho: manifest principal não define
explicitamente política de backup; isso deve ser reconciliado com release
mesclado e declaração de privacidade. Dados locais descreve arquitetura,
enquanto coleta/compartilhamento/backup precisa inventário próprio. Não prometer
grátis para sempre, sem custo ou sem assinatura vitalícia com base na franquia
Codex: preço/distribuição da loja são decisão separada não verificada aqui.

## Seis superfícies existentes selecionadas

Todas abertas diretamente por view_image em docs/ux/20261114-reminders/:
1. painel.png — Seu dia, no seu ritmo. Mostrar calendário, próxima ação e CTA.
2. lembrete.png — Lembretes sem reservar tempo. Mostrar opção de reserva
   desligada; manter introdução e exemplo Beber água presentes no app.
3. reservar-tempo.png — Reserve tempo quando precisar. Mostrar switch ligado
   e opções de duração, sem sugerir duração obrigatória.
4. dias-especificos.png — Repita nos dias que escolher. Mostrar seleção semanal
   real; não sugerir recorrência mensal/anual ou início/fim de série inexistentes.
5. opcoes-lembrete.png — Lembre de novo em10minutos. Mostrar o comando real,
   sem afirmar alteração da série inteira ou reagendamento inteligente por IA.
6. lista-silenciado.png — Pare o aviso. Conclua quando terminar. Mostrar estado
   pendente/silenciado e progresso; não confundir ciência com tarefa realizada.

Subtarefas é alternativa útil para sexto material se houver recaptura real da
superfície. O menu que abre subtarefas não demonstra por si uma checklist. Tela
de permissões é importante no roteiro interno, mas fraca como argumento de venda.

## Critérios visuais para avaliar os assets finais

Uma promessa por imagem; títulos curtos legíveis em miniatura; UI verdadeira e
com tamanho suficiente para leitura. Margens e enquadramento consistentes;
reusar tokens e ícone existentes. Não reconstruir interface fictícia para
encaixar layout de marketing. Composição pode usar moldura e títulos externos,
mas não fingir botão/estado/recurso dentro do app. Capturar no viewport adequado
é preferível a cortar ações relevantes de screenshot longa; preservar proporção
sem esticar. Não usar relógio recortado de tela rolada como se fosse falha do app.

Dados nas fotos devem ser sintéticos, sem nomes/contatos reais. Arquivar raw e
metadados de fixture, APK/commit e composição. Fonte de UI/gateway fake comprova
aparência, não entrega de alarme: ensaio nativo fica como evidência separada.
Validar dimensões/formato/políticas com documentação oficial atual, trabalho
em andamento pelo implementador; este parecer não certifica requisitos Play.

## Limites para o pacote de entrega

Preparar pasta/roteiro/textos/assets é autorizado. Upload, cobrança e chave de
assinatura não são parte desta revisão. APK/AAB debug ou unsigned de homologação
não é release pronto para distribuição; identificar esse limite expressamente
na documentação. Política de privacidade/DataSafety, titular/contato público,
classificação etária e permissões sensíveis precisam dados verificáveis do
responsável antes de publicação, sem inventar identidade/email/URL.

Nenhuma alteração de app ou repositório fitness feita. Aguardando imagens finais
para registrar aprovação ou achados concretos do material produzido.

## Revisão dos assets finais e textos —15/11/2026

Abri diretamente com view_image TODOS os arquivos em
PLAYSTORE/02_VISUAIS/ENVIAR_NO_CONSOLE:01 a06-telefone.png, destaque-1024x500.png
e icone-512.png. Peças aprovadas visualmente nesta revisão: paleta consistente,
títulos legíveis, hierarquia clara, molduras e margens regulares, UI real
reconhecível e sem controles ou funcionalidades inventados. A narrativa distingue
lembrete de reserva, dias escolhidos, adiamento isolado e silêncio sem conclusão.
Ícone calendário/check tem bom reconhecimento; destaque evita prêmios, rankings,
preço e promessas de resultado. Não é certificação de aceite da plataforma.

Também li os textos pt-BR da ficha, notas ao revisor, metadados e modelos de
resposta: benefícios compatíveis com fonte atual, ressalvas Android presentes,
sem promessa indevida de IA/sync/funcionamento garantido. A declaração de
armazenamento local inclui corretamente limite do backup Android. Responsável
e contato foram informados pelo implementador como provenientes de fonte pública
e reutilização autorizada pelo usuário; este revisor não consultou repositório
fitness nem refez essa verificação externa de identidade. URL de política
DayToDay permanece dado específico a hospedar, não reaproveitar política alheia.

### Ajuste material solicitado nos documentos

PRIVACIDADE.md e privacidade.html dizem que é possível excluir atividades pelas
funções do app. O contrato atual de Cancelar desativa atividade e preserva dados/
histórico no banco, não apaga individualmente a atividade. Solicitei trocar por
Você pode desativar atividades e remover subtarefas. Para apagar todos os dados
locais, use Limpar dados/desinstalar, mantendo ressalva dos backups do sistema.
Isso precisa ser corrigido antes de tratar a política como pronta; não demanda
mudar o app ou apagar dados. Não afirmar que mera desativação equivale a exclusão.

Ajustes menores opcionais: slide06 pode dizer A atividade fica pendente até você
marcar como concluída, em lugar de até você terminar, para não sugerir detecção
automática. Na descrição, Crie atividades únicas ou repita... é mais natural que
Repita uma vez. Nenhum outro bloqueio visual/claim concreto identificado nas
peças examinadas. Pendência material desta leitura é apenas precisão da política
sobre exclusão, além dos passos de release/plataforma já documentados.

Materiais foram avaliados localmente, sem publicação ou pagamento e sem editar
app. Aprovação visual não autoriza upload, chaves, cobranças ou afirmação de
release pronto. Dados de exemplo e screenshots de fixture comprovam apresentação;
prova de áudio nativo continua separada com seus próprios limites.

## Fechamento — assets e claims aprovados para o kit preparatório

Reabri06-telefone.png final: subtítulo agora diz A atividade fica pendente até
ser marcada como concluída. Continua legível, sem falso reconhecimento automático.
Conferi PRIVACIDADE.md e privacidade.html finais: ambos explicam desativar
atividades preservando histórico, remover subtarefas e apagar todos os dados
via armazenamento Android/desinstalação, com ressalva de backups. A afirmação
indevida de exclusão individual foi removida: achado material encerrado. Descrição
completa também usa Crie atividades únicas ou repita..., encerrando o ajuste
menor. Não há pendência visual/claim remanescente identificada nesta revisão.

Aprovo os oito materiais visuais e textos examinados para entrega como pasta de
preparação da Play Store. Não significa autorização técnica de upload, aceite
Play ou ausência de pendências operacionais. Política ainda precisa URL própria
e acesso no app; assinatura de upload não foi criada; permissões restritas e
questionários dependem da conta e revisão Console. Esses limites devem continuar
explícitos e não são solucionados por assets bonitos ou relatório de UX.

Implementador informa AAB/APK release unsigned de homologação, verificações de
ELF/zipalign16KB e instalação QA assinada exclusivamente debug fora do kit;
não reexecutei ou auditei essas etapas nesta revisão de assets. Não converter
checagem estática de alinhamento em runtime16KB validado, nem QA debug em release
assinado para distribuição. Revisor não publicou, não pagou, não criou chave,
não acessou repositório fitness e não editou app. Aprovação de material pronta
para o implementador consolidar documentação/PR conforme autorização do usuário.
