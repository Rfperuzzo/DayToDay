"""Generate store documents and code-native artwork from verified app captures.
No API, image-generation service, network download or changes to the app.
"""
from pathlib import Path
import json,hashlib,shutil,html,subprocess

ROOT=Path(__file__).resolve().parents[2]
KIT=ROOT/'PLAYSTORE'
if (KIT/'04_BUILD/CERTIFICADO-PUBLICO-UPLOAD.pem').exists():
 raise SystemExit('Kit de producao consolidado: gerador historico bloqueado para nao sobrescrever politica, declaracoes e verificacoes atuais. Edite as fontes de arte e documentos especificos.')
DATE='15/11/2026'
def write(path,text):
 p=KIT/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text.strip()+'\n',encoding='utf-8')

write('01_TEXTOS/pt-BR/titulo.txt','DayToDay: rotina e lembretes')
write('01_TEXTOS/pt-BR/descricao-curta.txt','Organize sua rotina com lembretes, blocos de tempo e subtarefas. Tudo offline.')
write('01_TEXTOS/pt-BR/descricao-completa.txt','''Seu dia pode mudar. Sua organização pode acompanhar.

O DayToDay reúne lembretes e atividades em um painel diário simples, com calendário, progresso e próximas ações. Organize o que precisa fazer sem criar conta e com os dados salvos localmente.

LEMBRETES SEM COMPLICAR
Cadastre o que quer lembrar, escolha o horário e defina a repetição. Um lembrete simples não ocupa um intervalo da sua agenda.

RESERVE TEMPO QUANDO PRECISAR
Vai estudar ou se dedicar a uma tarefa? Ative a reserva de tempo e escolha a duração. Os blocos ajudam a evitar sobreposições; a duração não é o tempo de toque do alarme.

PARE O AVISO. CONCLUA QUANDO TERMINAR.
Parar o alarme mantém a atividade pendente. Marcar como concluída registra que você terminou. Também é possível adiar um lembrete em dez minutos, sem reorganizar as outras atividades.

UMA ROTINA DO SEU JEITO
Crie atividades únicas ou repita todos os dias, nos dias úteis ou nos dias da semana que escolher. Divida atividades em subtarefas e use o filtro de pendências para ver o que ainda falta.

ACOMPANHE O DIA
Veja o progresso, navegue pelo calendário e consulte as atividades pelo widget Android. Blocos de tempo seguem uma sequência; lembretes funcionam independentemente dela. Quando um bloco precisa ser adiado, o app procura outro intervalo na rotina.

OFFLINE E SEM CONTA
O app funciona sem cadastro, sem anúncios e sem depender de uma conta na nuvem. Sua organização fica salva no aparelho. Backup e transferência do Android dependem das configurações do sistema.

IMPORTANTE SOBRE OS AVISOS
Notificações, som, vibração e tela cheia dependem das permissões concedidas e das restrições do Android e do fabricante. A execução do som é independente da duração reservada. Revise os acessos de alarmes no app e teste os avisos no seu aparelho.

Suporte: thalesmelodasilva@gmail.com''')
write('01_TEXTOS/pt-BR/notas-versao.txt','''<pt-BR>
Bem-vindo ao DayToDay!
• Lembretes simples e reserva de tempo opcional.
• Parar o alarme separado de concluir a atividade.
• Repetição em dias específicos e subtarefas.
• Atalho para lembrar em 10 minutos e filtro de pendências.
• Painel diário, calendário e widget Android.
</pt-BR>''')
write('01_TEXTOS/DADOS_DA_FICHA.json',json.dumps({
 'app_name':'DayToDay: rotina e lembretes','language':'pt-BR','developer_public_name':'Thales Melo da Silva',
 'support_email':'thalesmelodasilva@gmail.com','support_source':'https://play.google.com/store/apps/details?id=br.com.projetomonstro.app&hl=pt_BR&gl=BR',
 'reuse_authorized_by_user':True,'package_name':'com.senhoritajhenifer.rotina','version_name':'1.0.0','version_code':1,
 'category_suggestion':'Produtividade','app_or_game':'App','ads':False,'accounts_required':False,
 'pricing':'Confirmar no Play Console; nenhum preco e prometido nos materiais',
 'privacy_policy_url':None,'support_website_url':None,'content_rating':'Atribuida pelo IARC apos questionario',
 'target_audience':'Responsavel deve selecionar os grupos etarios realmente pretendidos; nao declarar Families por padrao',
 'privacy_contact':'thalesmelodasilva@gmail.com','last_verified':'2026-11-15'},ensure_ascii=False,indent=2))
