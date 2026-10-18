import 'package:isar_community/isar.dart';

import 'chain.dart';

part 'pool_position.g.dart';

/// Uma posição de liquidez (NFT) numa pool Uniswap v3/v4, com o estado mais
/// recente conhecido (TVL, fees, range). O histórico de fees vive em
/// [FeeSnapshot], indexado por [positionKey].
@collection
class PoolPosition {
  Id id = Isar.autoIncrement;

  /// Chave estável `chain:tokenIdOnChain`, usada para ligar aos snapshots.
  @Index(unique: true, replace: true)
  late String positionKey;

  @Enumerated(EnumType.name)
  late Chain chain;

  @Index()
  late String walletAddress;

  late String tokenIdOnChain;

  late String token0Symbol;
  late String token1Symbol;

  /// Fee tier em basis points (500 = 0.05%, 3000 = 0.3%, 10000 = 1%).
  late int feeTierBps;

  /// Quando a posição foi criada (timestamp do bloco de mint do NFT).
  late DateTime createdAt;

  late int tickLower;
  late int tickUpper;
  late int currentTick;

  /// Tick da pool no momento em que a posição foi criada — usado para
  /// estimar o impermanent loss (variação de preço desde a abertura).
  /// Em modo Live é uma aproximação (ponto médio do range, por o subgraph
  /// não guardar o tick exato do mint ligado ao tokenId do NFT); em modo
  /// Demo é o valor exato definido nos dados sintéticos.
  late int entryTick;

  /// Valor atual da posição (token0 + token1) em USD.
  late double liquidityUsd;

  /// Capital depositado na criação da posição, em USD — base para o P&L
  /// "desde a abertura".
  late double initialLiquidityUsd;

  /// Fees já reclamadas (collect) acumuladas, em USD.
  late double feesClaimedUsd;

  /// Fees geradas mas ainda não reclamadas, em USD.
  late double feesUnclaimedUsd;

  /// Custo total de gás gasto nesta posição (mint + adds + collects), em USD.
  late double gasCostUsd;

  /// Verdadeiro quando toda a liquidez foi removida (posição fechada/NFT
  /// com `liquidity == 0`). Uma posição fechada deixa de aparecer na lista
  /// de "Your Pools" (não faz sentido mostrar range/APR dela), mas as suas
  /// fees continuam a contar para o total vitalício — ver nota em
  /// [dashboard_metrics.dart].
  bool isClosed = false;

  /// Quando a posição foi fechada, se conhecido. Em modo Live fica `null`
  /// (o subgraph não guarda isso de forma simples — ver nota em
  /// `live_pool_fees_repository.dart`); em modo Demo é preenchido.
  DateTime? closedAt;

  double get feesTotalUsd => feesClaimedUsd + feesUnclaimedUsd;

  double get feeTierPct => feeTierBps / 10000;
}
