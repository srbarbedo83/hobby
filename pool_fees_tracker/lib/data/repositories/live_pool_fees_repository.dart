import 'dart:async';

import 'package:isar_community/isar.dart';

import '../../core/calc/liquidity_profile.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../local/chain.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import '../local/position_event.dart';
import '../local/price_point.dart';
import '../remote/eth_rpc_client.dart';
import '../remote/uniswap_subgraph_client.dart';
import 'pool_fees_repository.dart';
import 'wallet_repository.dart';

/// Implementação "live": lê posições reais do subgraph Uniswap v3 e
/// calcula fees não reclamadas com a mesma fórmula do contrato
/// (`univ3_fee_math.dart`), sem precisar de uma chamada RPC.
///
/// Agrega várias chains ao mesmo tempo (uma ligação ao subgraph por
/// chain, a mesma API key): as mesmas wallets são consultadas em cada
/// chain selecionada e os resultados somados num só dashboard — um
/// endereço EVM é o mesmo em todas as chains, não há nada específico por
/// chain a configurar além de quais ligar.
///
/// Inclui posições já FECHADAS (liquidez removida): continuam a contar
/// para o total vitalício de fees do dashboard, só deixam de aparecer na
/// lista "Your Pools" — ver `PoolPosition.isClosed` e o ecrã de Pools.
///
/// Aproximações conhecidas, por não serem o foco do pedido original
/// (acompanhar fees) e por implicarem bastante mais superfície:
/// - `liquidityUsd`/`initialLiquidityUsd` usam os montantes depositados
///   menos os retirados, a preço ATUAL (não o valor exato da posição
///   agora, que precisaria da fórmula `getAmountsForLiquidity` com
///   sqrt-price, nem o preço histórico no momento de cada depósito/saque).
///   As fees — o número em destaque na app — não são afetadas por esta
///   aproximação.
/// - `gasCostUsd` fica a 0 no modelo persistido (o subgraph não guarda
///   custo de gás). Quando há um RPC URL configurado nas Definições, e
///   esse RPC responde pela MESMA chain da posição (confirmado via
///   `eth_chainId` — um endpoint só serve uma chain, mas o utilizador pode
///   ter várias selecionadas), [getGasCostUsd] lê os recibos das
///   transações da posição (mint/collects/burn, cujos hashes já vêm de
///   [getEvents]) e soma `gasUsed × effectiveGasPrice` a sério — ver
///   `EthRpcClient`. Sem RPC configurado, ou em Polygon (gás pago em
///   MATIC, sem fonte de preço de MATIC ligada), devolve `null` e o ecrã
///   de detalhe cai para o valor persistido (0).
/// - `closedAt` fica `null`: o subgraph não dá diretamente o timestamp em
///   que uma posição fechou (seria preciso o evento `Burn` mais recente
///   dessa posição). O ecrã de Pools mostra "Closed" sem data nesse caso.
/// - `entryTick` (para o impermanent loss) usa o centro do range como
///   proxy do tick de entrada — o subgraph não liga o tick exato do mint
///   ao tokenId do NFT.
/// - `getEvents` identifica os eventos (mint/collect/burn) desta posição
///   por `pool + owner + tickLower + tickUpper`, pela mesma razão — ver
///   `UniswapSubgraphClient.fetchPositionEvents`.
/// - `getPricePoints` só regista um ponto por refresh a partir do momento
///   em que a app liga — o subgraph não é interrogado pelo histórico de
///   tick antigo, por isso gráficos/streaks que dependem disto ficam
///   curtos logo após ativar modo Live (crescem com o uso).
/// - O histórico por posição (para o gráfico de barras) é alocado a partir
///   do histórico da POOL (`poolHourData`/`poolDayData`), repartido pela
///   quota de liquidez da posição — o subgraph não guarda uma série
///   temporal por posição. Para uma posição fechada isto já não é possível
///   (a quota atual seria 0), por isso o histórico fica congelado no que já
///   estava em cache a partir do momento em que fechou.
///
/// Nunca testado contra um endpoint real nesta sessão (sem API key
/// disponível) — valide com uma Subgraph API key antes de confiar nos
/// números em modo live.
class LivePoolFeesRepository implements PoolFeesRepository {
  final WalletRepository _walletRepository;
  final Isar _isar;
  final Map<Chain, UniswapSubgraphClient> _clients;
  final EthRpcClient? _rpcClient;

