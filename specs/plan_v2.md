# Plan v2 — decisões técnicas dos módulos 6-14

## Novas dependências
| Pacote | Para o quê |
|---|---|
| `share_plus` | Compartilhar o arquivo de backup (Módulo 9) |
| `file_picker` | Selecionar arquivo de backup pra importar (Módulo 9) |
| `home_widget` | Widget de tela inicial (Módulo 12) |

## Módulo 6 — Recorrência
- Novo campo em `TaskItem`: `recurrenceRule` (String? — formato simples
  tipo `"daily"`, `"weekly:MON,WED,FRI"`, `"every:3"` dias).
- Novo campo `parentRecurringId` (Id? — aponta pra "tarefa modelo" de
  onde a instância foi gerada; null se a tarefa não é recorrente).
- Geração de instâncias: ao abrir o app (ou uma vez por dia), o
  `task_repository` verifica todas as tarefas com `recurrenceRule` e
  garante que existem instâncias concretas pros próximos 30 dias,
  criando as que faltarem.
- Editar "só esta ocorrência" edita a instância normalmente. Editar
  "esta e as futuras" atualiza a tarefa-modelo e regenera as instâncias
  futuras (mantém as passadas intactas).

## Módulo 7 — Subtarefas
- Nova collection Isar `SubTaskItem`: `id`, `parentTaskId` (Id),
  `title`, `isCompleted`, `order` (int, pra ordenação manual).
- `task_repository` ganha métodos `watchSubtasks(taskId)`,
  `addSubtask`, `toggleSubtask`, `reorderSubtasks`.

## Módulo 8 — Nudge de adiamento
- Novo campo em `TaskItem`: `postponeCount` (int, default 0).
- Incrementado em `task_controller.updateTask()` sempre que
  `scheduledDate` muda pra uma data **posterior** à anterior (edição
  que empurra a tarefa pra frente).
- Reseta pra 0 quando a tarefa é concluída.

## Módulo 9 — Backup/restauração
- Formato do arquivo: JSON com `{"version": 1, "exportedAt": ...,
  "tasks": [...], "subtasks": [...], "progressLogs": [...]}`.
- Reaproveita o mesmo estilo de serialização do `share_code_codec.dart`
  (Módulo 5), mas sem compactação Base64 — aqui é um arquivo completo,
  não precisa caber num código curto.
- Exportar: gera o JSON, salva em arquivo temporário, abre a folha de
  compartilhamento nativa via `share_plus`.
- Importar: `file_picker` abre o seletor de arquivos, valida o campo
  `version`, e insere/mescla os dados.

## Módulo 10 — Ação na notificação
- Usa `AndroidNotificationAction` do `flutter_local_notifications` com
  `id: "COMPLETE_TASK"`.
- O callback de ação em background (`onDidReceiveBackgroundNotificationResponse`)
  roda num isolate separado — precisa abrir uma instância mínima do
  Isar só pra gravar a conclusão (sem carregar o resto do app), similar
  ao que o pacote `alarm` já faz internamente.

## Módulo 11 — Busca/filtro
- Só camada de UI + query no `task_repository` (`watchFiltered(query,
  type, status, dateRange)`); não exige mudança de schema.

## Módulo 12 — Widget de tela inicial
- Pacote `home_widget` conecta dados do Flutter a um `AppWidgetProvider`
  nativo (Kotlin) + layout XML.
- Sempre que uma tarefa é concluída (`task_controller.completeTask`),
  chama `HomeWidget.saveWidgetData` com a contagem de pendentes e o
  streak, seguido de `HomeWidget.updateWidget()`.
- Esse módulo é o mais isolado — pode ser feito por último sem
  bloquear os outros.

## Módulo 13 — Resumo semanal
- Reaproveita `notification_service.dart` (Módulo 2), só adiciona um
  agendamento recorrente semanal (calculado a partir do
  `progress_repository.watchRange()`).

## Módulo 14 — Categorias/tags
- Novo campo em `TaskItem`: `tags` (`List<String>`, default vazio).
- Índice Isar por tag pra filtro rápido, se necessário
  (`@Index(type: IndexType.value)` numa lista de string é suportado
  pelo Isar).

## Ordem recomendada de implementação
6 (recorrência) → 7 (subtarefas) → 8 (nudge, depende de 7 pra sugestão
fazer sentido) → 11 (busca/filtro) → 14 (tags, some junto com o filtro)
→ 9 (backup) → 10 (ação notificação) → 13 (resumo semanal) → 12 (widget,
mais isolado, pode ficar por último).
