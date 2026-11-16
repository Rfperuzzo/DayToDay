# Entrega de produção preparada — 15/11/2026

Fonte do app: commit cde6b59. Pacote com.senhoritajhenifer.rotina, versão 1.0.0+1.
O usuário confirmou primeira publicação sem chave anterior e escolhas: gratuito,
Brasil, público 13+, sem direcionamento infantil. Não houve envio ao Play Console.

## Concluído

- Política pública própria em HTTPS, sem login, e mesma política offline no app.
  Abertura do navegador externo por ação explícita; URL fixa, sem dados de rotina.
- Primeira chave exclusiva de upload RSA3072, protegida fora do repositório/ZIP.
  Certificado público exportado e correspondente às assinaturas AAB e APK.
- Release deixa de usar certificado debug e recusa build sem chave, salvo opção
  explícita de diagnóstico sem assinatura. Bloqueio negativo executado e aprovado.
- SCHEDULE_EXACT_ALARM concedida pelo usuário; USE_EXACT_ALARM removida do manifesto
  final. Pedido de um acesso especial por vez. Reconciliação ao fechar revisão.
- JAR/AAB e APK com assinaturas verificadas; bundletool oficial 1.18.3 validate
  aprovado. ZIP íntegro, manifesto e asset final conferidos, ELF64 e zipalign16KB PASS.
- 107 testes aprovados; análise Flutter sem problemas. Sem migração de banco,
  exclusão de rotinas ou alteração no repositório fitness.
- Instalação limpa no emulador dedicado Android15, usando a mesma chave de upload.
  Permissão exata negada → retorno negado; concedida → retorno liberado observados.
- Lembrete criado na UI assinada para 15:32 do aparelho, disparado em segundo plano;
  serviço observado isForeground=true, notificação real com controle de parada.
  Parar no app mostrou Aviso silenciado; ao retornar, progresso 0 de 1 concluídas.
- Gravação real de 408s, sem edição/áudio, publicada em URL pública junto da política.
  Conteúdo do MP4 e da política conferidos por SHA256 contra os arquivos locais.
- Logs do processo do app sem FATAL EXCEPTION nesta sessão de ensaio.
- Revisão visual/factual MONSTRUX encerrada sem novos problemas no escopo examinado.

## Limites e atos do titular

O vídeo não valida som físico, todas as ações da notificação, comportamento sob
bloqueio, concessão automática de tela cheia ou diferenças de OEM. O Android do
ensaio usa páginas 4KB; a checagem de 16KB é estática, não um teste em sistema16KB.
Pré-lançamento, testes físicos, eventual teste fechado, classificação IARC e
aceite de formulários são feitos na conta Play conforme o checklist. Não afirmar
aprovação da loja com base em testes locais. O certificado autoassinado de upload
não precisa de autoridade certificadora ou serviço pago de timestamp; a verificação
Java informa esses avisos normais de certificado próprio, sem inconsistência JAR.

Guarda da chave e backup portátil dependem de senha privada escolhida pelo titular;
o script de exportação está pronto, mas o backup com senha pessoal não foi feito
em seu nome. Preserve a pasta privada e faça o backup antes de perder o Windows.

Nenhuma API paga, taxa de conta ou submissão de loja foi acionada. Hospedagem pública
usa apenas o GitHub Pages do DayToDay. Não foi aberto nem alterado o fitness.