  List<PoolPosition> _positions = [];
  final Map<String, String> _poolIdByPositionKey = {};
  final Map<String, Chain> _chainByPositionKey = {};
  final Map<Chain, double> _ethPriceUsdByChain = {};
  final StreamController<List<PoolPosition>> _controller =
      StreamController.broadcast();
  DateTime? _lastUpdatedAt;
  String? _lastError;
  Timer? _autoRefreshTimer;
  bool _refreshing = false;
  Future<Chain?>? _rpcChainFuture;

  LivePoolFeesRepository({
    required List<Chain> chains,
    required String apiKey,
    required WalletRepository walletRepository,
    required Isar isar,
    String rpcUrl = '',
    Map<Chain, String> subgraphIdOverrides = const {},
    Map<Chain, UniswapSubgraphClient>? clients,
    EthRpcClient? rpcClient,
  }) : _walletRepository = walletRepository,
       _isar = isar,
       _clients =
           clients ??
           {
             for (final chain in chains)
               chain: UniswapSubgraphClient(
                 chain: chain,
                 apiKey: apiKey,
                 subgraphIdOverride: subgraphIdOverrides[chain],
               ),
           },
       _rpcClient =
           rpcClient ?? (rpcUrl.isEmpty ? null : EthRpcClient(rpcUrl: rpcUrl)) {
    _loadCachedThenRefresh();
  }

  Future<void> _loadCachedThenRefresh() async {
    _positions = await _isar.poolPositions.where().findAll();
    if (_positions.isNotEmpty) _controller.add(List.unmodifiable(_positions));
    await refreshNow();
  }

  @override
  Stream<List<PoolPosition>> watchPositions() async* {
    yield List.unmodifiable(_positions);
    yield* _controller.stream;
  }

  @override
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  @override
  String? get lastError => _lastError;