write('03_POLITICAS_E_DECLARACOES/PRIVACIDADE.md','''# Política de privacidade — DayToDay

Atualizada em 15 de novembro de 2026.

Responsável: Thales Melo da Silva. Contato: thalesmelodasilva@gmail.com.

O DayToDay organiza rotinas, lembretes e blocos de tempo no dispositivo Android.
Não exige conta. Na versão descrita, o aplicativo não envia seus dados de rotina
a um servidor do desenvolvedor, não tem anúncios e não inclui ferramentas de
publicidade ou análise de comportamento.

## Dados utilizados no aparelho

Títulos, observações, horários, repetições, duração dos blocos, prioridades,
subtarefas, confirmações e histórico são armazenados localmente para apresentar
e organizar suas atividades. O Android recebe as informações necessárias para
agendar e exibir alarmes, notificações e o widget.

## Permissões

Notificações apresentam os avisos. Os acessos de alarmes exatos, tela cheia e
Não Perturbe atendem aos recursos de alarme quando disponíveis e autorizados.
Vibração, manutenção temporária do processamento e serviço de reprodução de
áudio permitem executar o aviso. A permissão de inicialização permite tratar
alarmes após reinício, conforme as restrições do sistema. O app não solicita
câmera, microfone, contatos ou localização para organizar sua rotina.

## Compartilhamento e serviços do sistema

O desenvolvedor não recebe uma cópia da sua rotina por meio do aplicativo.
Backup, restauração e transferência oferecidos pelo Android ou pelo fabricante
podem incluir dados locais conforme a versão e suas configurações. Esses
recursos são gerenciados pelo sistema e pela conta do usuário, não por uma
conta DayToDay. Revise as configurações e políticas do serviço escolhido.

## Conservação e exclusão

Os dados ficam no aparelho enquanto você usa o app. Você pode desativar atividades,
preservando seu histórico, e remover subtarefas. Para apagar todos os dados locais do app, use
Configurações do Android > Aplicativos > DayToDay > Armazenamento > Limpar dados,
ou desinstale o aplicativo. Backups do sistema devem ser gerenciados nas opções
do próprio Android; uma restauração pode recuperar dados de um backup existente.

## Segurança e suas escolhas

Proteja o aparelho com bloqueio de tela e mantenha o sistema atualizado. Não
afirmamos que o banco local possui criptografia própria ou que alarmes são
garantidos em todas as condições. Você pode revisar permissões no Android e
acessos de alarmes no app. Ao entrar em contato por e-mail, o conteúdo enviado
será utilizado para responder ao pedido, segundo as políticas do provedor de
e-mail; não envie informações sensíveis desnecessárias.

## Alterações e contato

Esta política deve ser atualizada se novas funções mudarem o tratamento dos
dados. Para dúvidas sobre o DayToDay e privacidade, escreva para
thalesmelodasilva@gmail.com.
''')
privacy=(KIT/'03_POLITICAS_E_DECLARACOES/PRIVACIDADE.md').read_text(encoding='utf-8')
parts=[]
for para in privacy.split('\n\n'):
 if para.startswith('# '):parts.append('<h1>'+html.escape(para[2:])+'</h1>')
 elif para.startswith('## '):parts.append('<h2>'+html.escape(para[3:])+'</h2>')
 else:parts.append('<p>'+html.escape(para.replace('\n',' '))+'</p>')
