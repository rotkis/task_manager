# Tasks v2: módulos 6-14

Ordem recomendada (ver plan_v2.md): 6 → 7 → 8 → 11 → 14 → 9 → 10 → 13 → 12

---

## Módulo 6 — Tarefas recorrentes (hábitos)
- [ ] Adicionar `recurrenceRule` e `parentRecurringId` ao `TaskItem`
      (Isar) + rodar build_runner.
- [ ] `task_repository.ensureUpcomingInstances()`: gera instâncias
      concretas dos próximos 30 dias pra toda tarefa-modelo com
      `recurrenceRule` preenchido, chamado ao abrir o app.
- [ ] Parser simples de `recurrenceRule` (`daily`, `weekly:MON,WED`,
      `every:N`) em `core/utils/recurrence_parser.dart`.
- [ ] UI no `task_form`: seletor de recorrência (nenhuma/diária/
      semanal com dias/intervalo customizado).
- [ ] Ao editar uma tarefa recorrente, perguntar "só esta" ou "esta e
      as futuras" antes de salvar.
- **Critério de aceite**: criar hábito diário gera instâncias pros
  próximos 30 dias; completar uma não afeta as outras; editar "esta e
  as futuras" regenera só as futuras.
- **Testes**: unit test do `recurrence_parser` (as 3 variantes) e do
  `ensureUpcomingInstances` (não duplica instância já existente).

---

## Módulo 7 — Subtarefas
- [ ] Nova collection `SubTaskItem` (Isar) + build_runner.
- [ ] `task_repository`: `watchSubtasks`, `addSubtask`,
      `toggleSubtask`, `reorderSubtasks`, `deleteSubtask`.
- [ ] Widget `subtask_checklist.dart`: lista expansível dentro do
      `task_card`/`task_form`, com progresso "N/M".
- **Critério de aceite**: adicionar, marcar, reordenar e remover
  subtarefa de uma tarefa; progresso "N/M" reflete corretamente.
- **Testes**: unit test do CRUD de subtarefas no repository.

---

## Módulo 8 — Nudge de adiamento repetido
- [ ] Campo `postponeCount` no `TaskItem` + build_runner.
- [ ] `task_controller.updateTask()`: incrementa quando a nova
      `scheduledDate` é posterior à anterior; reseta ao completar.
- [ ] Widget de aviso (banner/dialog) quando `postponeCount >= 3`,
      oferecendo abrir o checklist de subtarefas (Módulo 7).
- **Critério de aceite**: adiar a mesma tarefa 3 vezes mostra o aviso;
  completá-la reseta o contador.
- **Testes**: unit test do incremento/reset do `postponeCount`.

---

## Módulo 11 — Busca e filtro
- [ ] `task_repository.watchFiltered(query, type, status, dateRange)`.
- [ ] Barra de busca + chips de filtro na `tasks_screen`.
- **Critério de aceite**: buscar por texto e combinar com filtro de
  tipo/status/data retorna o esperado.
- **Testes**: unit test do `watchFiltered` cobrindo combinações
  (busca sozinha, filtro sozinho, os dois juntos).

---

## Módulo 14 — Categorias/tags
- [ ] Campo `tags` (`List<String>`) no `TaskItem` + build_runner.
- [ ] Campo de tags no `task_form` (chips editáveis).
- [ ] Integrar tag como mais um filtro do Módulo 11.
- **Critério de aceite**: criar tarefa com tags, filtrar por tag mostra
  só as correspondentes.
- **Testes**: unit test do filtro por tag.

---

## Módulo 9 — Backup e restauração
- [ ] `core/utils/backup_codec.dart`: `exportAll()` → JSON completo
      (tasks + subtasks + progressLogs + campo `version`).
      `importAll(json, {merge: bool})`.
- [ ] Tela/ação "Exportar backup" → gera arquivo, abre
      share_plus.
- [ ] Tela/ação "Importar backup" → `file_picker`, valida `version`,
      pergunta mesclar ou substituir.
- **Critério de aceite**: exportar, apagar o app (ou instalar em outro
  aparelho), importar, e todos os dados voltam idênticos.
- **Testes**: unit test round-trip `exportAll` → `importAll` (merge e
  substituir).

---

## Módulo 10 — Ação "Concluir" na notificação
- [ ] `AndroidNotificationAction` "COMPLETE_TASK" nas notificações
      normais (não nas de alarme importante).
- [ ] Handler de background que abre uma instância mínima do Isar e
      marca a tarefa concluída, sem depender do app estar aberto.
- **Critério de aceite**: tocar "Concluir" na notificação, com o app
  fechado, marca a tarefa e atualiza o gráfico/streak na próxima
  abertura do app.
- **Testes**: teste manual obrigatório (ação em background não é bem
  coberta por `flutter test`); documentar o passo a passo do teste
  manual no PR/commit.

---

## Módulo 13 — Resumo semanal
- [ ] Agendamento automático (ex: domingo 20h) via
      `notification_service`, calculado a partir do
      `progress_repository.watchRange()` da semana.
- **Critério de aceite**: notificação de resumo aparece no horário
  configurado com números corretos da semana.
- **Testes**: unit test do cálculo do resumo (dado um conjunto de
  ProgressLog, retorna os números certos).

---

## Módulo 12 — Widget de tela inicial (Android)
- [ ] `home_widget` configurado + `AppWidgetProvider` nativo (Kotlin)
      + layout XML simples (pendentes hoje + streak).
- [ ] `task_controller.completeTask()` chama
      `HomeWidget.saveWidgetData` + `HomeWidget.updateWidget()`.
- **Critério de aceite**: adicionar o widget à tela inicial mostra os
  números certos e atualiza sozinho ao completar tarefa no app.
- **Testes**: teste manual (widget nativo não é testável via
  `flutter test`); documentar o passo a passo manual.

---

## Convenção (igual aos módulos 1-5)
Antes de considerar qualquer módulo pronto:
1. `dart format .`
2. `flutter analyze` — zero erros/warnings novos
3. `flutter test` — módulo passando
4. Para os módulos 10 e 12 (ação em background / widget nativo),
   teste manual obrigatório no APK de release, já que `flutter test`
   não cobre esses caminhos.
