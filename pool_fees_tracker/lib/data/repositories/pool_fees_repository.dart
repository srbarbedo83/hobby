import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';

/// Fonte das posições de liquidez e do seu histórico de fees. Tem duas
/// implementações: [DemoPoolFeesRepository] (dados sintéticos, sem rede) e
/// a futura implementação "live" (subgraph Uniswap + RPC).
abstract class PoolFeesRepository {
  /// Emite a lista mais recente de posições sempre que há uma atualização
  /// (live tick, refresh manual, ou poll periódico).
  Stream<List<PoolPosition>> watchPositions();

  /// Timestamp da última atualização bem sucedida.
  DateTime? get lastUpdatedAt;

  /// Histórico de fees de uma posição (para o gráfico de barras).
  Future<List<FeeSnapshot>> getFeeSnapshots(String positionKey);

  /// Força uma atualização imediata (pull-to-refresh).
  Future<void> refreshNow();

  /// Liga o refresh periódico automático (ignora se já estiver ligado).
  void startAutoRefresh(Duration interval);

  void stopAutoRefresh();

  void dispose();
}
