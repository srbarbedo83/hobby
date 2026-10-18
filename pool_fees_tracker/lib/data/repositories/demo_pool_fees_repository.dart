import 'dart:async';
import 'dart:math';

import '../local/chain.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import 'pool_fees_repository.dart';

/// Repositório de demonstração: gera posições e histórico de fees
/// sintéticos (sem rede, sem wallet real) e simula acréscimos "em direto" a
/// cada poucos segundos, para a app ser utilizável e testável sem
/// credenciais de subgraph/RPC configuradas.
class DemoPoolFeesRepository implements PoolFeesRepository {
  final List<PoolPosition> _positions = [];
  final Map<String, List<FeeSnapshot>> _snapshotsByKey = {};
  final StreamController<List<PoolPosition>> _controller =
      StreamController.broadcast();
  final Random _rng = Random(7);

  Timer? _liveTimer;
  Timer? _autoRefreshTimer;
  DateTime? _lastUpdatedAt;

  DemoPoolFeesRepository() {
    _generateDemoData();
    _liveTimer = Timer.periodic(const Duration(seconds: 4), (_) => _tickLive());
  }

  @override
  Stream<List<PoolPosition>> watchPositions() async* {
    yield List.unmodifiable(_positions);
    yield* _controller.stream;
  }

  @override
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  @override
  Future<List<FeeSnapshot>> getFeeSnapshots(String positionKey) async {
    return List.unmodifiable(_snapshotsByKey[positionKey] ?? const []);
  }

