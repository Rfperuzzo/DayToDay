# Assinatura exclusiva do DayToDay

O usuário confirmou que o app nunca foi enviado e não tinha chave. Foi criada
uma primeira chave de **upload**, RSA 3072, alias `daytoday-upload`, validade de
10.000 dias. O certificado público acompanha a entrega; ele não permite assinar.
O AAB PRODUCAO foi assinado e verificado com essa chave, nunca com Android Debug.

A chave privada fica em `%USERPROFILE%/.codex/signing/daytoday/daytoday-upload.jks`.
A senha aleatória fica protegida pelo Windows/usuário atual em
`upload.password.dpapi`, na mesma pasta privada com acesso restrito ao titular e
SYSTEM. Nada disso está no Git, PLAYSTORE ou ZIP. Não envie esses arquivos a
terceiros, não use ferramentas online para assinatura e não compartilhe senha.

## Antes de perder acesso a este Windows

Execute `Backup-Assinatura.ps1 -Destino <caminho privado fora do projeto>/daytoday-upload-backup.p12`.
O script pede uma senha nova (16+ caracteres) no terminal e exporta um backup
PKCS12 protegido, sem gravar senha em texto. Guarde duas cópias privadas em locais
independentes e a senha no seu gerenciador de senhas. A senha DPAPI original
sozinha não serve para restauração em outro Windows. Não apague a chave original.
O backup portátil depende de uma senha escolhida pelo titular; não foi executado
automaticamente nem foi inventada uma senha para você memorizar.

## No primeiro envio

Aceite/configure o Play App Signing e permita ao Google gerar/gerenciar a chave
de assinatura distribuída, se essa for a opção oferecida. Envie o AAB PRODUCAO.
A chave local é de upload; a chave de distribuição gerenciada pelo Google pode
ter outro certificado. O certificado público exportado só precisa ser fornecido
se o fluxo do Console pedir; a chave privada não precisa ser enviada.

Para builds futuros na mesma máquina: `Gerar-Producao.ps1 -ProjectRoot <projeto>`.
Nunca usar `-CriarPrimeiraChave` de novo para esse pacote. Em outra máquina,
restaure/use o backup correto; não gere outra chave para uma atualização.
