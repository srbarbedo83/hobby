# Pool Fees Tracker

Dashboard Android para acompanhar **em direto** as taxas (fees) geradas pelas
minhas posições de liquidez na Uniswap v3/v4 — número grande no topo, gráfico
de barras configurável por pool (hora/dia/semana/mês, 24h a "desde o início"),
e estatísticas extra: APR realizado, estado do range de preço, desde-quando-
-abri-isto P&L, break-even de gás, e projeção de ganhos por mês/ano.

A app é **read-only**: nunca pede chave privada ou seed phrase.

## Fontes de dados

- **Demo** (omissão): posições e histórico de fees sintéticos, gerados em
  memória — funciona sem wallet nem API key, com um "live tick" a simular
  fees a acumular.
- **Live** (experimental, em Definições): lê posições reais do subgraph
  Uniswap v3 (The Graph) e calcula fees não reclamadas com a mesma fórmula do
  contrato (`lib/core/calc/univ3_fee_math.dart`), sem precisar de RPC. Ver as
  aproximações conhecidas documentadas no topo de
  `lib/data/repositories/live_pool_fees_repository.dart` — nunca testado
  contra um endpoint real; valide com uma Subgraph API key antes de confiar
  nos números.

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
