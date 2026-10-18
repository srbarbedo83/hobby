import 'dart:async';

import 'package:isar_community/isar.dart';

import '../../core/calc/univ3_fee_math.dart';
import '../local/chain.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import '../remote/uniswap_subgraph_client.dart';
import 'pool_fees_repository.dart';
import 'wallet_repository.dart';

/// Implementação "live": lê posições reais do subgraph Uniswap v3 e
/// calcula fees não reclamadas com a mesma fórmula do contrato
/// (`univ3_fee_math.dart`), sem precisar de uma chamada RPC.
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
/// - `gasCostUsd` fica a 0: o subgraph não guarda o custo de gás pago pelo
///   dono; isso exigiria ler o histórico de transações da wallet (ex.
///   API de um explorador). O break-even de gás no ecrã de detalhe não é
///   fiável em modo live até isto ser implementado.
/// - `closedAt` fica `null`: o subgraph não dá diretamente o timestamp em
///   que uma posição fechou (seria preciso o evento `Burn` mais recente
///   dessa posição). O ecrã de Pools mostra "Closed" sem data nesse caso.
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
  final Chain chain;
  final WalletRepository _walletRepository;
  final Isar _isar;
  final UniswapSubgraphClient _client;

  List<PoolPosition> _positions = [];
  final StreamController<List<PoolPosition>> _controller =
      StreamController.broadcast();
  DateTime? _lastUpdatedAt;
  Timer? _autoRefreshTimer;
  bool _refreshing = false;

  LivePoolFeesRepository({
    required this.chain,
    required String apiKey,
    required WalletRepository walletRepository,
    required Isar isar,
    UniswapSubgraphClient? client,
  }) : _walletRepository = walletRepository,
       _isar = isar,
       _client = client ?? UniswapSubgraphClient(chain: chain, apiKey: apiKey) {
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
  Future<List<FeeSnapshot>> getFeeSnapshots(String positionKey) {
    return _isar.feeSnapshots
        .filter()
        .positionKeyEqualTo(positionKey)
        .sortByTimestamp()
        .findAll();
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

      final result = await _client.fetchPositions(
        wallets.map((w) => w.address).toList(),
      );
      final now = DateTime.now();
      final mapped = <PoolPosition>[];
      for (final raw in result.positions) {
        final position = _mapPosition(raw, result.ethPriceUsd);
        mapped.add(position);
        // Uma posição fechada já não tem quota da pool (liquidity == 0) —
        // não há como alocar-lhe fees novas, por isso o seu histórico fica
        // congelado no que já estava guardado em Isar.
        if (!position.isClosed) {
          await _refreshHistoryForPosition(
            raw: raw,
            position: position,
            now: now,
          );
        }
      }

      await _isar.writeTxn(() async {
        await _isar.poolPositions.putAll(mapped);
      });

      _positions = mapped;
      _lastUpdatedAt = now;
      _controller.add(List.unmodifiable(_positions));
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
    _client.dispose();
  }

  PoolPosition _mapPosition(RawPosition raw, double ethPriceUsd) {
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
      ..feeTierBps = raw.pool.feeTierBps
      ..createdAt = raw.createdAt
      ..tickLower = raw.tickLower.tickIdx
      ..tickUpper = raw.tickUpper.tickIdx
      ..currentTick = raw.pool.tick
      ..liquidityUsd = raw.isClosed ? 0 : currentUsd
      ..initialLiquidityUsd = initialUsd
      ..feesClaimedUsd = claimedUsd
      ..feesUnclaimedUsd = unclaimedUsd
      ..gasCostUsd = 0
      ..isClosed = raw.isClosed
      ..closedAt = null;
  }

  Future<void> _refreshHistoryForPosition({
    required RawPosition raw,
    required PoolPosition position,
    required DateTime now,
  }) async {
    final shareOfPool = raw.pool.liquidity > BigInt.zero
        ? raw.liquidity.toDouble() / raw.pool.liquidity.toDouble()
        : 0.0;

    final weekAgo = now.subtract(const Duration(days: 7));
    final hourBuckets = await _client.fetchPoolHourData(raw.pool.id, weekAgo);
    final dayBuckets = (await _client.fetchPoolDayData(
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
