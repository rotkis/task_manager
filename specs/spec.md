# Spec: Task Manager — app anti-procrastinação

## 1. Visão geral
Aplicativo mobile (Android, via Flutter) para ajudar o usuário a combater a
procrastinação organizando tarefas de diferentes tipos, lembrando delas por
notificação/alarme, recompensando a conclusão, e mostrando a evolução ao
longo do tempo. Sem login — todos os dados vivem localmente no dispositivo
(Isar), com um sistema de código para compartilhar/copiar tarefas entre
usuários.

## 2. Objetivos
- Reduzir a fricção de criar e acompanhar tarefas do dia a dia.
- Dar feedback visual de progresso (gráfico + streak) para reforçar o hábito.
- Suportar tarefas com "formato" diferente (estudo cronometrado, exercício por
  tempo, exercício por repetições, tarefa simples).
- Permitir compartilhar um conjunto de tarefas/horários com outra pessoa via
  código, sem precisar de conta nem servidor próprio de sync contínuo.

## 3. Não-objetivos (fora de escopo da v1)
- Login / conta de usuário / sync em nuvem contínuo.
- Multiplataforma (iOS/desktop) — foco inicial é Android.
- Colaboração em tempo real (o "código de cópia" é uma cópia pontual, não um
  compartilhamento ao vivo).
- Gamificação social (ranking entre usuários, amigos, etc.).

## 4. Personas
- **Estudante procrastinador**: quer usar blocos de tempo (pomodoro) para
  estudar e ver evolução.
- **Praticante de calistenia em casa**: quer registrar exercícios por tempo
  (prancha) ou repetições (flexão) como tarefas do dia.
- **Pessoa com prazos/entregas**: quer atribuir tarefas/projetos a datas e
  horários específicos e visualizar tudo num cronograma.

## 5. Requisitos funcionais

### 5.1 Tarefas (CRUD)
- Criar tarefa com: título, descrição opcional, tipo, data, horário
  (opcional), parâmetros do tipo (duração ou repetições), pontos de
  recompensa (valor padrão, editável).
- Editar qualquer campo de uma tarefa existente.
- Remover tarefa com confirmação (swipe-to-delete + desfazer, ou botão).
- Marcar tarefa como concluída manualmente, ou automaticamente ao finalizar
  o cronômetro/contador (ver 5.2).
- Listagem de tarefas pendentes do dia, com destaque para atrasadas.

### 5.2 Tipos de tarefa
| Tipo | Comportamento na UI |
|---|---|
| Genérica | Checkbox simples de concluir |
| Estudo (pomodoro) | Cronômetro configurável (padrão 25 min foco / 5 min pausa), notifica ao fim do ciclo |
| Exercício por tempo | Cronômetro de contagem regressiva (ex: prancha 60s) |
| Exercício por repetições | Contador incremental manual (ex: flexão, toca "+1" a cada repetição, define meta) |

- Ao concluir qualquer tipo, a tarefa é marcada `isCompleted`, dispara a
  recompensa (5.4) e atualiza o registro de progresso do dia (5.3).

### 5.3 Gráfico de evolução
- Gráfico de linha mostrando pontos acumulados / tarefas concluídas por dia,
  subindo a cada tarefa concluída (agregado diário armazenado em
  `ProgressLog`).
- Períodos de visualização: últimos 7 dias, 30 dias, tudo.
- Widget resumido (mini gráfico ou número) também na tela inicial.

### 5.4 Recompensa
- Ao concluir uma tarefa: pontos somados ao total do dia, animação/feedback
  visual simples (ex: confete leve ou destaque de cor), e possível
  incremento de streak (dias seguidos com ao menos 1 tarefa concluída).
- Streak exibido como widget (ex: "🔥 5 dias seguidos").

### 5.5 Notificações e alarmes
- Notificação local no horário agendado da tarefa (via
  `flutter_local_notifications` + `timezone`).
