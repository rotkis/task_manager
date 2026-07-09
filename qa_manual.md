# QA manual — Task Manager

Roteiro pra rodar no aparelho físico (ou emulador com Google Play Services,
pra alarmes/notificações se comportarem de forma realista). Marque cada
item ao testar; qualquer ✅ que virar ❌, anote o comportamento observado
antes de voltar pro opencode pedir a correção.

## 0. Preparação
- [ ] `flutter run --release` (testar em modo release pega problemas de
      permissão/otimização de bateria que o modo debug às vezes disfarça)
- [ ] Desinstalar qualquer instalação anterior antes, pra testar o
      fluxo de permissões "do zero" (Android pede notificação/alarme
      exato só na primeira vez)
- [ ] Anotar a versão do Android do aparelho de teste (o comportamento de
      permissão muda bastante entre 12, 13 e 14+)

## 1. Módulo 1 — Tarefas
- [ ] Criar tarefa genérica → aparece na lista de pendentes
- [ ] Criar tarefa tipo pomodoro/estudo com duração → cronômetro abre e
      conta corretamente
- [ ] Criar exercício por tempo (ex: prancha 60s) → cronômetro regressivo
      funciona, conclui sozinha ao chegar a 0
- [ ] Criar exercício por repetições (ex: flexão, meta 20) → botão "+1"
      incrementa, barra de progresso reflete, completa ao bater a meta
- [ ] Editar uma tarefa existente (mudar título, data, tipo) → mudanças
      persistem depois de fechar e reabrir o app
- [ ] Excluir por swipe → aparece SnackBar de desfazer; testar tanto
      "desfazer" (tarefa volta) quanto deixar expirar (tarefa some de vez)
- [ ] Criar tarefa sem data → não deve travar nem sumir da lista
      silenciosamente (bug que o reviewer já pegou no Módulo 1 — confirmar
      que continua corrigido)
- [ ] Tarefa com horário no passado aparece marcada como atrasada
      visualmente

## 2. Módulo 2 — Notificações e alarmes
- [ ] Na primeira criação de tarefa com horário, o Android pede permissão
      de notificação — aceitar e confirmar que funciona
- [ ] Criar tarefa normal (não importante) daqui a 1-2 min → notificação
      simples dispara no horário, **com o app em background**
- [ ] Repetir o teste acima **com o app totalmente fechado** (swipe pra
      fora da lista de recentes)
- [ ] Criar tarefa marcada como importante daqui a 1-2 min → alarme toca
      em loop/vibra, mesmo com app fechado; botão de parar funciona
- [ ] Editar o horário de uma tarefa já agendada → notificação antiga é
      cancelada e a nova é agendada no horário certo (não dispara duas
      vezes, nem no horário errado)
- [ ] Excluir uma tarefa agendada → notificação correspondente não
      dispara mais
- [ ] Reiniciar o aparelho com um alarme importante ainda pendente →
      confirmar que ele continua agendado depois do boot (por causa do
      `RECEIVE_BOOT_COMPLETED`)

## 3. Módulo 3 — Calendário e cronograma
- [ ] Dias com tarefa aparecem com marcador no calendário mensal
- [ ] Selecionar um dia mostra exatamente as tarefas daquele dia, na
      ordem certa por horário
- [ ] Mudar de mês no calendário e voltar não perde os marcadores
- [ ] Reatribuir data/horário de uma tarefa pela tela do calendário →
      reflete na lista imediatamente e reagenda a notificação (cruzar
      com o item do Módulo 2 acima)

## 4. Módulo 4 — Gráfico de evolução
- [ ] Completar uma tarefa faz o gráfico de linha subir **sem precisar
      sair e voltar pra tela** (atualização em tempo real via stream)
- [ ] Alternar entre os períodos (7 dias / 30 dias / tudo) mostra dados
      coerentes
- [ ] Streak (🔥 N dias) incrementa corretamente completando tarefas em
      dias seguidos
- [ ] Streak reseta pra 1 depois de pular um dia sem completar nada
      (testar mudando a data do sistema, se não quiser esperar dias reais)
- [ ] Pontos do dia somam corretamente conforme o `rewardPoints` de cada
      tarefa completada

## 5. Módulo 5 — Compartilhamento por código
Esse módulo precisa de **dois aparelhos** (ou um aparelho + um emulador).
- [ ] Selecionar 2-3 tarefas no aparelho A e gerar o código
- [ ] Copiar o código e colar no aparelho B, importar
- [ ] Confirmar que as tarefas aparecem no aparelho B com datas coerentes
      (o offset relativo tem que fazer sentido no dia/horário local do
      aparelho B, não literalmente igual ao A)
- [ ] Editar o horário de uma tarefa importada no aparelho B → não afeta
      a tarefa original no aparelho A
- [ ] Duas tarefas importadas do mesmo código mostram o mesmo
      `syncGroupCode` (mesmo hash) — testar gerando o código de novo a
      partir do mesmo conjunto de tarefas e confirmar que dá o mesmo hash
      (valida a correção do FNV-1a)
- [ ] Colar um código inválido/corrompido não trava o app — mostra erro
      tratado

## 6. Temas
- [ ] Alternar manualmente light/dark no ícone da AppBar aplica as
      paletas certas (creme `#FFF8E7` no light, roxo Catppuccin `#1E1E2E`
      / `#CBA6F7` no dark) em **todas** as telas, não só na inicial
- [ ] Tema "seguir o sistema" (se implementado) responde a mudar o tema
      do Android nas configurações

## 7. Fluxo integrado (ponta a ponta, tudo junto)
Simula um dia de uso real, sem pular etapas:
1. [ ] Abre o app pela primeira vez (permissões concedidas)
2. [ ] Cria 3 tarefas de tipos diferentes pro dia, com horários próximos
3. [ ] Recebe notificação/alarme de cada uma no horário certo
4. [ ] Completa as 3 → gráfico e streak atualizam
5. [ ] Vê o dia no calendário refletindo as 3 tarefas concluídas
6. [ ] Compartilha o conjunto com outro aparelho e confirma import
7. [ ] Fecha o app, reabre depois de um tempo → tudo continua consistente

## 8. Registro de problemas encontrados
Pra cada item que falhar, anote nesse formato antes de levar de volta
pro opencode:

```
Módulo: X
Passo do teste: "..."
Esperado: ...
Observado: ...
Versão do Android: ...
```

Isso vira o prompt de correção pro `flutter-build` — quanto mais preciso
o "esperado vs observado", menos ida-e-volta o agente precisa pra
entender e corrigir.
