# Spec v2 — Extensões anti-procrastinação

Adendo ao `spec.md` original. Numeração de módulos continua a partir do
Módulo 5 (compartilhamento), que já está pronto.

## Contexto
As features abaixo miram diretamente o comportamento de procrastinação
(hábitos, tarefas grandes demais, adiamento repetido), não só organização
de tarefas.

---

## Módulo 6 — Tarefas recorrentes (hábitos)
- Uma tarefa pode ter uma regra de recorrência: nenhuma, diária, semanal
  (dias específicos, ex: seg/qua/sex), ou intervalo customizado (a cada
  N dias).
- O app gera instâncias concretas de tarefa numa janela rolante (ex:
  próximos 30-60 dias), regenerando conforme o tempo passa.
- Completar/editar **uma instância** não afeta as outras nem a regra
  (ex: pular o treino de hoje não cancela os próximos dias).
- Editar a regra em si (ex: mudar horário do hábito) deve oferecer
  "aplicar só daqui pra frente" (não altera instâncias já passadas).
- Streak (Módulo 4) deve considerar hábitos recorrentes corretamente —
  não completar uma instância de hoje quebra o streak igual a qualquer
  tarefa.

## Módulo 7 — Subtarefas (checklist)
- Qualquer tarefa pode ter uma lista de subtarefas simples (título +
  concluída/não).
- Tarefa "grande" fica menos intimidante ao ser quebrada em passos.
- Conclusão da tarefa-pai é independente das subtarefas por padrão (o
  usuário pode marcar a tarefa toda como concluída mesmo com subtarefas
  pendentes), mas a UI mostra o progresso (ex: "3/5 passos").

## Módulo 8 — Nudge de adiamento repetido
- O app rastreia quantas vezes uma tarefa teve sua data adiada via
  edição (`postponeCount`).
- Ao atingir 3 adiamentos, mostra um aviso não-intrusivo (banner ou
  diálogo) sugerindo quebrar a tarefa em subtarefas (Módulo 7) ou
  reduzir o escopo.
- O aviso não bloqueia o usuário de simplesmente adiar de novo — é uma
  sugestão, não uma trava.

## Módulo 9 — Backup e restauração
- Exportar todos os dados do app (tarefas, subtarefas, progresso) para
  um único arquivo JSON, compartilhável (salvar no dispositivo ou
  enviar via qualquer app, usando a folha de compartilhamento nativa do
  Android).
- Importar um arquivo desse formato, com opção de "substituir tudo" ou
  "mesclar" (adicionar sem apagar o que já existe).
- Incluir um número de versão do formato no JSON exportado, pra permitir
  evoluir o formato no futuro sem quebrar backups antigos.

## Módulo 10 — Ação "Concluir" direto na notificação
- A notificação de uma tarefa (não a de alarme importante) ganha um
  botão de ação "Concluir", que marca a tarefa como feita sem precisar
  abrir o app.
- Deve funcionar mesmo com o app completamente fechado (processamento
  em background/isolate).

## Módulo 11 — Busca e filtro de tarefas
- Campo de busca por título/descrição na tela de tarefas.
- Filtros combináveis: por tipo (genérica/pomodoro/exercício), por
  status (pendente/concluída/atrasada), por intervalo de data.

## Módulo 12 — Widget de tela inicial (Android)
- Widget nativo do Android mostrando: contagem de tarefas pendentes
  hoje e o streak atual.
- Atualiza sozinho quando uma tarefa é concluída no app (sem precisar
  abrir o widget/app pra atualizar).
- **Nota**: é o módulo com maior parte de código nativo Android
  (Kotlin + XML de layout de widget), mais isolado dos demais.

## Módulo 13 — Resumo semanal
- Notificação semanal (ex: domingo à noite) com um resumo: quantas
  tarefas concluídas na semana, streak atual, comparação com a semana
  anterior.
- Agendada automaticamente, sem ação do usuário.

## Módulo 14 — Categorias/tags
- Tarefa pode ter uma ou mais tags livres (texto curto, ex: "faculdade",
  "casa", "saúde").
- Chips visuais no card da tarefa; integra com o filtro do Módulo 11
  (filtrar por tag).

## Fora de escopo por enquanto
- **Modo foco / bloqueio de distração**: exigiria Accessibility Service
  ou Usage Stats API do Android (permissões avançadas, revisão extra de
  privacidade). Vale tratar como um projeto separado se decidir seguir
  com isso depois.