write('03_POLITICAS_E_DECLARACOES/privacidade.html','''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Privacidade — DayToDay</title><style>body{font:18px/1.65 system-ui,sans-serif;background:#f6f8f5;color:#172f2b;max-width:820px;margin:auto;padding:48px 24px}h1{font-size:38px}h2{margin-top:38px}p{margin:18px 0}a{color:#145a52}</style><main>'''+''.join(parts)+'</main></html>')
write('03_POLITICAS_E_DECLARACOES/SEGURANCA_DOS_DADOS.md','''# Preenchimento de Segurança dos dados — proposta verificada em código

Base: eb4ce7a, Android, 1.0.0+1. Rever o AAB final e quaisquer alterações futuras.

O app usa dados da rotina localmente. Não foram encontrados backend próprio,
analytics, publicidade ou contas no código e dependências desta versão.
O manifest release deve ser conferido; INTERNET de um APK debug não representa
necessariamente a versão release. A coleta definida pelo Google se refere à
transmissão para fora do aparelho e inclui o comportamento de SDKs.

Proposta para o formulário: não coleta nem compartilha dados com o desenvolvedor
ou terceiros por meio de serviços do app. Processamento exclusivamente local não
deve ser marcado como coleta por si só. Revise separadamente o backup/transferência
do Android: o manifest não o desativa explicitamente. Não confundir isso com uma
promessa de que os dados jamais deixam o aparelho.

Não declarar criptografia própria do banco, testes de segurança independentes,
exclusão remota ou certificações não realizadas. Sem contas, o requisito de link
de exclusão de conta não descreve uma função existente; a exclusão local consta
na política. O formulário é responsabilidade do publicador e deve refletir o AAB
efetivamente enviado. Há política HTML pronta, mas a URL pública e o acesso dentro
do app ainda precisam ser concluídos antes de submeter.

Fonte: [Segurança dos dados](https://support.google.com/googleplay/android-developer/answer/10787469?hl=pt-BR).
''')
write('03_POLITICAS_E_DECLARACOES/PERMISSOES_E_REVISAO.md','''# Permissões e declarações do Play Console

Não enviar respostas automáticas como se fossem aprovação do Google.

## Alarmes exatos

O AAB declara USE_EXACT_ALARM. É uma permissão restrita, avaliada segundo a função
principal. O DayToDay apresenta organização de rotina com alarmes e calendário;
essa descrição não prova enquadramento como app dedicado de alarme/calendário.
Confirmar elegibilidade no Play Console antes da submissão. Se não se enquadrar,
será necessária uma mudança técnica de permissão/solicitação ou de agendamento;
o kit não altera o app silenciosamente para contornar a revisão.

Justificativa factual para adaptar: o usuário escolhe horários de atividades;
o sistema agenda avisos e o usuário pode parar, concluir, pular ou adiar. Não
inventar que a função principal é despertador se isso não representar o produto.

## Tela cheia e serviço em primeiro plano

USE_FULL_SCREEN_INTENT e FOREGROUND_SERVICE_MEDIA_PLAYBACK requerem as declarações
aplicáveis no Console. Explicar o aviso de alarme iniciado por um horário escolhido
e a reprodução visível para o usuário. O serviço encerra ao parar/finalizar o som;
isso não conclui a atividade. A concessão automática de tela cheia tem escopo
restrito; não prometer elegibilidade automática ou aprovação garantida.

Preparar demonstração real no aparelho/AAB de produção: criar aviso, conceder os
acessos necessários, aguardar disparo, mostrar a notificação/tela, parar e mostrar
que a atividade fica pendente. O arquivo ROTEIRO_VIDEO.md contém a sequência.
Se o Console exigir link de vídeo, o responsável deve gravar/publicar a demonstração
adequada e informar a URL. As capturas estáticas não substituem essa prova.

## Outros acessos

POST_NOTIFICATIONS: exibir avisos; RECEIVE_BOOT_COMPLETED: tratamento de retorno
após reinício; WAKE_LOCK/VIBRATE: execução do aviso; ACCESS_NOTIFICATION_POLICY:
integração com Não Perturbe quando autorizada. Manifest do app remove leitura de
armazenamento e SCHEDULE_EXACT_ALARM e fecha a exportação do AlarmReceiver.

Fontes: [Permissões](https://support.google.com/googleplay/android-developer/answer/16558241?hl=pt-BR)
e [serviços/tela cheia](https://support.google.com/googleplay/android-developer/answer/13392821?hl=pt-BR).
''')
write('03_POLITICAS_E_DECLARACOES/QUESTIONARIOS_CONSOLE.md','''# Respostas de conteúdo e acesso — revisar no Console

- App, categoria sugerida Produtividade, idioma pt-BR.
- Sem anúncios ou compras integradas no código atual; definir o preço na conta.
- Acesso às funcionalidades: não requer login nem credenciais. Alguns avisos
  dependem de permissões Android; informar isso nas instruções ao revisor.
- Classificação: preencher o IARC com conteúdo real. Não inventar classificação
  Livre, PEGI, ESRB ou aprovação antes do resultado do questionário.
- Público-alvo: responsável deve escolher as faixas realmente pretendidas. Não
  marcar público infantil/Families automaticamente porque a interface é simples.
- Não é rede social, jogo de apostas, app financeiro, de notícias, governamental,
  de saúde clínica ou rastreador de localização. Não transformar usos possíveis de
  uma observação pessoal em promessa médica.
- Confirmar a identidade/contatos da conta e direitos do nome/ícone. Nome público
  e suporte foram reaproveitados da ficha pública do Consistência por autorização.
- Se houver pergunta sobre código de terceiros, informar a biblioteca alarm local,
  com MIT preservada e demais dependências Flutter. Não declarar certificações.

Nenhum formulário foi enviado. Conferir as perguntas exatas disponíveis na conta.
''')
write('01_TEXTOS/COMENTARIOS_PARA_REVISAO.md','''# Notas ao revisor da Google Play

O DayToDay é um organizador de rotina offline e não exige conta ou login.
Não há credenciais para fornecer. O usuário pode criar um lembrete pela ação
Nova atividade, preencher o nome e escolher horário/repetição. Reservar tempo na
agenda é opcional e cria um bloco com duração.

O Android pode solicitar notificações e acessos de alarmes. A criação continua
salva se um acesso for negado. O botão Alarmes permite revisar os estados.
O som não é controlado pela duração do bloco. Parar alarme mantém a atividade
pendente; Concluir registra a realização. Lembrar em 10 minutos muda somente o
lembrete. Apenas blocos seguem o bloqueio sequencial; lembretes são independentes.

Passagem sugerida: criar lembrete; criar bloco em intervalo livre; escolher dias
específicos; adicionar subtarefas pelo menu da atividade; filtrar Só pendentes;
testar um aviso no aparelho com os acessos concedidos; verificar parada separada
da conclusão. O widget é adicionado pelo launcher Android.

As imagens da ficha usam dados de exemplo e interface real. Não apresentam
integrações, inteligência artificial, sincronização, idiomas ou planos inexistentes.
Contato do publicador: thalesmelodasilva@gmail.com.
''')
write('01_TEXTOS/RESPOSTAS_A_AVALIACOES.md','''# Modelos para responder avaliações reais

Estes são modelos de atendimento. Não são avaliações de usuários e não devem ser
publicados como depoimentos, notas ou comentários fictícios.

## Agradecimento
Obrigado por compartilhar sua experiência com o DayToDay. Que ele ajude a deixar
sua rotina mais clara. Se tiver uma sugestão, conte para nós pelo suporte.

## Aviso não tocou
Obrigado por avisar. Confira os estados em Alarmes e as permissões do Android.
As restrições de bateria e do fabricante também podem afetar avisos. Escreva para
thalesmelodasilva@gmail.com com modelo do aparelho, versão do Android e passos
para reproduzir, sem incluir informações pessoais da sua rotina.

## Sugestão
Obrigado pela sugestão. Vamos avaliar como ela se encaixa na organização da rotina.
Ainda não há prazo confirmado; não queremos prometer uma função antes de validá-la.

## Falha
Queremos entender o que aconteceu. Envie ao suporte a versão do app, o aparelho e
os passos que levaram à falha. Não envie senhas ou dados sensíveis desnecessários.
''')
write('02_VISUAIS/ROTEIRO_VIDEO.md','''# Roteiro de demonstração — gravação ainda não realizada

Vídeo promocional é opcional na ficha. Uma declaração de serviço/permissão pode
pedir demonstração específica; verificar o formulário da conta.

Gravar em aparelho de teste com dados sintéticos e a versão assinada a submeter.
Não mostrar e-mails, notificações pessoais ou opções internas de fixture.

1. 0–8s: painel e Nova atividade; explicar lembrete sem reserva.
2. 8–18s: ativar reserva e mostrar duração opcional; voltar ao modo lembrete.
3. 18–28s: selecionar dias específicos e salvar um horário próximo.
4. 28–45s: colocar o app em segundo plano e aguardar o aviso real.
5. 45–60s: parar o aviso, abrir o app e mostrar pendência; só depois concluir.

Para declaração de tela cheia/serviço, incluir permissões e o disparo real na
condição solicitada. Não usar uma tela de alarme da fixture como prova de entrega.
Não foi criado link YouTube nem enviado vídeo a qualquer serviço.
''')
write('04_BUILD/LEIA_ANTES_DE_ENVIAR.md','''# Binário — pendente de assinatura do responsável

O Gradle normal do app ainda usa signingConfigs.debug em release. Não enviar um
arquivo produzido por esse caminho como se estivesse pronto para a loja.

O script do kit usa um override temporário, fora das fontes do app, para gerar
AAB/APK release **sem assinatura** com target lib/main.dart. Os nomes contêm
SEM-ASSINATURA/NAO-ENVIAR. Não foram criadas chaves nem senhas. Esses arquivos
servem para inspeção técnica, não para upload ou instalação direta.

Para finalizar: o titular confirma Application ID e versionCode, usa sua chave
de upload correta fora do repositório e assina uma cópia pelo script Assinar-AAB.ps1.
O jarsigner solicita a senha no terminal; nunca cole a senha no chat ou na pasta.
Se esta ficha já existir, usar a chave compatível e um versionCode novo. Para um
app novo, configurar Play App Signing na conta. Não trocar o pacote sem decisão:
com.senhoritajhenifer.rotina é o ID atual e torna-se permanente na primeira ficha.

Depois: verificar certificado, validar o bundle, ensaiar via teste interno,
concluir permissões/privacidade e revisar o relatório de pré-lançamento.
Não existe publicação automática neste kit. Nenhum AAB está autorizado para envio
somente por estar nesta pasta. Ver 00_LEIA_PRIMEIRO.md e as pendências.
''')
write('05_FONTES_E_FERRAMENTAS/FONTES_OFICIAIS.md','''# Referências consultadas em 15/11/2026

- [Assets da ficha](https://support.google.com/googleplay/android-developer/answer/9866151?hl=pt-BR): ícone512² PNG32bits até1024KB; destaque1024x500 PNG24bits/JPEG; screenshots JPEG/PNG24bits,320–3840px, lado maior até2×menor. Kit fornece6 imagens1080x1920, sem alegar suporte tablet/TV/Wear.
- [Descrição](https://support.google.com/googleplay/android-developer/answer/13393723?hl=pt-BR): curta até80 caracteres, completa até4000; título até30 conforme criação da ficha. Sem depoimentos inventados ou alegações enganosas.
- [Criar app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=pt-BR): identidade, contato, app bundle e configuração da conta.
- [Preparar revisão](https://support.google.com/googleplay/android-developer/answer/9859455?hl=pt-BR): política pública e acesso dentro do app mesmo sem coleta; campos e declarações variam por produto/conta.
- [Segurança dos dados](https://support.google.com/googleplay/android-developer/answer/10787469?hl=pt-BR).
- [Permissões restritas](https://support.google.com/googleplay/android-developer/answer/16558241?hl=pt-BR).
- [Serviço/tela cheia](https://support.google.com/googleplay/android-developer/answer/13392821?hl=pt-BR).
- [Testes para contas pessoais novas](https://support.google.com/googleplay/android-developer/answer/14151465?hl=pt-BR): se aplicável à conta criada depois13/11/2023, ao menos12testadores por14dias consecutivos, antes de solicitar acesso à produção. Não aplica automaticamente a toda conta.
- [API alvo](https://support.google.com/googleplay/android-developer/answer/11926878?hl=pt-BR): conferir exigência vigente; app mira36.
- [Páginas16KB](https://developer.android.com/guide/practices/page-sizes): verificar bibliotecas nativas e APKs gerados do bundle; não confundir um build bem-sucedido com teste de execução16KB.
- [Construir/testar bundle](https://developer.android.com/guide/app-bundle/test).

Dados de contato reaproveitados da [ficha pública do Consistência](https://play.google.com/store/apps/details?id=br.com.projetomonstro.app&hl=pt_BR&gl=BR), lida por HTTP público após o leitor web falhar. Nome e e-mail foram verificados; nenhum repositório fitness foi aberto. A URL de privacidade daquele app não será usada como política do DayToDay.
''')

