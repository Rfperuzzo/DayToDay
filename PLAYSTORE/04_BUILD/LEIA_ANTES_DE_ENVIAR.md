# Binário — pendente de assinatura do responsável

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
