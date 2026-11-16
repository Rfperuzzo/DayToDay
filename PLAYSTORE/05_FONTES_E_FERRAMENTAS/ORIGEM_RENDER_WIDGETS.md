# Renderizações de widgets reais — somente apresentação

Origem: presentation_render_test.dart no diretório superior. Execução local por
Flutter WidgetTester, sem AVD/ADB, banco de produção ou plugin de alarme.

- 03-configurar-widget.png: NewActivitySheet real, início09:30/final10:00,
  duração30min, avisos de início/final ligados, posição rolada para configuração.
- 05-troca-widget.png: AlarmRingingScreen real com AlarmPhase.transition.
- 06-final-widget.png: AlarmRingingScreen real com AlarmPhase.end.

Todos1080x2400,360x800 lógico,pixelRatio3,ptBR,tema claro,fator de texto1.
Roboto regular/medium/bold/black e MaterialIcons carregados do cache instalado
Flutter; Segoe UI Symbol local como fallback para seta. No harness somente,
fontFamilyRoboto foi explicitada no FilledButton e fallback no TextTheme para
impedir a fonte de teste Ahem; conteúdo, tamanhos e pesos dos widgets preservados.
Nenhum arquivo do aplicativo/teste versionado foi alterado nesta tarefa.

Dados sintéticos; título/corpo de transição fornecidos ao widget como modelo,
sem agendamento real. Ações do alarme são callbacks vazios; formulário nunca
persiste nem solicita permissões. Não apresentar como prova de disparo sonoro,
notificação, troca real em Android, foreground/background ou aparelho físico.
Não há barras do sistema operacional nem navegador na imagem. Relógio do alarme
usa TimeOfDay.now real; relógio do formulário fixo para o exemplo comercial.

origin.json registra hashes dos PNGs, fontes de código e condições. Log final
no diretório superior: presentation-render.log (1 teste render PASS). Primeiro
ensaio de fonte foi descartado; arquivos finais foram regenerados e inspecionados
visualmente, incluindo botão e seta legíveis. Arquivos são renders de interface
real para apresentação, não mockups redesenhados nem captura de produção.

As imagens longas são fontes para composição; o responsável prepara os formatos
finais da ficha e confere regras da loja. Não substituir evidência Android por
este conjunto. Nenhuma publicação/pagamento/API externa foi usada.
