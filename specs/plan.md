# Plan: Task Manager — decisões técnicas e arquitetura

Este documento resolve os itens da seção 7 da `spec.md` e define como o
código deve ser organizado, para que os agentes do opencode implementem
cada módulo de forma consistente.

## 1. Stack confirmada
| Camada | Escolha | Motivo |
|---|---|---|
| Banco local | `isar_community` (v3.3.2) | Fork ativo, API estável; `isar` original está descontinuado e o `isar` v4 novo ainda muda a API |
| Notificação simples | `flutter_local_notifications` + `timezone` | Padrão da comunidade, cobre lembretes agendados |
| Alarme "insistente" | `alarm` (gdelataillade) | Toca áudio em loop, vibra, controla volume, sobrevive a app fechado via foreground service — resolve o caso de tarefas marcadas como importantes |
| Gráfico | `fl_chart` | Suporta line chart nativamente, leve |
| Calendário | `table_calendar` | Padrão de mercado, indicador de eventos por dia |
| Gerenciamento de estado | `provider` (ChangeNotifier por feature) | Simples de aprender, baixo boilerplate, suficiente para o escopo do app |

## 2. Decisões da seção 7 da spec

### 2.1 Alarmes insistentes
Usar **dois mecanismos separados**:
- Tarefas normais → `flutter_local_notifications`, notificação única no
  horário agendado.
- Tarefas marcadas `isImportant = true` → pacote `alarm`, que toca som em
  loop e vibra até o usuário abrir/parar, funcionando mesmo com o app
  fechado (via foreground service no Android).
- Ambos os caminhos escrevem/lêem o `notificationId` (ou `alarmId`) na
  `TaskItem` pra permitir cancelar/reagendar ao editar/excluir.
- Nota: pedir a permissão de alarme exato (`SCHEDULE_EXACT_ALARM`, Android
  14+) explicitamente na primeira vez que o usuário criar uma tarefa com
  horário.

### 2.2 Formato do código de compartilhamento
Decisão: **payload auto-contido, sem servidor** (opção "a" da spec).
- Serializar a lista de tarefas selecionadas como JSON compacto (chaves
  curtas: `t`=title, `y`=type, `d`=dueDate relativo em dias, `h`=hora,
  `dur`=duração, `rep`=reps, `pts`=pontos).
- Codificar em Base64 URL-safe.
- Representar ao usuário como texto para copiar/colar (e, se der tempo,
  também como QR code usando `qr_flutter`, já que o payload é só texto).
- **Ajuste importante em relação à spec original**: um código de 6-8
  caracteres só é realista para 1 tarefa. Para múltiplas tarefas o código
  será mais longo (dezenas de caracteres) — isso é aceitável porque ele é
  copiado/colado ou lido via QR, não digitado manualmente.
- Datas são guardadas como **offset relativo** (ex: "amanhã", "daqui 3
  dias") em vez de data absoluta, pra fazer sentido quando importado em
  outro dia.
- Ao importar: cria novas `TaskItem` locais com `syncGroupCode` preenchido
  com um hash curto do payload original (só para agrupar visualmente),
  totalmente independentes da origem depois de importadas.

### 2.3 Isar
Confirmado `isar_community`. Rodar `build_runner` sempre que um `@collection`
mudar.

## 3. Arquitetura de pastas e camadas

```
lib/
  core/
    constants/          # cores, durações padrão, chaves de storage
    utils/               # formatação de data, geração/parse do código de share
  theme/
    app_theme.dart       # já criado no scaffold
  data/
    isar/
      isar_service.dart  # já criado no scaffold
    models/
      task_item.dart      # já criado
      progress_log.dart   # já criado
    repositories/
      task_repository.dart       # CRUD de TaskItem + streams do Isar
      progress_repository.dart   # leitura/escrita de ProgressLog
      share_repository.dart      # encode/decode do código, import/export
  features/
    tasks/
      controllers/task_controller.dart   # ChangeNotifier, usa task_repository
      screens/tasks_screen.dart
      widgets/ (task_card.dart, task_form.dart, timer_widget.dart, rep_counter_widget.dart)
    calendar/
      controllers/calendar_controller.dart
      screens/calendar_screen.dart
      widgets/schedule_list.dart
    stats/
      controllers/stats_controller.dart
      screens/stats_screen.dart
      widgets/progress_line_chart.dart, streak_badge.dart
    share/
      screens/share_screen.dart
      widgets/share_code_view.dart, import_code_form.dart
    notifications/
      notification_service.dart   # wrapper de flutter_local_notifications
      alarm_service.dart           # wrapper do pacote alarm
  main.dart
```

### Regras de camada
- **Widgets** (em `features/*/screens` e `widgets`) nunca acessam o Isar
  diretamente — só chamam métodos do **controller** da própria feature.
- **Controllers** (`ChangeNotifier`) chamam **repositories**, nunca o Isar
  cru.
- **Repositories** são o único lugar que importa `isar_community` e sabe o
  schema das coleções.
- `notification_service.dart` e `alarm_service.dart` são chamados pelo
  `task_controller` sempre que uma tarefa é criada/editada/excluída/concluída
  — nunca direto da UI.

## 4. Convenções para os agentes (opencode)
- Cada tarefa do `tasks.md` deve ser implementada em um branch/commit
  isolado, terminando com `flutter analyze` limpo e os testes daquele
  módulo passando antes de seguir pra próxima.
- Não pular a geração do Isar (`build_runner`) depois de mexer em
  `data/models/*`.
- Preferir editar arquivos existentes (patches pequenos) a reescrever
  arquivos inteiros, para manter o histórico legível e economizar tokens
  (ver seção sobre isso na conversa principal).
