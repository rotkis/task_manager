# Task Manager — instruções para o agente

Este é um app Flutter + Isar (`isar_community`) para combater procrastinação.
Sem login. Banco 100% local no dispositivo.

## Antes de codar
Leia (se ainda não leu nesta sessão):
- `specs/spec.md` — o que o app faz, por módulo
- `specs/plan.md` — decisões técnicas e arquitetura de pastas/camadas
- `specs/tasks.md` — lista de tarefas por módulo, com critério de aceite

Carregue esses arquivos sob demanda (lazy loading), não precisa recarregar
tudo se já leu nesta sessão.

## Regras inegociáveis de arquitetura
- Widget nunca acessa o Isar direto. Sempre: widget → controller
  (`ChangeNotifier`) → repository → Isar.
- Só arquivos em `lib/data/repositories/` importam `isar_community`.
- `notification_service.dart` e `alarm_service.dart` só são chamados pelo
  `task_controller`, nunca direto da UI.

## Definição de "pronto" para qualquer tarefa
1. `dart format .`
2. `flutter analyze` — zero erros/warnings novos
3. `flutter test` — testes do módulo passando
Se qualquer passo falhar, leia o erro, corrija, rode de novo. Repita até
passar limpo antes de reportar a tarefa como concluída.

## Estilo de edição
- Prefira editar trechos específicos de arquivos existentes a reescrever o
  arquivo inteiro.
- Não leia arquivos gerados (`*.g.dart`, `build/`, `.dart_tool/`) a menos
  que precise depurar um erro de geração do Isar.
- Um módulo do `tasks.md` por vez. Não comece o próximo módulo sem o
  anterior passar em format/analyze/test.

## Known issues

### `alarm` v5.5.0 — compileSdkVersion incompatível

O pacote `alarm` declara `compileSdkVersion=34` mas depende de `flutter_fgbg`
que exige 35+. O build falha com:

```
Dependency ':flutter_fgbg' requires libraries and applications that
depend on it to compile against version 35 or later of the Android APIs.
```

**Solução**: Executar `bash tools/fix_alarm_compile_sdk.sh` depois de
`flutter pub get`. O script faz o patch no cache do pub.

## Fora de escopo (não implementar sem pedido explícito)
- Login / conta de usuário / servidor de sync contínuo.
- Suporte a iOS/desktop na v1.
