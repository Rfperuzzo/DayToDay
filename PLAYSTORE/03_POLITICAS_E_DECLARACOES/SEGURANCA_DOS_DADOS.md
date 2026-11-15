# Preenchimento de Segurança dos dados — proposta verificada em código

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