# Artwork is code-native composition of actual, unretouched app screenshots.
source=KIT/'05_FONTES_E_FERRAMENTAS/arte';source.mkdir(parents=True,exist_ok=True)
raw=KIT/'02_VISUAIS/originais';raw.mkdir(parents=True,exist_ok=True)
svg='<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><rect width="108" height="108" fill="#145A52"/><g fill="none" stroke="#F6F8F5" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><path d="M32 35H76V75H32Z M32 46H76 M43 30V38 M65 30V38 M44 60L51 67L65 54"/></g></svg>'
write('05_FONTES_E_FERRAMENTAS/arte/icone.svg',svg)
slides=[
 ('painel','Seu dia,<br>no seu ritmo.','Veja o que vem a seguir e acompanhe sua rotina.','#DCEFE6'),
 ('lembrete','Um lembrete.<br>Sem complicar.','Escolha o horário sem reservar um intervalo.','#F6F8F5'),
 ('reservar-tempo','Tempo reservado.<br>Quando precisar.','Ative a duração para organizar seus blocos.','#FFE7D6'),
 ('dias-especificos','Nos dias<br>que você escolher.','Personalize a repetição ao longo da semana.','#DCEFE6'),
 ('opcoes-lembrete','Daqui a<br>10 minutos.','Adie só o lembrete, sem mover suas outras atividades.','#F6F8F5'),
 ('lista-silenciado','Parar o aviso<br>não é concluir.','A atividade fica pendente até ser marcada como concluída.','#FFE7D6'),
]
for i,(name,title,sub,bg) in enumerate(slides,1):
 app_capture=ROOT/'docs/ux/20261114-reminders'/(name+'.png')
 if app_capture.exists():shutil.copy2(app_capture,raw/(name+'.png'))
 else:assert (raw/(name+'.png')).exists(),f'Missing real screenshot: {name}'
 page=f'''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><title>DayToDay — {name}</title><style>
 *{{box-sizing:border-box}}html,body{{margin:0;width:1080px;height:1920px;overflow:hidden}}body{{background:{bg};font-family:"Segoe UI",Arial,sans-serif;color:#172f2b}}.brand{{position:absolute;left:82px;top:50px;display:flex;gap:16px;align-items:center;font-weight:700;font-size:32px}}.brand img{{width:46px;height:46px;border-radius:10px}}h1{{position:absolute;left:80px;top:122px;margin:0;font-size:78px;line-height:1.08;letter-spacing:-2.5px;font-weight:750}}.sub{{position:absolute;left:84px;top:314px;width:912px;font-size:30px;line-height:1.3;margin:0;color:#4f6862}}.device{{position:absolute;top:428px;left:216px;width:648px;height:1440px;border:3px solid #145a52;border-radius:34px;overflow:hidden;background:#f6f8f5;box-shadow:0 18px 42px #145a5224}}.device img{{display:block;width:100%;height:100%}}.tick{{position:absolute;width:250px;height:250px;border:2px solid #145a5212;border-radius:55px;right:-95px;top:102px;transform:rotate(13deg)}}
 </style><div class="tick"></div><div class="brand"><img src="icone.svg">DayToDay</div><h1>{title}</h1><p class="sub">{html.escape(sub)}</p><div class="device"><img src="../../02_VISUAIS/originais/{name}.png"></div></html>'''
 write(f'05_FONTES_E_FERRAMENTAS/arte/telefone-{i:02d}.html',page)
