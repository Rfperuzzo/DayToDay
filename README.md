# Rotina da Andriele

Aplicativo Android offline para organizar atividades e disparar alarmes fortes,
com reagendamento inteligente ao escolher **Agora não** ou perder a janela de
uma tarefa sem confirmação.

O MVP já possui painel diário responsivo, conclusão antecipada, subtarefas,
controle de duração, sequência diária e cadastro de atividades únicas ou
recorrentes com preparação contextual dos alarmes. A fila se reorganiza por
importância sem criar sobreposições, e um widget Android mostra as tarefas do
dia na tela inicial. A ilustração da Andriele é usada como ícone oficial em
formatos Android legado, redondo e adaptativo. O calendário horizontal percorre
todos os dias dos meses e mostra a rotina da data selecionada.

## Contexto do projeto

Leia [DOCUMENTOS.md](DOCUMENTOS.md) antes de alterar código. Esse arquivo é a
memória viva das decisões, regras de negócio e próximos passos. A direção de
interface está em [docs/REFERENCIA_VISUAL.md](docs/REFERENCIA_VISUAL.md) e as
ideias priorizadas em [docs/ROADMAP_PRODUTO.md](docs/ROADMAP_PRODUTO.md).
Os resultados da rodada real no Motorola estão em
[docs/VALIDACAO_DISPOSITIVO.md](docs/VALIDACAO_DISPOSITIVO.md).
O instalador portátil para testes em outros celulares está documentado em
[docs/INSTALADOR_DEBUG.md](docs/INSTALADOR_DEBUG.md).
As instruções do widget Android estão em
[docs/WIDGET_TELA_INICIAL.md](docs/WIDGET_TELA_INICIAL.md).
O comportamento do calendário está em
[docs/CALENDARIO_MENSAL.md](docs/CALENDARIO_MENSAL.md).

## Comandos

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
powershell -ExecutionPolicy Bypass -File scripts/package_debug_installer.ps1
```

> Neste ambiente Codex, os metadados Git estão em `.gitdata` porque a pasta
> `.git` é protegida pelo sandbox. Use
> `git --git-dir=.gitdata --work-tree=. <comando>` enquanto essa proteção
> estiver ativa.
