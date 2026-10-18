import 'dart:async';
import 'dart:math';

import '../local/chain.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import '../local/position_event.dart';
import 'pool_fees_repository.dart';

/// Repositório de demonstração: gera posições e histórico de fees
/// sintéticos (sem rede, sem wallet real) e simula acréscimos "em direto" a
/// cada poucos segundos, para a app ser utilizável e testável sem
/// credenciais de subgraph/RPC configuradas.
class DemoPoolFeesRepository implements PoolFeesRepository {
  final List<PoolPosition> _positions = [];
  final Map<String, List<FeeSnapshot>> _snapshotsByKey = {};
  final Map<String, List<PositionEvent>> _eventsByKey = {};
  final StreamController<List<PoolPosition>> _controller =
      StreamController.broadcast();
  final Random _rng = Random(7);

  /// Decimais reais dos tokens usados nos dados de demo — para que o preço
  /// derivado dos ticks (ver `priceAtTick`) saia num valor plausível, não
  /// só uma fração 0..1.
  static const _decimalsBySymbol = {
    'ETH': 18,
    'WBTC': 8,
    'ARB': 18,
    'USDC': 6,
    'USDT': 6,
    'DAI': 18,
  };

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
  Future<List<PositionEvent>> getEvents(String positionKey) async {
    return List.unmodifiable(_eventsByKey[positionKey] ?? const []);
  }

  @override
  Future<double?> getGasCostUsd(String positionKey) async {
    // Em Demo não há RPC nem transações reais — o valor sintético já
    // definido em PoolPosition.gasCostUsd é a única fonte.
    return null;
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
        // Deslocados de um "base tick" realista para ETH/USDC (~$1,850 —
        // ver priceAtTick) em vez de ticks pequenos arbitrários; a largura
        // do range e os deltas para o entryTick ficam exatamente iguais
        // aos valores originais (-100/100/20/-40), só a magnitude muda.
        tickLower: -201180,
        tickUpper: -200980,
        currentTick: -201060,
        entryTick: -201120,
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
        // Base realista para WBTC/ETH (~32 ETH por WBTC); mesma largura e
        // deltas que os ticks pequenos originais (-200/200/-30/50).
        tickLower: 264860,
        tickUpper: 265260,
        currentTick: 265030,
        entryTick: 265110,
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
        // Base realista para ARB/ETH (~0.00043, i.e. ARB ≈ $0.80 a
        // ETH=$1,850); mesma largura e deltas que os ticks originais
        // (-50/50/80/-20) — inclui "fora do range" acima do máximo.
        tickLower: -77510,
        tickUpper: -77410,
        currentTick: -77380,
        entryTick: -77480,
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
        entryTick: 10,
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
        // Base realista para DAI/ETH (~0.00054, i.e. 1 ETH ≈ $1,850 em
        // DAI); mesma largura e deltas que os ticks originais
        // (-150/150/0/-100).
        tickLower: -75390,
        tickUpper: -75090,
        currentTick: -75240,
        entryTick: -75340,
      ),
      // Numa chain diferente (Arbitrum) — mostra que a app agrega fees de
      // várias chains no mesmo total, não só da chain "principal".
      _PositionSpec(
        chain: Chain.arbitrum,
        tokenId: '88214',
        token0: 'ETH',
        token1: 'USDC',
        feeTierBps: 500,
        daysAgo: 25,
        liquidityUsd: 3200,
        initialLiquidityUsd: 3000,
        feesClaimedUsd: 40,
        feesUnclaimedUsd: 22.50,
        gasCostUsd: 2,
        // Mesma base de ETH/USDC do primeiro exemplo; mesma largura e
        // deltas que os ticks originais (-80/80/10/-5).
        tickLower: -201160,
        tickUpper: -201000,
        currentTick: -201070,
        entryTick: -201085,
      ),
    ];

    for (var i = 0; i < specs.length; i++) {
      final spec = specs[i];
      final closedAt = spec.closedDaysAgo != null
          ? now.subtract(Duration(days: spec.closedDaysAgo!))
          : null;
      final position = PoolPosition()
        ..positionKey = '${spec.chain.name}:${spec.tokenId}'
        ..chain = spec.chain
        ..walletAddress = wallet
        ..tokenIdOnChain = spec.tokenId
        ..token0Symbol = spec.token0
        ..token1Symbol = spec.token1
        ..token0Decimals = _decimalsBySymbol[spec.token0] ?? 18
        ..token1Decimals = _decimalsBySymbol[spec.token1] ?? 18
        ..feeTierBps = spec.feeTierBps
        ..createdAt = now.subtract(Duration(days: spec.daysAgo))
        ..tickLower = spec.tickLower
        ..tickUpper = spec.tickUpper
        ..currentTick = spec.currentTick
        ..entryTick = spec.entryTick
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
      _eventsByKey[position.positionKey] = _buildEvents(position);
    }

    _lastUpdatedAt = now;
  }

  /// Linha do tempo sintética: mint na abertura, dois collects a meio da
  /// vida da posição (repartindo as fees já reclamadas), e — se a posição
  /// estiver fechada — um collect final seguido da remoção de liquidez.
  List<PositionEvent> _buildEvents(PoolPosition position) {
    final events = <PositionEvent>[
      PositionEvent()
        ..positionKey = position.positionKey
        ..timestamp = position.createdAt
        ..type = PositionEventType.mint
        ..amountUsd = position.initialLiquidityUsd,
    ];

    final lifetimeEnd = position.closedAt ?? DateTime.now();
    final lifetime = lifetimeEnd.difference(position.createdAt);

    if (position.feesClaimedUsd > 0) {
      final collectFractions = position.isClosed
          ? [0.4, 0.75, 1.0]
          : [0.35, 0.7];
      final perCollect = position.feesClaimedUsd / collectFractions.length;
      for (final fraction in collectFractions) {
        events.add(
          PositionEvent()
            ..positionKey = position.positionKey
            ..timestamp = position.createdAt.add(
              Duration(
                seconds: (lifetime.inSeconds * fraction).round().clamp(
                  0,
                  lifetime.inSeconds,
                ),
              ),
            )
            ..type = PositionEventType.collect
            ..amountUsd = perCollect,
        );
      }
    }

    if (position.isClosed) {
      events.add(
        PositionEvent()
          ..positionKey = position.positionKey
          ..timestamp = lifetimeEnd
          ..type = PositionEventType.decreaseLiquidity
          ..amountUsd = position.initialLiquidityUsd,
      );
    }

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
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
  final Chain chain;
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
  final int entryTick;

  /// `null` = posição ainda aberta; caso contrário, há quantos dias foi
  /// fechada (toda a liquidez removida).
  final int? closedDaysAgo;

  const _PositionSpec({
    this.chain = Chain.ethereum,
    required this.tokenId,
    required this.token0,
    required this.token1,
    required this.feeTierBps,
    required this.daysAgo,
    required this.liquidityUsd,
    required this.initialLiquidityUsd,
    required this.feesClaimedUsd,
    required this.feesUnclaimedUsd,
    required this.entryTick,
    required this.gasCostUsd,
    required this.tickLower,
    required this.tickUpper,
    required this.currentTick,
    this.closedDaysAgo,
  });
}
