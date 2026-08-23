# Prompt — App Android "Uniswap Fees Dashboard"

> Prompt pronto a usar para pedir a uma IA (ou a um developer) a construção de uma
> app Android de dashboard para acompanhar as taxas (fees) geradas pelas minhas
> pools de liquidez na Uniswap, inspirada na app Krystal, com foco em mostrar
> **em direto** e em **números grandes** o valor de fees acumulado.

---

## Prompt

Cria uma app Android (Kotlin + Jetpack Compose, Material 3) chamada
**"Pool Fees Tracker"**, um dashboard para acompanhar em tempo real as taxas
(fees) geradas pelas minhas posições de liquidez na Uniswap (v3 e v4),
inspirada na experiência da app **Krystal** (secção de "Earnings"/"Pool
Positions"). A app é **read-only**: nunca pede nem guarda chaves privadas,
apenas endereços de wallet (públicos) ou ligação via WalletConnect só para
leitura.

### 1. Objetivo principal

- O ecrã inicial ("Home") deve ter, em destaque no topo, um **número grande**
  (tipografia grande, tabular, com animação de contagem/"count-up" quando o
  valor muda) com o **total de fees acumuladas** em USD de todas as pools,
  atualizado em direto (polling a cada 15–30s ou subscrição via WebSocket ao
  subgraph/RPC).
- Por baixo do número principal, mostrar sub-métricas rápidas: fees nas
  últimas 24h, variação % vs. dia anterior, e um indicador visual (seta
  verde/vermelha) de tendência.
- A app deve poder acompanhar **múltiplas pools em simultâneo**, associadas a
  um ou mais endereços de wallet.

### 2. Fonte de dados

- Usar o **Uniswap v3/v4 Subgraph** (The Graph) para histórico de fees,
  liquidez e swaps por posição.
- Usar um provider RPC (Alchemy/Infura/QuickNode — configurável via API key
  nas definições) para ler o estado atual das posições NFT (`positions()` no
  `NonfungiblePositionManager`) e calcular fees não reclamadas
  (`collect` simulation / `tokensOwed0`/`tokensOwed1`).
- Suportar múltiplas chains (Ethereum mainnet, Arbitrum, Base, Optimism,
  Polygon) — seletor de rede nas definições, com fees agregadas em USD
  usando um price feed (Coingecko API ou o próprio subgraph).
- Cache local (Room/SQLite) do histórico para funcionar offline e reduzir
  chamadas à API.

### 3. Gráfico de barras configurável por pool

- Ecrã de detalhe por pool com um **gráfico de barras** do valor de fees
  geradas por período.
- Configuração do utilizador (segmented control ou dropdown):
  - Agrupar por: **Hora / Dia / Semana / Mês**
  - Intervalo: **24h / 7 dias / 30 dias / 90 dias / Desde o início**
  - Alternar entre fees em **USD** ou nos tokens nativos da pool (token0/token1)
- Cada barra com tooltip ao toque (valor exato, data, e taxa APR
  equivalente desse período).
- Comparação opcional: sobrepor uma linha com o valor investido/liquidez para
  contextualizar o rendimento.

### 4. Outras estatísticas a incluir (inspiração Krystal + valor acrescentado)

- **APR / APY realizado** por pool (fees acumuladas ÷ liquidez fornecida,
  anualizado) e APR médio da carteira toda.
- **Fees reclamadas vs. não reclamadas** (claimed vs. unclaimed), com botão
  de atalho para abrir a transação de "collect" na wallet.
- **Estado do range de preço** (in-range / out-of-range) com barra visual
  mostrando a posição do preço atual dentro do range mín/máx da posição —
  crítico em Uniswap v3/v4, tal como a Krystal mostra.
- **Impermanent loss estimado** (comparação entre "hold" vs. posição atual).
- **Valor total em liquidez (TVL da posição)** e breakdown por token
  (quantidade + valor USD de token0/token1).
- **Custo de gás acumulado** (mints, adds, collects) para dar uma noção do
  lucro líquido (fees − gás).
- **Ranking de pools** por rendimento (melhor/pior pool da carteira).
- **Histórico de eventos**: lista de collects, adds/removes de liquidez.
- **Notificações push**: alerta quando uma posição sai do range de preço, ou
  quando as fees acumuladas ultrapassam um limite definido pelo utilizador.
- **Multi-wallet**: agregação de fees de várias wallets num único total.

### 5. UI/UX

- **Home**: número grande de fees totais (com animação count-up), sub-cards
  com 24h/7d, lista de pools (cada uma com mini-sparkline + fees do dia).
- **Detalhe da pool**: header com par de tokens + fee tier (ex: ETH/USDC
  0.05%), número grande com fees totais dessa pool, gráfico de barras
  configurável (ponto 3), barra de range de preço, botão de refresh manual e
  indicador de "última atualização".
- **Widget de ecrã inicial Android** (App Widget) com o número grande de
  fees totais, atualizado periodicamente via `WorkManager`.
- Modo escuro por definição (paleta estilo trading app: fundo quase preto,
  verde/vermelho para variações positivas/negativas, tipografia monoespaçada
  para os números).
- Pull-to-refresh em todos os ecrãs com dados em direto.
- Ecrã de definições: gerir wallets/endereços seguidos, escolher chains,
  escolher API keys (RPC/Coingecko), moeda de referência (USD/EUR), intervalo
  de atualização automática.

### 6. Arquitetura sugerida

- **Kotlin + Jetpack Compose**, arquitetura MVVM com `ViewModel` + `StateFlow`.
- **Room** para cache local de histórico de fees e posições.
- **Retrofit/Ktor** para chamadas ao subgraph (GraphQL) e Coingecko.
- **Web3j** ou **web3-kmp** para leitura on-chain (fallback quando o subgraph
  estiver desatualizado).
- **WorkManager** para polling periódico em background e atualização do
  widget.
- **Hilt** para injeção de dependências.
- Gráficos com **Vico** ou **MPAndroidChart** (bar chart configurável).

### 7. Critérios de aceitação

- O número principal de fees atualiza sem precisar de reiniciar a app
  (live, com indicador subtil de "a atualizar…").
- É possível adicionar uma wallet, ver as pools associadas automaticamente
  detetadas, e configurar o gráfico de barras por hora/dia/semana/mês por
  cada pool individualmente.
- App funciona só de leitura — nunca pede seed phrase nem chave privada.
- Interface responde em <100ms a interações locais; chamadas de rede
  mostram skeleton/loading states, nunca bloqueiam o ecrã.

---

## Notas de implementação (contexto do repositório)

Este repositório (`hobby`) atualmente contém a app **Ritmo** (cronómetro de
assiduidade em hobbies, em **Flutter**), que é um projeto completamente
distinto deste dashboard de Uniswap. Se a intenção for desenvolver esta app
neste mesmo repositório, é preciso decidir:

1. **Novo projeto Android nativo à parte** (recomendado pelo prompt acima,
   Kotlin/Compose) — provavelmente num repositório/diretório próprio, já que
   a stack (Kotlin nativo) não tem nada a ver com o Flutter do Ritmo.
2. **Ou reaproveitar a stack Flutter existente** (Riverpod + `fl_chart`, já
   presentes no `pubspec.yaml`), o que permitiria construir esta dashboard
   como uma nova app Flutter (ou até uma nova feature dentro do Ritmo, se
   fizer sentido ter os dois no mesmo repositório) reaproveitando padrões já
   usados (ex.: `tendencia_chart.dart`, `evolucao_todos_hobbies_chart.dart`).

Diz-me qual das duas opções preferes e eu começo a implementação.
