# Segurança dos dados — preenchimento da versão 1.1.0+2

URL da política: https://rfperuzzo.github.io/DayToDay/privacidade.html
O app oferece a mesma política offline em Privacidade e suporte.

- O app coleta ou compartilha os tipos de dados exigidos pelo formulário? **Não.**
  A rotina e o histórico são processados localmente; não há backend, contas,
  anúncios, analytics ou permissão INTERNET no binário release final.
- Criação de conta: **o app não permite criar contas**. Nenhum método de login.
- Link de exclusão de conta: **não aplicável**, não criar URL de exclusão fictícia.
- Tipos de dados coletados/compartilhados: **nenhum pelo app**. Não marcar títulos,
  horários e notas locais como coleta apenas por existirem no banco do aparelho.
- Análise independente de segurança, MASA ou certificações: **não declarar**.
- Criptografia em trânsito: não inventar tráfego criptografado de rotina. Se o
  formulário dispensar a pergunta ao marcar não coleta, seguir essa ramificação.
  Não declarar criptografia própria do banco local, que não foi implementada.

O Android pode incluir dados em backup/transferência conforme configurações do
usuário; o app não controla um serviço próprio de nuvem. A política explica isso.
Ao abrir o site, o navegador/GitHub Pages pode tratar metadados da visita; ao
contatar suporte, o usuário envia voluntariamente e-mail fora do app. Não há
transmissão de rotina pelo app para esses serviços. Se o titular integrar outro
SDK ou ativar coleta por fora desta versão, revisar o formulário antes do envio.

Fonte: https://support.google.com/googleplay/android-developer/answer/10787469?hl=pt-BR
