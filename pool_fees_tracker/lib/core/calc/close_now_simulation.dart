import '../../data/local/pool_position.dart';

/// Resultado de "e se fechasse esta posição agora" — a pergunta mais
/// concreta que existe sobre uma posição aberta, e que nenhum dos stats
/// existentes respondia diretamente (APR, Net vs. HODL e Gas break-even
/// todos ignoram o custo de SAIR da posição).
class CloseNowSimulation {
  /// Quanto receberias agora, em USD, ao fechar: valor atual da posição
  /// (já inclui as fees não reclamadas) mais as fees já reclamadas no
  /// passado, menos o gás estimado para a saída.
  final double netReceivedUsd;

  /// Gás estimado para fechar (decreaseLiquidity + collect + burn) — por
  /// não haver forma de simular a transação sem a executar, assume-se o
  /// mesmo valor gasto a abrir a posição (aproximação simétrica).
  final double estimatedCloseGasUsd;

  /// Lucro ou perda líquido desde a abertura, contando TUDO: capital
  /// depositado, gás já pago (mint/adds/collects) e o gás estimado para
  /// esta saída — diferente do "Net vs. HODL" existente, que não inclui
  /// nenhum custo de gás.
  final double netProfitSinceOpenUsd;

  const CloseNowSimulation({
    required this.netReceivedUsd,
    required this.estimatedCloseGasUsd,
    required this.netProfitSinceOpenUsd,
  });
}

CloseNowSimulation computeCloseNowSimulation({required PoolPosition position}) {
  final estimatedCloseGasUsd = position.gasCostUsd;
  final netReceivedUsd =
      position.liquidityUsd + position.feesClaimedUsd - estimatedCloseGasUsd;
  final netProfitSinceOpenUsd =
      netReceivedUsd - position.initialLiquidityUsd - position.gasCostUsd;
  return CloseNowSimulation(
    netReceivedUsd: netReceivedUsd,
    estimatedCloseGasUsd: estimatedCloseGasUsd,
    netProfitSinceOpenUsd: netProfitSinceOpenUsd,
  );
}