  @override
  Future<void> refreshNow() async => _tickLive();

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
    _liveTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _controller.close();
  }

  void _tickLive() {
    final now = DateTime.now();
    for (final p in _positions) {
      // Uma posição fechada não gera mais fees — só as que ainda têm
      // liquidez acumulam em direto.
      if (p.isClosed) continue;
      final bump = 0.01 + _rng.nextDouble() * 0.12;
      p.feesUnclaimedUsd += bump;
      _snapshotsByKey[p.positionKey]!.add(
        FeeSnapshot()
          ..positionKey = p.positionKey
          ..timestamp = now
          ..feesUsdDelta = bump,
      );
    }
    _lastUpdatedAt = now;
    _controller.add(List.unmodifiable(_positions));
  }

  void _generateDemoData() {
    final now = DateTime.now();
    const wallet = '0x7a3fbeeb1a9c8f9b4e2f0b3c9d6a8f1e2c4b6a21';

    final specs = [
      _PositionSpec(
        tokenId: '418291',
        token0: 'ETH',
        token1: 'USDC',
        feeTierBps: 500,
        daysAgo: 42,
        liquidityUsd: 8450,
        initialLiquidityUsd: 7900,
        feesClaimedUsd: 300,
        feesUnclaimedUsd: 182.10,
        gasCostUsd: 45,
        tickLower: -100,
        tickUpper: 100,
        currentTick: 20,
      ),
      _PositionSpec(
        tokenId: '418355',
        token0: 'WBTC',
        token1: 'ETH',
        feeTierBps: 3000,
        daysAgo: 75,
        liquidityUsd: 5600,
        initialLiquidityUsd: 5250,
        feesClaimedUsd: 200,
        feesUnclaimedUsd: 110.55,
        gasCostUsd: 60,
        tickLower: -200,
        tickUpper: 200,
        currentTick: -30,
      ),
      _PositionSpec(
        tokenId: '419042',
        token0: 'ARB',
        token1: 'ETH',
        feeTierBps: 10000,
        daysAgo: 18,
        liquidityUsd: 1240,
        initialLiquidityUsd: 1180,
        feesClaimedUsd: 60,
        feesUnclaimedUsd: 36.20,
        gasCostUsd: 35,
        tickLower: -50,
        tickUpper: 50,
        currentTick: 80,
      ),
      _PositionSpec(
        tokenId: '419501',
        token0: 'USDC',
        token1: 'USDT',
        feeTierBps: 100,
        daysAgo: 10,
        liquidityUsd: 9200,
        initialLiquidityUsd: 9180,
        feesClaimedUsd: 10,
        feesUnclaimedUsd: 8.90,
        gasCostUsd: 20,
        tickLower: -10,
        tickUpper: 10,
        currentTick: 9,
      ),
      // Posição FECHADA: toda a liquidez foi removida (ex.: para a
      // redeployar numa pool nova). As fees ficam congeladas no valor final
      // — isto existe para mostrar que o total vitalício do dashboard
      // continua a contá-las mesmo depois de a posição desaparecer da
      // lista "Your Pools".
      _PositionSpec(
        tokenId: '417102',
        token0: 'DAI',
        token1: 'ETH',
        feeTierBps: 3000,
        daysAgo: 60,
        closedDaysAgo: 5,
        liquidityUsd: 0,
        initialLiquidityUsd: 3000,
        feesClaimedUsd: 145.30,
        feesUnclaimedUsd: 0,
        gasCostUsd: 55,
        tickLower: -150,
        tickUpper: 150,
        currentTick: 0,
      ),
    ];

    for (var i = 0; i < specs.length; i++) {
      final spec = specs[i];
      final closedAt = spec.closedDaysAgo != null
          ? now.subtract(Duration(days: spec.closedDaysAgo!))
          : null;
      final position = PoolPosition()
        ..positionKey = '${Chain.ethereum.name}:${spec.tokenId}'
        ..chain = Chain.ethereum
        ..walletAddress = wallet
        ..tokenIdOnChain = spec.tokenId
        ..token0Symbol = spec.token0
        ..token1Symbol = spec.token1
        ..feeTierBps = spec.feeTierBps
        ..createdAt = now.subtract(Duration(days: spec.daysAgo))
        ..tickLower = spec.tickLower
        ..tickUpper = spec.tickUpper
        ..currentTick = spec.currentTick
        ..liquidityUsd = spec.liquidityUsd
        ..initialLiquidityUsd = spec.initialLiquidityUsd
        ..feesClaimedUsd = spec.feesClaimedUsd
        ..feesUnclaimedUsd = spec.feesUnclaimedUsd
        ..gasCostUsd = spec.gasCostUsd
        ..isClosed = closedAt != null
        ..closedAt = closedAt;

      _positions.add(position);
      _snapshotsByKey[position.positionKey] = _buildHistory(
        positionKey: position.positionKey,
        createdAt: position.createdAt,
        until: closedAt ?? now,
        totalFeesUsd: position.feesTotalUsd,
        seed: i + 1,
      );
    }

    _lastUpdatedAt = now;
  }

  /// Reparte [totalFeesUsd] por snapshots horários entre [createdAt] e
  /// [until] (agora, ou o momento em que a posição foi fechada), com um
  /// padrão pseudo-aleatório (mais atividade em "horas de dia") cuja soma
  /// bate certo com o total — assim o gráfico e o "desde a abertura" nunca
  /// se contradizem.
  List<FeeSnapshot> _buildHistory({
    required String positionKey,
    required DateTime createdAt,
    required DateTime until,
    required double totalFeesUsd,
    required int seed,
  }) {
    final rng = Random(seed * 1000 + 13);
    final totalHours = until.difference(createdAt).inHours;
    if (totalHours <= 0) return [];

    final weights = <double>[];
    for (var h = 0; h < totalHours; h++) {
      final hourOfDay = createdAt.add(Duration(hours: h)).hour;
      final dayCycle = 0.6 + 0.4 * sin((hourOfDay - 6) / 24 * 2 * pi);
      weights.add(dayCycle * (0.3 + rng.nextDouble()));
    }
    final weightSum = weights.fold<double>(0, (a, b) => a + b);

    final snapshots = <FeeSnapshot>[];
    for (var h = 0; h < totalHours; h++) {
      final timestamp = createdAt.add(Duration(hours: h + 1));
      final delta = weightSum == 0
          ? 0.0
          : totalFeesUsd * weights[h] / weightSum;
      snapshots.add(
        FeeSnapshot()
          ..positionKey = positionKey
          ..timestamp = timestamp
          ..feesUsdDelta = delta,
      );
    }
    return snapshots;
  }
}

class _PositionSpec {
  final String tokenId;
  final String token0;
  final String token1;
  final int feeTierBps;
  final int daysAgo;
  final double liquidityUsd;
  final double initialLiquidityUsd;
  final double feesClaimedUsd;
  final double feesUnclaimedUsd;
  final double gasCostUsd;
  final int tickLower;
  final int tickUpper;
  final int currentTick;

  /// `null` = posição ainda aberta; caso contrário, há quantos dias foi
  /// fechada (toda a liquidez removida).
  final int? closedDaysAgo;

  const _PositionSpec({
    required this.tokenId,
    required this.token0,
    required this.token1,
    required this.feeTierBps,
    required this.daysAgo,
    required this.liquidityUsd,
    required this.initialLiquidityUsd,
    required this.feesClaimedUsd,
    required this.feesUnclaimedUsd,
    required this.gasCostUsd,
    required this.tickLower,
    required this.tickUpper,
    required this.currentTick,
    this.closedDaysAgo,
  });
}