  @override
  Future<List<FeeSnapshot>> getFeeSnapshots(String positionKey) {
    return _isar.feeSnapshots
        .filter()
        .positionKeyEqualTo(positionKey)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<List<PricePoint>> getPricePoints(String positionKey) {
    return _isar.pricePoints
        .filter()
        .positionKeyEqualTo(positionKey)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<List<TickLiquidity>> getLiquidityProfile(String positionKey) async {
    final poolId = _poolIdByPositionKey[positionKey];
    final chain = _chainByPositionKey[positionKey];
    final client = chain == null ? null : _clients[chain];
    if (poolId == null || client == null) return const [];

    PoolPosition? position;
    for (final p in _positions) {
      if (p.positionKey == positionKey) {
        position = p;
        break;
      }
    }
    if (position == null) return const [];

    final width = position.tickUpper - position.tickLower;
    if (width <= 0) return const [];

    final raw = await client.fetchLiquidityProfile(
      poolId: poolId,
      tickLowerBound: position.tickLower - width,
      tickUpperBound: position.tickUpper + width,
    );
    return raw
        .map(
          (t) => TickLiquidity(
            tick: t.tickIdx,
            liquidityGross: t.liquidityGross.toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<List<PositionEvent>> getEvents(String positionKey) async {
    final poolId = _poolIdByPositionKey[positionKey];
    final chain = _chainByPositionKey[positionKey];
    final client = chain == null ? null : _clients[chain];
    if (poolId == null || client == null) return [];

    PoolPosition? position;
    for (final p in _positions) {
      if (p.positionKey == positionKey) {
        position = p;
        break;
      }
    }
    if (position == null) return [];

    final raw = await client.fetchPositionEvents(
      poolId: poolId,
      owner: position.walletAddress,
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
    );
    return raw
        .map(
          (e) => PositionEvent()
            ..positionKey = positionKey
            ..timestamp = e.timestamp
            ..type = switch (e.kind) {
              RawEventKind.mint => PositionEventType.mint,
              RawEventKind.collect => PositionEventType.collect,
              RawEventKind.burn => PositionEventType.decreaseLiquidity,
            }
            ..amountUsd = e.amountUsd
            ..txHash = e.txHash,
        )
        .toList();
  }

  /// Custo real de gás de uma posição, em USD — `null` quando não há como
  /// calculá-lo (sem RPC configurado, RPC de outra chain, ou Polygon). Ver
  /// a nota sobre `gasCostUsd` no topo do ficheiro.
  @override
  Future<double?> getGasCostUsd(String positionKey) async {
    final rpcClient = _rpcClient;
    final positionChain = _chainByPositionKey[positionKey];
    if (rpcClient == null || positionChain == null) return null;
    // O gás é pago em MATIC em Polygon, não em ETH — não temos uma fonte
    // de preço de MATIC ligada, por isso não arriscamos um número errado.
    if (positionChain == Chain.polygon) return null;

    final rpcChain = await (_rpcChainFuture ??= rpcClient.detectChain());
    if (rpcChain != positionChain) return null;

    final events = await getEvents(positionKey);
    final txHashes = events
        .map((e) => e.txHash)
        .whereType<String>()
        .toSet()
        .toList();
    if (txHashes.isEmpty) return 0;

    final gasWei = await rpcClient.fetchGasCostWei(txHashes);
    final ethPriceUsd = _ethPriceUsdByChain[positionChain] ?? 0;
    return tokenAmountToDouble(gasWei, 18) * ethPriceUsd;
  }

  @override
  Future<void> refreshNow() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final wallets = await _walletRepository.getAll();
      if (wallets.isEmpty) {
        _lastUpdatedAt = DateTime.now();
        _controller.add(List.unmodifiable(_positions));
        return;
      }
      final owners = wallets.map((w) => w.address).toList();

      final now = DateTime.now();
      final mapped = <PoolPosition>[];
      final pricePoints = <PricePoint>[];

      for (final entry in _clients.entries) {
        final chain = entry.key;
        final client = entry.value;
        final result = await client.fetchPositions(owners);
        _ethPriceUsdByChain[chain] = result.ethPriceUsd;

        for (final raw in result.positions) {
          final position = _mapPosition(chain, raw, result.ethPriceUsd);
          mapped.add(position);
          _poolIdByPositionKey[position.positionKey] = raw.pool.id;
          _chainByPositionKey[position.positionKey] = chain;
          // Uma posição fechada já não tem quota da pool (liquidity == 0)
          // — não há como alocar-lhe fees novas, por isso o seu histórico
          // fica congelado no que já estava guardado em Isar.
          if (!position.isClosed) {
            await _refreshHistoryForPosition(
              client: client,
              raw: raw,
              position: position,
              now: now,
            );
            // Um ponto de preço por refresh — só prospetivo (ver nota no
            // topo do ficheiro): o subgraph não dá o histórico de tick
            // antigo, por isso o histórico só começa a partir de agora.
            pricePoints.add(
              PricePoint()
                ..positionKey = position.positionKey
                ..timestamp = now
                ..tick = position.currentTick,
            );
          }
        }
      }

      await _isar.writeTxn(() async {
        await _isar.poolPositions.putAll(mapped);
        await _isar.pricePoints.putAll(pricePoints);
      });

      _positions = mapped;
      _lastUpdatedAt = now;
      _lastError = null;
      _controller.add(List.unmodifiable(_positions));
    } catch (e) {
      // Nunca deixa um erro do subgraph/RPC (rede, API key inválida,
      // schema inesperado) rebentar como excepção não apanhada — isso
      // deixava o ecrã silenciosamente sem dados, sem nenhuma pista
      // visível na app (só via logcat). Guarda a mensagem para a UI
      // mostrar um aviso em vez disto.
      _lastError = e.toString();
    } finally {
      _refreshing = false;
    }
  }

  @override
  void startAutoRefresh(Duration interval) {
    _autoRefreshTimer ??= Timer.periodic(interval, (_) => refreshNow());
  }

  @override
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _controller.close();
    for (final client in _clients.values) {
      client.dispose();
    }
    _rpcClient?.dispose();
  }

  PoolPosition _mapPosition(Chain chain, RawPosition raw, double ethPriceUsd) {
    final price0 = raw.pool.token0.priceUsd(ethPriceUsd);
    final price1 = raw.pool.token1.priceUsd(ethPriceUsd);

    final unclaimed = computeUnclaimedTokens(
      feeGrowthGlobal0X128: raw.pool.feeGrowthGlobal0X128,
      feeGrowthGlobal1X128: raw.pool.feeGrowthGlobal1X128,
      feeGrowthOutsideLower0X128: raw.tickLower.feeGrowthOutside0X128,
      feeGrowthOutsideLower1X128: raw.tickLower.feeGrowthOutside1X128,
      feeGrowthOutsideUpper0X128: raw.tickUpper.feeGrowthOutside0X128,
      feeGrowthOutsideUpper1X128: raw.tickUpper.feeGrowthOutside1X128,
      feeGrowthInsideLast0X128: raw.feeGrowthInside0LastX128,
      feeGrowthInsideLast1X128: raw.feeGrowthInside1LastX128,
      liquidity: raw.liquidity,
      currentTick: raw.pool.tick,
      tickLower: raw.tickLower.tickIdx,
      tickUpper: raw.tickUpper.tickIdx,
    );
    final unclaimedUsd =
        tokenAmountToDouble(unclaimed.owed0, raw.pool.token0.decimals) *
            price0 +
        tokenAmountToDouble(unclaimed.owed1, raw.pool.token1.decimals) * price1;

    final initialUsd =
        raw.depositedToken0 * price0 + raw.depositedToken1 * price1;
    // Líquido = depositado - retirado. Nunca negativo: arredondamentos do
    // subgraph podem passar ligeiramente de 0 numa posição já fechada.
    final netToken0 = raw.depositedToken0 - raw.withdrawnToken0;
    final netToken1 = raw.depositedToken1 - raw.withdrawnToken1;
    final currentUsd = (netToken0 * price0 + netToken1 * price1).clamp(
      0.0,
      double.infinity,
    );
    final claimedUsd =
        raw.collectedFeesToken0 * price0 + raw.collectedFeesToken1 * price1;

    return PoolPosition()
      ..positionKey = '${chain.name}:${raw.id}'
      ..chain = chain
      ..walletAddress = raw.owner
      ..tokenIdOnChain = raw.id
      ..token0Symbol = raw.pool.token0.symbol
      ..token1Symbol = raw.pool.token1.symbol
      ..token0Decimals = raw.pool.token0.decimals
      ..token1Decimals = raw.pool.token1.decimals
      ..feeTierBps = raw.pool.feeTierBps
      ..createdAt = raw.createdAt
      ..tickLower = raw.tickLower.tickIdx
      ..tickUpper = raw.tickUpper.tickIdx
      ..currentTick = raw.pool.tick
      // Aproximação: o subgraph não liga o tick exato do mint ao tokenId
      // do NFT — usa-se o centro do range como proxy do preço de entrada,
      // para o impermanent loss. Ver nota no topo do ficheiro.
      ..entryTick = (raw.tickLower.tickIdx + raw.tickUpper.tickIdx) ~/ 2
      ..liquidityUsd = raw.isClosed ? 0 : currentUsd
      ..initialLiquidityUsd = initialUsd
      ..feesClaimedUsd = claimedUsd
      ..feesUnclaimedUsd = unclaimedUsd
      ..gasCostUsd = 0
      ..isClosed = raw.isClosed
      ..closedAt = null;
  }

  Future<void> _refreshHistoryForPosition({
    required UniswapSubgraphClient client,
    required RawPosition raw,
    required PoolPosition position,
    required DateTime now,
  }) async {
    final shareOfPool = raw.pool.liquidity > BigInt.zero
        ? raw.liquidity.toDouble() / raw.pool.liquidity.toDouble()
        : 0.0;

    final weekAgo = now.subtract(const Duration(days: 7));
    final hourBuckets = await client.fetchPoolHourData(raw.pool.id, weekAgo);
    final dayBuckets = (await client.fetchPoolDayData(
      raw.pool.id,
      now.subtract(const Duration(days: 365)),
    )).where((b) => b.periodStart.isBefore(weekAgo));

    final snapshots = [
      for (final bucket in hourBuckets)
        FeeSnapshot()
          ..positionKey = position.positionKey
          ..timestamp = bucket.periodStart
          ..feesUsdDelta = bucket.feesUsd * shareOfPool,
      for (final bucket in dayBuckets)
        FeeSnapshot()
          ..positionKey = position.positionKey
          ..timestamp = bucket.periodStart
          ..feesUsdDelta = bucket.feesUsd * shareOfPool,
    ];

    await _isar.writeTxn(() async {
      final old = await _isar.feeSnapshots
          .filter()
          .positionKeyEqualTo(position.positionKey)
          .findAll();
      await _isar.feeSnapshots.deleteAll(old.map((s) => s.id).toList());
      await _isar.feeSnapshots.putAll(snapshots);
    });
  }
}
