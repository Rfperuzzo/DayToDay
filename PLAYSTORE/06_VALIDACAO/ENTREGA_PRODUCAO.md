# Entrega atual — DayToDay 1.1.0+2 — 16/11/2026

Versão com avisos opcionais de início/final e fusão de troca. Fonte funcional e
limites descritos em docs/UX_INICIO_FIM_20261116.md, no repositório.
137 testes aprovados e análise limpa. Migrações1/2/3→4 preservam dados e preferências.
MONSTRUX implementou/revisou cadastro e edição e revisou a integração do motor.

## Conferências técnicas

AAB/APK de produção assinados com a MESMA chave exclusiva de upload; nenhum
certificado debug nem nova chave. Chave e backup continuam fora do repositório,
PLAYSTORE e ZIP. Certificado público acompanha a entrega. Bundletool1.18.3,
assinaturas, manifesto sem INTERNET/USE_EXACT_ALARM, ELF64 e zipalign16KB aprovados.
Versão1.1.0, código2, API36/mínimo24. Entrada de produção: lib/main.dart.

Ensaio nativo opt-in, em segundo plano, com banco em memória e repositórios reais:
start/transition/end/endonly PASS, todas as3atividades pendentes e ciência de final
persistida. Este ensaio não se confunde com tela de fixture nem com o APK enviado
à loja. Resultado em ENSAIO_NATIVO_INICIO_FIM.json.

A mesma instalação de produção foi atualizada no AVD sem apagar dados; uma rotina
sintética de15/11 continuou pendente, com progresso0/1. Ensaios visuais atuais e
suas capturas são descritos em JORNADA_PRODUCAO_INICIO_FIM.json quando concluídos.

## Limites

O AVD usa páginas4KB. Execução16KB, aparelhos físicos/OEM, áudio físico, boot,
force-stop, testes da conta e pré-lançamento continuam no checklist. Não houve
submissão à Play Store. O vídeo público1.0.0 é histórico e não comprova estas
novas opções. Política e práticas de dados não mudaram: processamento local.
Backup portátil da mesma chave já foi criado e verificado na sessão anterior;
não precisa gerar outra chave ou senha para esta versão.

## Conferência visual da versão de produção

A repetição completa de início/troca/final na UI de produção ficou inconclusiva
na retomada por ANR do SystemUI e capturas pretas do AVD. Não foi marcada como
aprovada. Os 137 testes e o ensaio nativo real de quatro avisos estão aprovados;
eles têm escopos distintos. Repetir a jornada visual em aparelho/AVD estável antes
da publicação em produção. Os prints03/07/08 são renders dos widgets reais para
apresentação, com dados sintéticos e origem documentada.
