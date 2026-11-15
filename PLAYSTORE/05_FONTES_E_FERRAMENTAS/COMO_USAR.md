# Ferramentas locais da entrega

A entrega já inclui o AAB PRODUCAO assinado. Não precisa compilar nem assinar
novamente para o primeiro envio. Binários são locais/no ZIP, ignorados pelo Git.

- Gerar-Producao.ps1: build offline com chave exclusiva protegida pelo Windows.
  Na mesma máquina/usuário, informe -ProjectRoot se o projeto estiver em outro local.
  -CriarPrimeiraChave é somente para a primeira criação; recusa sobrescrever a chave.
- Backup-Assinatura.ps1: exporta backup PKCS12 protegido por senha escolhida pelo
  titular, fora do projeto. Leia 04_BUILD/ASSINATURA_E_BACKUP.md.
- validar_kit.py: confere dimensões, textos, integridade e ausência de chaves privadas.
- Gerar-AAB-SemAssinatura.ps1 e Assinar-AAB.ps1: ferramentas alternativas de diagnóstico;
  não são necessárias para o AAB final entregue. O primeiro exige liberação explícita
  de build sem assinatura e nomeia seus arquivos como NÃO ENVIAR.
- arte/: fontes HTML/SVG dos oito materiais comerciais já renderizados.
- preparar_materiais.py: gerador histórico da primeira prévia, bloqueado após a
  consolidação da assinatura para não sobrescrever as declarações/política atuais.
  Edite a fonte específica se precisar alterar uma imagem ou documento.

Nenhuma ferramenta publica na loja, chama inferência, usa API paga ou contém uma senha.
Gradle release falha sem configuração de upload; nunca recai em certificado debug.
Para futuras versões atualize versão/código e revise nomes de artefatos dos scripts.
