# Pool Fees Tracker

Dashboard Android para acompanhar **em direto** as taxas (fees) geradas pelas
minhas posições de liquidez na Uniswap v3/v4 — número grande no topo, gráfico
de barras configurável por pool (hora/dia/semana/mês, 24h a "desde o início"),
e estatísticas extra: APR realizado, estado do range de preço, P&L desde a
abertura, impermanent loss estimado, break-even de gás, projeção de ganhos
por mês/ano, histórico de eventos (mint/collect/burn), alertas (out-of-range
e milestones de fees) e um widget de ecrã inicial.

A app é **read-only**: nunca pede chave privada ou seed phrase.

## Fontes de dados

- **Demo** (omissão): posições e histórico de fees sintéticos, gerados em
  memória — funciona sem wallet nem API key, com um "live tick" a simular
  fees a acumular. Inclui uma posição já fechada (para mostrar que o total
  vitalício não a esquece) e uma posição noutra chain (Arbitrum, para mostrar
  a agregação multi-chain).
- **Live** (experimental, em Definições): lê posições reais do subgraph
  Uniswap v3 (The Graph), em todas as chains selecionadas ao mesmo tempo, e
  calcula fees não reclamadas com a mesma fórmula do contrato
  (`lib/core/calc/univ3_fee_math.dart`), sem precisar de RPC. Ver as
  aproximações conhecidas documentadas no topo de
  `lib/data/repositories/live_pool_fees_repository.dart` — nunca testado
  contra um endpoint real; valide com uma Subgraph API key antes de confiar
  nos números.

## Alertas e widget de ecrã inicial

Uma única tarefa periódica do Android WorkManager
(`lib/data/background/background_sync_worker.dart`, a cada ~15 min, também
acionável já com o botão "Check now" no ecrã de Alerts) atualiza o widget de
ecrã inicial e, se ligado em Definições, verifica se alguma posição saiu do
range ou passou um milestone de fees, disparando uma notificação local.
Nunca testado num dispositivo real nesta sessão (sem Android SDK/emulador
disponível) — a lógica de deteção em si (`lib/core/calc/alert_detector.dart`)
tem testes unitários, mas a integração nativa (WorkManager, notificações, o
widget em `android/app/src/main/kotlin/.../PoolFeesWidgetProvider.kt`) só foi
validada por leitura/paridade com os exemplos oficiais dos plugins.

## Estrutura

```
lib/
  core/        # cálculos puros (APR, projeções, range health, fee math) + tema + formatação
  data/        # modelos Isar, repositórios (demo/live/wallets), cliente do subgraph
  features/    # ecrãs: dashboard, pool_detail, pools, alerts, settings
  shared/      # widgets reutilizados entre ecrãs
test/          # testes unitários dos cálculos (sem Isar/rede)
```

## Correr

```
flutter pub get
flutter run
```

Para gerar o código do Isar depois de alterar um modelo em `lib/data/local/`:

```
dart run build_runner build --delete-conflicting-outputs
```
