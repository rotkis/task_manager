# Task Manager

App Android para combater a procrastinação — tarefas com cronômetro/
contador, notificações e alarmes, gráfico de evolução, calendário,
recorrência de hábitos, backup, e widgets de tela inicial.

Feito em Flutter + Isar (`isar_community`), 100% local (sem login,
sem servidor).

## Funcionalidades

### Núcleo
- **Tarefas** de 4 tipos: genérica, pomodoro/estudo (cronômetro),
  exercício por tempo (ex: prancha) e por repetições (ex: flexão)
- **Notificações** simples e **alarmes** insistentes (para tarefas
  marcadas como importantes)
- **Calendário e cronograma** com reagendamento de data/horário
- **Gráfico de evolução** (linha) + streak de dias seguidos
- Temas **light** (branco amarelado `#FFF8E7`) e **dark** (roxo estilo
  Catppuccin Mocha, base `#1E1E2E`, destaque `#CBA6F7`)

### Extras
- **Tarefas recorrentes** (hábitos diários/semanais/por intervalo)
- **Subtarefas** (checklist dentro de uma tarefa)
- **Nudge de adiamento**: aviso ao adiar a mesma tarefa 3+ vezes,
  sugerindo quebrar em passos menores
- **Busca e filtro** por texto, tipo, status e tags
- **Categorias/tags** livres por tarefa
- **Backup e restauração** completos (exportar/importar arquivo JSON)
- **Ação "Concluir" direto na notificação**, sem abrir o app
- **Resumo semanal** automático (notificação)
- **Widgets de tela inicial**: mini-calendário mensal com indicadores
  de tarefa e navegação entre meses, e lista de tarefas do dia + streak

## Stack técnica

| Camada | Tecnologia |
|---|---|
| Framework | Flutter (SDK `>=3.4.0 <4.0.0`) |
| Banco local | `isar_community` (fork mantido do Isar v3) |
| Estado | `provider` (`ChangeNotifier`) |
| Notificações | `flutter_local_notifications` + `timezone` |
| Alarmes insistentes | pacote `alarm` (foreground service) |
| Gráfico | `fl_chart` |
| Calendário | `table_calendar` |
| Backup | `share_plus` + `file_picker` |
| Widget de tela inicial | `home_widget` + `AppWidgetProvider` nativo (Kotlin) |

## Pré-requisitos

- **Flutter SDK** (canal estável, versão compatível com `>=3.4.0`)
- **Android SDK cmdline-tools** (gerenciado via `sdkmanager` ou Android
  Studio)
- **JDK 17** (verifique com `java --version`)
- Um dispositivo Android ou emulador para testar (widgets nativos e
  notificações/alarmes exigem teste em aparelho real ou emulador)

O setup padrão do Flutter (`flutter doctor`) já cobre a maior parte
desses requisitos.

## Como rodar

```bash
# 1. Baixar dependências
flutter pub get

# 2. Gerar código do Isar (sempre que models/ mudarem)
dart run build_runner build --delete-conflicting-outputs

# 3. Rodar em modo debug
flutter run
```

### APK de release

Nota: o pacote `alarm` v5.5.0 declara `compileSdkVersion=34` mas
depende de `flutter_fgbg` que exige 35+. O `android/app/build.gradle.kts`
já força `compileSdk = 36` para resolver, mas se `flutter pub get`
for rodado novamente, execute o script de patch:

```bash
bash tools/fix_alarm_compile_sdk.sh
```

Depois:

```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Estrutura do projeto

```
lib/
  core/
    constants/         # cores, durações padrão, chaves de storage
    utils/             # formatação de data, parser de recorrência, codec de backup
  theme/               # temas light/dark (app_theme.dart)
  data/
    isar/              # inicialização do banco (isar_service.dart)
    models/            # TaskItem, SubTaskItem, ProgressLog
    repositories/      # CRUD e streams do Isar (task, progress, backup, share)
  features/
    tasks/             # controllers, telas, widgets (task_card, timer, rep_counter, form)
    calendar/          # controllers, telas, services (renderer PNG), widgets (schedule_list)
    stats/             # controllers, telas, widgets (line chart, streak badge)
    notifications/     # services (notification, alarm, weekly summary), widgets (settings sheet)
    widget/            # data service para widgets de tela inicial (WidgetDataService)
  main.dart

android/app/src/main/kotlin/com/rotkis/task_manager/
  TaskWidgetProvider.kt           # widget de tarefas do dia + streak
  CalendarWidgetProvider.kt       # widget de calendário mensal
  CalendarWidgetNavReceiver.kt    # navegação entre meses (◀ ▶)
  CalendarImageRenderer.kt       # renderização do PNG do calendário (Canvas Kotlin)
  MainActivity.kt                # entry point do Flutter

specs/                 # documentos de spec-driven development (ver abaixo)
tools/
  fix_alarm_compile_sdk.sh  # patch no cache do pub para o pacote alarm
```

## Desenvolvimento (spec-driven, com opencode)

Este projeto foi construído seguindo um fluxo de spec-driven
development, com os agentes do [opencode](https://opencode.ai)
implementando módulo por módulo:

- `specs/spec.md` / `specs/plan.md` / `specs/tasks.md` — spec
  original (módulos 1-5; o módulo 5 de compartilhamento foi removido
  depois — ver seção 5.7 do spec.md)
- `specs/spec_v2.md` / `specs/plan_v2.md` / `specs/tasks_v2.md` —
  extensão com as features de combate à procrastinação (módulos 6-14)

A configuração dos agentes está em `opencode.json` e `AGENTS.md` na
raiz do projeto.

## Testes

```bash
# Análise estática
flutter analyze

# Testes unitários e de widget
flutter test
```

Alguns fluxos não são cobertos por teste automatizado (exigem teste
manual no aparelho, documentado nos próprios arquivos de spec):
notificações/alarmes reais, ação de background na notificação, e os
widgets de tela inicial (nativos).

## Notas / particularidades conhecidas

- **MIUI/HyperOS (Xiaomi)**: notificações agendadas podem não disparar
  sem ativar manualmente "Início automático em segundo plano"
  (Configurações > Apps > Task Manager) e desativar restrições de
  bateria. O app tem uma tela de diagnóstico de permissões (ícone de
  sino na AppBar) com um botão de teste pra validar isso.
- **AGP (Android Gradle Plugin)**: fixado na versão **8.7.3** em
  `android/settings.gradle.kts`. O Flutter emite um aviso de que
  versões abaixo de 8.11.1 serão em breve abandonadas. Atualize com
  cautela, testando build de release depois da mudança.
- **compileSdk**: o `android/app/build.gradle.kts` força `compileSdk = 36`
  porque o pacote `alarm` (via `flutter_fgbg`) exige 35+. O script
  `tools/fix_alarm_compile_sdk.sh` faz o patch no cache do pub para
  que `flutter pub get` não reverta essa configuração.
- **RemoteViews (widgets nativos)**: só aceitam um conjunto limitado de
  views (`LinearLayout`, `TextView`, `ImageView`, `Button`,
  `FrameLayout`, etc). **Não usar `<View>` genérico** como divisor —
  a tag `View` pura causa `InflateException` no widget. Usar
  `LinearLayout` com `layout_height="1dp"` no lugar.
- **ProGuard / R8**: em release, o R8 mantém as classes dos widgets
  (`TaskWidgetProvider`, `CalendarWidgetProvider`,
  `CalendarWidgetNavReceiver`) desde que haja `-keep` explícito em
  `proguard-rules.pro`. As regras já estão configuradas.

## Licença

Projeto pessoal, sem licença definida.
