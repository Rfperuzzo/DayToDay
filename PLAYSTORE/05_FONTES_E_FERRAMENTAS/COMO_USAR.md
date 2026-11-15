# Reproduzir e conferir os materiais

Os PNGs e textos já estão preparados; as ferramentas abaixo são opcionais.

## Conferir sem instalar pacotes

Na raiz do projeto: `python -B PLAYSTORE/05_FONTES_E_FERRAMENTAS/validar_kit.py`.
O validador usa só a biblioteca padrão do Python e verifica dimensões, formato,
textos, alt text e ausência de chaves na pasta. PASS do kit não significa liberação
para upload: readyToPublish permanece false enquanto faltarem as etapas do titular.

## Recriar as artes

Executar `preparar_materiais.py --render` com Python e Playwright locais e Google
Chrome instalado. O ambiente de preparação já possuía essas ferramentas; nenhum
gerador de imagens ou serviço pago foi usado. São HTML/CSS/SVG locais com as
capturas reais incluídas em 02_VISUAIS/originais, sem retocar a interface do app.
Os fontes usam Segoe UI/Arial; fontes não são redistribuídas. Em outro sistema,
uma fonte substituta pode mudar a composição: renderizar e revisar novamente.
O script reescreve os textos gerados; ajuste o fonte antes de regenerar.

## Build release

Na pasta do projeto, execute Gerar-AAB-SemAssinatura.ps1. Fora do projeto,
informe -ProjectRoot. O padrão é offline; se faltar um artefato público do SDK,
o parâmetro -PermitirDownloadDeDependencias permite obtê-lo dos repositórios de
build configurados. Isso não muda versões nem usa modelos/API pagos.

O script usa o JDK do Android Studio quando disponível e restaura JAVA_HOME.
O override de assinatura é só dessa execução: não altera build.gradle.kts nem
cria uma chave. Não rode uma versão normal com debug signing e a chame de produção.

## Chave e assinatura do titular

Use a chave de upload correta da conta/ficha. Se for necessário criar uma chave,
faça isso no Android Studio (Build > Generate Signed Bundle/APK), escolhendo
armazenamento privado fora do repositório; registre o backup seguro e as credenciais.
Não foi criada ou copiada nenhuma chave real neste trabalho.

Para assinar a cópia sem assinatura, execute Assinar-AAB.ps1 -KeyStore com o
caminho privado e -Alias com o alias correto. A senha é solicitada pelo jarsigner
no terminal. Não deve constar de argumentos, arquivos do kit ou mensagens.
O script verifica a assinatura e rejeita certificado Android Debug. Certificado
de upload e configuração Play App Signing devem ser conferidos pelo titular.

Arquivos assinados ainda exigem o checklist de publicação, ensaio via faixa
interna e revisão do Console. Nenhum script faz upload, compra ou publicação.
