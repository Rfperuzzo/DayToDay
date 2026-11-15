# Referências consultadas em 15/11/2026

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

- [Ferramenta oficial bundletool](https://developer.android.com/tools/bundletool): validação local do AAB e geração de APKs. Utilizada a versão1.18.3 do repositório google/bundletool, com digest do release conferido.
- [Alarmes exatos Android14](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms): SCHEDULE_EXACT_ALARM exige concessão e revalidação do estado.
