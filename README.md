# Rotina da Jhenifer

Aplicativo Android offline para organizar atividades e disparar alarmes fortes,
com reagendamento inteligente quando Jhenifer escolhe **Agora não**.

Esta etapa contém somente a fundação técnica. Nenhum layout de produto foi
criado.

## Contexto do projeto

Leia [DOCUMENTOS.md](DOCUMENTOS.md) antes de alterar código. Esse arquivo é a
memória viva das decisões, regras de negócio e próximos passos.

## Comandos

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

> Neste ambiente Codex, os metadados Git estão em `.gitdata` porque a pasta
> `.git` é protegida pelo sandbox. Use
> `git --git-dir=.gitdata --work-tree=. <comando>` enquanto essa proteção
> estiver ativa.
