import '../../core/calc/liquidity_profile.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import '../local/position_event.dart';
import '../local/price_point.dart';

/// Fonte das posições de liquidez e do seu histórico de fees. Tem duas
/// implementações: [DemoPoolFeesRepository] (dados sintéticos, sem rede) e
/// [LivePoolFeesRepository] (subgraph Uniswap + fórmula de fees on-chain).
abstract class PoolFeesRepository {
  /// Emite a lista mais recente de posições sempre que há uma atualização
  /// (live tick, refresh manual, ou poll periódico).
  Stream<List<PoolPosition>> watchPositions();

  /// Timestamp da última atualização bem sucedida.
  DateTime? get lastUpdatedAt;

  /// Histórico de fees de uma posição (para o gráfico de barras).
  Future<List<FeeSnapshot>> getFeeSnapshots(String positionKey);

  /// Histórico de eventos (mint, adds/removes de liquidez, collects) de
  /// uma posição, mais recente primeiro.
  Future<List<PositionEvent>> getEvents(String positionKey);

  /// Histórico de preço/tick de uma posição, ordenado por tempo — ver a
  /// nota em `PricePoint` sobre a limitação em modo Live (só regista a
  /// partir de agora, não faz backfill do histórico antigo).
  Future<List<PricePoint>> getPricePoints(String positionKey);

  /// Liquidez bruta por tick da pool desta posição, numa janela ao redor
  /// do seu range — ver `computeRangeConcentrationPct`. Lista vazia em
  /// Demo se não houver dados sintéticos, ou em Live se a pool não tiver
  /// ticks inicializados na janela (raro).
  Future<List<TickLiquidity>> getLiquidityProfile(String positionKey);

  /// Custo real de gás da posição, em USD, quando há forma de calculá-lo
  /// (só [LivePoolFeesRepository], com RPC configurado — ver a nota em
  /// `live_pool_fees_repository.dart`). `null` quando não há — o chamador
  /// usa então o valor persistido em [PoolPosition.gasCostUsd].
  Future<double?> getGasCostUsd(String positionKey);

  /// Força uma atualização imediata (pull-to-refresh).
  Future<void> refreshNow();

  /// Liga o refresh periódico automático (ignora se já estiver ligado).
  void startAutoRefresh(Duration interval);

  void stopAutoRefresh();

  void dispose();
}