write('05_FONTES_E_FERRAMENTAS/arte/destaque.html','''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><style>*{box-sizing:border-box}html,body{margin:0;width:1024px;height:500px;overflow:hidden}body{background:#DCEFE6;color:#172F2B;font-family:"Segoe UI",Arial,sans-serif}.icon{position:absolute;left:70px;top:140px;width:210px;height:210px;border-radius:40px}h1{position:absolute;left:330px;top:70px;font-size:48px;letter-spacing:-1px;margin:0;font-weight:750}h2{position:absolute;left:330px;top:148px;font-size:56px;line-height:1.08;letter-spacing:-1.6px;margin:0}p{position:absolute;left:332px;top:302px;font-size:24px;color:#4F6862;margin:0}.line{position:absolute;bottom:64px;left:330px;width:590px;height:5px;background:#A74F32;border-radius:3px}</style><img class="icon" src="icone.svg"><h1>DayToDay</h1><h2>Seu dia,<br>no seu ritmo.</h2><p>Lembretes e rotina, com clareza.</p><div class="line"></div></html>''')
print('Documents and artwork sources prepared; screenshots remain real app captures.')

if __name__=='__main__' and '--render' in __import__('sys').argv:
 from playwright.sync_api import sync_playwright
 import base64
 images=KIT/'02_VISUAIS/ENVIAR_NO_CONSOLE';images.mkdir(parents=True,exist_ok=True)
 with sync_playwright() as p:
  browser=p.chromium.launch(headless=True,executable_path='C:/Program Files/Google/Chrome/Application/chrome.exe')
  page=browser.new_page(viewport={'width':1080,'height':1920},device_scale_factor=1)
  for i in range(1,7):
   page.goto((source/f'telefone-{i:02d}.html').as_uri());page.evaluate('document.fonts.ready');page.locator('.device img').evaluate('(im)=>im.decode()')
   page.screenshot(path=str(images/f'{i:02d}-telefone.png'),type='png')
  page.set_viewport_size({'width':1024,'height':500});page.goto((source/'destaque.html').as_uri());page.locator('img').evaluate('(im)=>im.decode()')
  page.screenshot(path=str(images/'destaque-1024x500.png'),type='png')
  svg_url='data:image/svg+xml;base64,'+base64.b64encode((source/'icone.svg').read_bytes()).decode()
  uri=page.evaluate('''async(src)=>{let i=new Image();i.src=src;await i.decode();let c=document.createElement('canvas');c.width=c.height=512;c.getContext('2d').drawImage(i,0,0,512,512);return c.toDataURL('image/png')}''',svg_url)
  (images/'icone-512.png').write_bytes(base64.b64decode(uri.split(',')[1]))
  browser.close()
 print('Rendered6 store screenshots + feature graphic + icon, locally.')
