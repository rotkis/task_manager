# Tasks: Task Manager

Cada bloco abaixo é independente o suficiente para ser dado a um agente do
opencode de cada vez. Ordem sugerida: **1 → 2 → 3 → 4 → 5** (calendário e
gráfico dependem do módulo de tarefas existir; compartilhamento é o mais
isolado e pode ficar por último).

---

## Módulo 1 — Tarefas (core)
Base de tudo: sem isso nenhum outro módulo funciona.

- [ ] `data/repositories/task_repository.dart`: CRUD completo sobre
      `TaskItem` (create, update, delete, watchAll, watchPending,
      watchByDate) usando streams do Isar (`.watch(fireImmediately: true)`).
- [ ] `features/tasks/controllers/task_controller.dart`: expõe lista de
      tarefas pendentes/concluídas, método `completeTask(id)` que atualiza
      `isCompleted`, `completedAt`, soma `rewardPoints` e chama o
      `progress_repository` (módulo 4) para atualizar o `ProgressLog` do dia.
- [ ] `features/tasks/widgets/task_form.dart`: formulário de criar/editar
      tarefa — campos mudam conforme `TaskType` selecionado (duração para
      pomodoro/exercício por tempo, meta de reps para exercício por reps).
- [ ] `features/tasks/widgets/timer_widget.dart`: cronômetro regressivo
      reutilizável (usado por pomodoro e exercício por tempo), com
      pause/resume e callback `onFinish`.
- [ ] `features/tasks/widgets/rep_counter_widget.dart`: contador
      incremental manual com botão "+1" e barra de progresso até a meta.
- [ ] `features/tasks/widgets/task_card.dart`: item de lista com swipe-to-delete
      (com desfazer via `SnackBar`) e indicador visual de atrasada.
- [ ] `features/tasks/screens/tasks_screen.dart`: lista de tarefas do dia,
      separadas em pendentes/concluídas, FAB abrindo o `task_form`.
- **Critério de aceite**: criar, editar, concluir (por cada um dos 4 tipos)
  e excluir uma tarefa funcionando de ponta a ponta na tela.
- **Testes esperados**: unit tests do `task_repository` (CRUD) e do
  `task_controller` (cálculo de pontos/streak), widget test do `task_form`
  validando campos obrigatórios por tipo.

---

## Módulo 2 — Notificações e alarmes
Depende do Módulo 1 (precisa de `TaskItem` existente e de um
`notificationId`/`alarmId` gravável).

- [ ] `features/notifications/notification_service.dart`: inicializar
      `flutter_local_notifications`, agendar/cancelar notificação simples
      por `TaskItem`.
- [ ] `features/notifications/alarm_service.dart`: wrapper do pacote
      `alarm` para tarefas `isImportant`, incluindo tela/dialog de "alarme
      tocando" com botão de parar.
- [ ] Ligar os dois serviços ao `task_controller`: criar tarefa agenda,
      editar reagenda (cancela o antigo antes), excluir cancela.
- [ ] Tratar permissões: notificação (Android 13+), alarme exato (Android
      14+), e permissão de bateria/otimização para o pacote `alarm`.
- **Critério de aceite**: notificação/alarme dispara no horário certo com
  o app em background e também fechado.
- **Testes esperados**: teste unitário do agendamento (mockando o plugin)
  garantindo que editar tarefa cancela a notificação antiga antes de criar
  a nova.

---

## Módulo 3 — Calendário e cronograma
Depende do Módulo 1.

- [ ] `features/calendar/controllers/calendar_controller.dart`: expõe
      mapa `DateTime -> List<TaskItem>` a partir do `task_repository`.
- [ ] `features/calendar/screens/calendar_screen.dart`: `table_calendar`
      com marcador nos dias que têm tarefa; ao selecionar um dia, mostra a
      lista de tarefas daquele dia abaixo.
- [ ] `features/calendar/widgets/schedule_list.dart`: visão tipo agenda
      (lista ordenada por horário) — pode ser reaproveitada como a "aba
      cronograma" separada do calendário mensal.
- [ ] Permitir editar data/horário de uma tarefa diretamente a partir dessa
      tela (reaproveita o `task_form` do Módulo 1).
- **Critério de aceite**: selecionar um dia no calendário mostra
  corretamente as tarefas daquele dia; reatribuir dia/horário reflete
  instantaneamente na lista e reagenda a notificação (Módulo 2).

---

## Módulo 4 — Gráfico de evolução
Depende do Módulo 1 (e é alimentado por ele via `progress_repository`).

- [ ] `data/repositories/progress_repository.dart`: `incrementToday(points)`
      (cria ou atualiza o `ProgressLog` do dia corrente) e
      `watchRange(start, end)` para consultas por período.
- [ ] Cálculo de streak: ao incrementar, verificar se ontem também teve
      `tasksCompleted > 0`; se sim incrementa `currentStreak`, senão reseta
      para 1.
- [ ] `features/stats/widgets/progress_line_chart.dart`: line chart
      (`fl_chart`) com seletor de período (7 / 30 / tudo).
- [ ] `features/stats/widgets/streak_badge.dart`: widget pequeno "🔥 N dias".
- [ ] `features/stats/screens/stats_screen.dart`: junta gráfico + streak +
      totais (pontos da semana, tarefas concluídas no mês).
- **Critério de aceite**: completar uma tarefa reflete no gráfico
  imediatamente (via stream do Isar), sem precisar recarregar a tela.
- **Testes esperados**: unit test do cálculo de streak cobrindo os casos
  "dia seguido", "quebrou streak" e "primeiro dia".

---

## [REMOVIDO] Módulo 5 — Compartilhamento por código
Foi implementado e depois removido do projeto por decisão de produto
(custo de manutenção vs. uso real esperado). Ver nota em `spec.md`
seção 5.7. O Backup e restauração (`tasks_v2.md`, Módulo 9) cobre o
caso de uso de levar tarefas pra outro aparelho.

---

## Convenção geral para todos os módulos
Antes de considerar um módulo "pronto", o agente deve rodar, nessa ordem:
1. `dart format .`
2. `flutter analyze` — zero erros/warnings novos
3. `flutter test` — todos os testes do módulo passando
4. Só então seguir para o próximo módulo da lista.