- Opção de alarme mais insistente (som/repetição) para tarefas marcadas como
  "importantes", diferenciando de notificação silenciosa comum.
- Cancelar/reagendar notificação automaticamente ao editar ou excluir a
  tarefa.

### 5.6 Calendário e cronograma
- Visualização de calendário mensal (`table_calendar`) com indicador de dias
  que têm tarefas.
- Visualização de cronograma (lista/agenda por dia, ordenada por horário)
  para ver rapidamente o que vem a seguir.
- Atribuir/mudar a data e horário de uma tarefa direto pelo calendário
  (drag ou seleção + edição).

### 5.7 [REMOVIDO] Compartilhar tarefas via código
Essa feature foi implementada (v1) e depois **removida por decisão de
produto**: o custo de manutenção (bugs de determinismo de hash,
reatividade, agendamento de notificação) não compensava o uso real
esperado, já que o app é de uso pessoal/poucos usuários. O campo
`syncGroupCode` foi removido do `TaskItem`. O Backup e restauração
(Módulo 9, ver `tasks_v2.md`) cobre o caso de uso real de "levar minhas
tarefas pra outro aparelho".

### 5.8 Temas
- Light theme: fundo branco levemente amarelado (`#FFF8E7`), texto marrom
  escuro.
- Dark theme: paleta estilo Catppuccin Mocha (base `#1E1E2E`, destaque roxo
  `#CBA6F7`).
- Alternância manual (ícone na AppBar) e opção de seguir o tema do sistema.

## 6. Modelo de dados (Isar)
- **TaskItem**: id, title, description, type (enum), scheduledDate,
  scheduledTime, durationMinutes, targetReps, isCompleted, completedAt,
  rewardPoints, notificationId, createdAt. (campos adicionados depois:
  recurrenceRule, parentRecurringId, postponeCount, tags — ver
  `spec_v2.md`/`plan_v2.md`)
- **ProgressLog**: id, day (único por dia), tasksCompleted, pointsEarned,
  currentStreak.

## 7. Decisões técnicas em aberto (para o /plan)
- **Formato do código de compartilhamento**: decidir entre (a) o próprio
  código já carrega os dados codificados/comprimidos (ex: base32 de um JSON
  compactado) — funciona 100% offline sem servidor; ou (b) o código é só uma
  chave e existe um backend mínimo pra guardar o payload — mais robusto para
  pacotes grandes, mas quebra o requisito de "sem login/servidor". Recomendo
  (a) para manter a v1 sem infraestrutura de backend.
- **Isar**: usar `isar_community` (fork mantido, API v3) em vez do pacote
  `isar` original (descontinuado) ou do `isar` v4 novo (ainda em maturação).
- **Alarmes "insistentes"**: verificar se `flutter_local_notifications`
  sozinho cobre o caso (canal de alta prioridade + som em loop) ou se será
  necessário um pacote adicional de alarme (ex: `android_alarm_manager_plus`)
  para o Android matar menos o processo em background.

## 8. Requisitos não funcionais
- Funcionar 100% offline (nenhuma feature depende de internet).
- Dados nunca saem do aparelho, exceto quando o usuário gera/importa um
  código de compartilhamento explicitamente.
- Abertura do app e listagem de tarefas do dia deve ser instantânea
  (Isar é local, sem chamadas de rede).

## 9. Critérios de aceite (v1)
- [ ] Usuário cria, edita e remove tarefa de qualquer um dos 4 tipos.
- [ ] Cronômetro/contador funciona e marca a tarefa como concluída ao fim.
- [ ] Notificação dispara no horário agendado mesmo com o app fechado.
- [ ] Gráfico de linha reflete corretamente tarefas concluídas por dia.
- [ ] Calendário mostra indicador nos dias com tarefa e permite reatribuir
      data/horário.
- [ ] Gerar código de um conjunto de tarefas e importar em uma segunda
      instância do app reproduz as mesmas tarefas, editáveis independentemente.
- [ ] Alternância light/dark aplica as paletas definidas na seção 5.8.
