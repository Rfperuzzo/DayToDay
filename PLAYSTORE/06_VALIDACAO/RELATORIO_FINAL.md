# Registro histórico da primeira preparação

Este relatório antecede a assinatura e a política pública. Para o estado atual,
leia ENTREGA_PRODUCAO.md nesta pasta e VERIFICACAO_TECNICA.json.

# Conferência final do kit —15/11/2026

App1.0.0+1, pacote com.senhoritajhenifer.rotina, fonte eb4ce7a.

- 102 testes aprovados; flutter analyze sem issues. Repetidos nesta preparação.
- 8 assets aprovados pelo MONSTRUX:6 telefones1080x1920RGB, destaque1024x500RGB,
 ícone512RGBA. Título28, descrição curta78, completa1827 caracteres.
- Texto alternativo de cada screenshot incluído; todas as imagens usam UI real
 e exemplos sintéticos. Não são ensaios de entrega de alarme.
- Política própria corrigida: atividade é desativada, não excluída individualmente.
- Publicador/contato obtidos na ficha pública do Consistência por autorização;
 repositório fitness não foi aberto ou alterado.
- AAB e APK release sem assinatura compilados com override temporário e sem
 modificar fontes/configuração persistente do app. SDK36/mínimo24.
- Manifest release sem INTERNET; AlarmReceiver exported=false. Isso não é prova
 universal de privacidade: declarações incluem SDKs e condições de backup.
- AAB sem entradas de assinatura; APK validado pelo zipalign16KB; ELF64 com
 segmentos LOAD alinhados para16KB. Execução em16KB ainda não foi testada.
- APK release de QA assinado apenas com chave Android Debug existente, fora do
 kit, instalado no AVD DayToDayMonstrux35/5554; painel abriu sem falha fatal.
 A memória do AVD é4KB; isso não certifica16KB nem aparelho real/OEM.
- Scripts PowerShell analisados sem erro de sintaxe. Guard de assinatura recusou
 chave dentro do kit. Nenhuma chave de produção foi criada/lida/copiada.

Os artefatos SDK faltantes foram obtidos gratuitamente na versão já instalada;
nenhuma compra, API de inferência, crédito ou novo provedor foi usado. Os arquivos
sem assinatura estão deliberadamente identificados para não serem enviados.

Pendências reais: chave de upload e certificado, política pública e acesso
no app, elegibilidade/declarações de permissões, formulários da conta e ensaios
físicos/pré-lançamento. O kit não declara publicação ou aprovação da loja.

Ver CHECKLIST_PUBLICACAO.md, FONTES_OFICIAIS.md e VERIFICACAO_TECNICA.json.
