# PLAYSTORE — DayToDay, entrega para envio

Atualizado em **15/11/2026**. Abra **00_ABRIR_AQUI.html** e siga
**PASSO_A_PASSO_PLAY_CONSOLE.md**. O app não foi enviado nem publicado na loja.

## Pronto nesta entrega

- **04_BUILD/DayToDay-1.0.0-1-PRODUCAO.aab:** pacote assinado para o campo App Bundle.
- **04_BUILD/DayToDay-1.0.0-1-PRODUCAO-TESTE.apk:** somente instalação de teste.
- **01_TEXTOS/pt-BR:** nome, descrições e notas; contato e ficha preenchidos no JSON.
- **02_VISUAIS/ENVIAR_NO_CONSOLE:** seis screenshots de telefone, ícone e destaque
  nas dimensões da loja; ordem e textos alternativos acompanham a pasta.
- **03_POLITICAS_E_DECLARACOES:** política própria pública, Segurança dos dados,
  questionários e textos de permissões para copiar.
- **02_VISUAIS/DEMONSTRACAO-ALARME.mp4:** demonstração real da versão assinada;
  o guia de vídeo informa sua URL pública e limites do ensaio.
- **04_BUILD/ASSINATURA_E_BACKUP.md:** guarda da chave e backup. Chave privada e senha
  nunca entram nesta pasta, ZIP ou GitHub. Só o certificado público acompanha o kit.
- **06_VALIDACAO:** resultados e limites. 107 testes aprovados e análise sem problemas.

Política pública: https://rfperuzzo.github.io/DayToDay/privacidade.html
Acesso no app: final do painel > Privacidade e suporte. O texto funciona offline.
O binário usa SCHEDULE_EXACT_ALARM concedida pelo usuário; a permissão restrita
USE_EXACT_ALARM foi removida. Release não usa certificado debug.

Confirmado pelo titular: primeira publicação, gratuito, Brasil, público-alvo a
partir de 13 anos, sem direcionamento infantil. O Google calcula a classificação.
Não houve cobrança, uso de API paga ou acesso ao repositório fitness.

## O que só acontece no Play Console

Criar a ficha na sua conta, aceitar/configurar Play App Signing, copiar os campos,
enviar o AAB, executar a faixa interna/pré-lançamento, cumprir eventual teste
fechado exigido pela conta e enviar para revisão. Aprovação e prazos são do Google.
Os checkboxes desses atos ficam desmarcados porque não foram executados.

O teste local ocorreu em emulador Android 15 de 4 KB. Alinhamento de 16 KB foi
verificado estaticamente, não houve ensaio em sistema 16 KB nem aparelhos físicos.
Esses limites não são ocultados por uma declaração de aprovação universal.
