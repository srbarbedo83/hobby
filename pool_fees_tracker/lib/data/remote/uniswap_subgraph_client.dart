import 'dart:convert';

import 'package:http/http.dart' as http;

import '../local/chain.dart';

class SubgraphException implements Exception {
  final String message;

  SubgraphException(this.message);

  @override
  String toString() => 'SubgraphException: $message';
}

class RawToken {
  final String symbol;
  final int decimals;

  /// Preço do token em ETH, como o subgraph da Uniswap o deriva a partir
  /// dos pools mais líquidos — combinado com `Bundle.ethPriceUSD` dá o
  /// preço em USD sem precisar de uma segunda API de preços.
  final double derivedEth;

  RawToken({
    required this.symbol,
    required this.decimals,
    required this.derivedEth,
  });

  factory RawToken.fromJson(Map<String, dynamic> json) {
    return RawToken(
      symbol: json['symbol'] as String,
      decimals: int.parse(json['decimals'] as String),
      derivedEth: double.parse(json['derivedETH'] as String),
    );
  }

  double priceUsd(double ethPriceUsd) => derivedEth * ethPriceUsd;
}

class RawPool {
  final String id;
  final int tick;
  final int feeTierBps;
  final BigInt liquidity;
  final BigInt feeGrowthGlobal0X128;
  final BigInt feeGrowthGlobal1X128;
  final RawToken token0;
  final RawToken token1;

  RawPool({
    required this.id,
    required this.tick,
    required this.feeTierBps,
    required this.liquidity,
    required this.feeGrowthGlobal0X128,
    required this.feeGrowthGlobal1X128,
    required this.token0,
    required this.token1,
  });

  factory RawPool.fromJson(Map<String, dynamic> json) {
    return RawPool(
      id: json['id'] as String,
      tick: int.parse(json['tick'] as String),
      feeTierBps: int.parse(json['feeTier'] as String),
      liquidity: BigInt.parse(json['liquidity'] as String),
      feeGrowthGlobal0X128: BigInt.parse(
        json['feeGrowthGlobal0X128'] as String,
      ),
      feeGrowthGlobal1X128: BigInt.parse(
        json['feeGrowthGlobal1X128'] as String,
      ),
      token0: RawToken.fromJson(json['token0'] as Map<String, dynamic>),
      token1: RawToken.fromJson(json['token1'] as Map<String, dynamic>),
    );
  }
}

class RawTick {
  final int tickIdx;
  final BigInt feeGrowthOutside0X128;
  final BigInt feeGrowthOutside1X128;

  RawTick({
    required this.tickIdx,
    required this.feeGrowthOutside0X128,
    required this.feeGrowthOutside1X128,
  });

  factory RawTick.fromJson(Map<String, dynamic> json) {
    return RawTick(
      tickIdx: int.parse(json['tickIdx'] as String),
      feeGrowthOutside0X128: BigInt.parse(
        json['feeGrowthOutside0X128'] as String,
      ),
      feeGrowthOutside1X128: BigInt.parse(
        json['feeGrowthOutside1X128'] as String,
      ),
    );
  }
}

class RawPosition {
  final String id; // = NFT token id
  final String owner;
  final BigInt liquidity;
  final double depositedToken0;
  final double depositedToken1;
  final double withdrawnToken0;
  final double withdrawnToken1;
  final double collectedFeesToken0;
  final double collectedFeesToken1;
  final BigInt feeGrowthInside0LastX128;
  final BigInt feeGrowthInside1LastX128;
  final RawTick tickLower;
  final RawTick tickUpper;
  final DateTime createdAt;
  final RawPool pool;

  /// `liquidity == 0` quer dizer que toda a liquidez foi removida — a
  /// posição está fechada, mas as suas fees continuam válidas/históricas.
  bool get isClosed => liquidity == BigInt.zero;

  RawPosition({
    required this.id,
    required this.owner,
    required this.liquidity,
    required this.depositedToken0,
    required this.depositedToken1,
    required this.withdrawnToken0,
    required this.withdrawnToken1,
    required this.collectedFeesToken0,
    required this.collectedFeesToken1,
    required this.feeGrowthInside0LastX128,
    required this.feeGrowthInside1LastX128,
    required this.tickLower,
    required this.tickUpper,
    required this.createdAt,
    required this.pool,
  });

  factory RawPosition.fromJson(Map<String, dynamic> json) {
    return RawPosition(
      id: json['id'] as String,
      owner: json['owner'] as String,
      liquidity: BigInt.parse(json['liquidity'] as String),
      depositedToken0: double.parse(json['depositedToken0'] as String),
      depositedToken1: double.parse(json['depositedToken1'] as String),
      withdrawnToken0: double.parse(json['withdrawnToken0'] as String),
      withdrawnToken1: double.parse(json['withdrawnToken1'] as String),
      collectedFeesToken0: double.parse(json['collectedFeesToken0'] as String),
      collectedFeesToken1: double.parse(json['collectedFeesToken1'] as String),
      feeGrowthInside0LastX128: BigInt.parse(
        json['feeGrowthInside0LastX128'] as String,
      ),
      feeGrowthInside1LastX128: BigInt.parse(
        json['feeGrowthInside1LastX128'] as String,
      ),
      tickLower: RawTick.fromJson(json['tickLower'] as Map<String, dynamic>),
      tickUpper: RawTick.fromJson(json['tickUpper'] as Map<String, dynamic>),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['transaction']['timestamp'] as String) * 1000,
      ),
      pool: RawPool.fromJson(json['pool'] as Map<String, dynamic>),
    );
  }
}

enum RawEventKind { mint, collect, burn }

class RawPositionEvent {
  final RawEventKind kind;
  final DateTime timestamp;
  final double amountUsd;
  final String? txHash;

  RawPositionEvent({
    required this.kind,
    required this.timestamp,
    required this.amountUsd,
    required this.txHash,
  });

  factory RawPositionEvent.fromJson(
    Map<String, dynamic> json,
    RawEventKind kind,
  ) {
    return RawPositionEvent(
      kind: kind,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['timestamp'] as String) * 1000,
      ),
      amountUsd: double.parse(json['amountUSD'] as String),
      txHash: (json['transaction'] as Map<String, dynamic>?)?['id'] as String?,
    );
  }
}

class RawFeeBucket {
  final DateTime periodStart;
  final double feesUsd;
  final BigInt poolLiquidityAtBucket;

  RawFeeBucket({
    required this.periodStart,
    required this.feesUsd,
    required this.poolLiquidityAtBucket,
  });

  factory RawFeeBucket.fromJson(
    Map<String, dynamic> json, {
    required String startField,
  }) {
    return RawFeeBucket(
      periodStart: DateTime.fromMillisecondsSinceEpoch(
        (json[startField] as int) * 1000,
      ),
      feesUsd: double.parse(json['feesUSD'] as String),
      poolLiquidityAtBucket: BigInt.parse(json['liquidity'] as String),
    );
  }
}

/// Cliente fino para o subgraph Uniswap v3 publicado na rede descentralizada
/// do The Graph. Usa `http` em vez de um package de GraphQL dedicado — as
/// queries são pequenas e fixas, não vale a pena a dependência extra.
class UniswapSubgraphClient {
  final Chain chain;
  final String apiKey;
  final http.Client _httpClient;

  UniswapSubgraphClient({
    required this.chain,
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Uri get _endpoint {
    final subgraphId = chain.uniswapV3SubgraphId;
    if (subgraphId == null) {
      throw SubgraphException(
        'No Uniswap v3 subgraph known for ${chain.displayName}',
      );
    }
    return Uri.parse(
      'https://gateway.thegraph.com/api/$apiKey/subgraphs/id/$subgraphId',
    );
  }

  Future<Map<String, dynamic>> _post(
    String query,
    Map<String, dynamic> variables,
  ) async {
    final response = await _httpClient.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'variables': variables}),
    );
    if (response.statusCode != 200) {
      throw SubgraphException('HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['errors'] != null) {
      throw SubgraphException(decoded['errors'].toString());
    }
    return decoded['data'] as Map<String, dynamic>;
  }

  /// Todas as posições (abertas e fechadas) de um conjunto de endereços
  /// (owner do NFT), e o preço de ETH em USD do mesmo bloco (para converter
  /// os tokens). Inclui as fechadas (`liquidity == 0`) de propósito — as
  /// suas fees continuam a contar para o total vitalício; ver
  /// `RawPosition.isClosed` e a nota em `LivePoolFeesRepository`.
  Future<({List<RawPosition> positions, double ethPriceUsd})> fetchPositions(
    List<String> owners,
  ) async {
    if (owners.isEmpty) return (positions: <RawPosition>[], ethPriceUsd: 0.0);
    const query = r'''
      query Positions($owners: [String!]!) {
        positions(where: { owner_in: $owners }, first: 500) {
          id
          owner
          liquidity
          depositedToken0
          depositedToken1
          withdrawnToken0
          withdrawnToken1
          collectedFeesToken0
          collectedFeesToken1
          feeGrowthInside0LastX128
          feeGrowthInside1LastX128
          tickLower { tickIdx feeGrowthOutside0X128 feeGrowthOutside1X128 }
          tickUpper { tickIdx feeGrowthOutside0X128 feeGrowthOutside1X128 }
          transaction { timestamp }
          pool {
            id
            tick
            feeTier
            liquidity
            feeGrowthGlobal0X128
            feeGrowthGlobal1X128
            token0 { symbol decimals derivedETH }
            token1 { symbol decimals derivedETH }
          }
        }
        bundle(id: "1") { ethPriceUSD }
      }
    ''';
    final data = await _post(query, {
      'owners': owners.map((o) => o.toLowerCase()).toList(),
    });
    final positions = (data['positions'] as List).cast<Map<String, dynamic>>();
    final ethPriceUsd = double.parse(
      (data['bundle']?['ethPriceUSD'] as String?) ?? '0',
    );
    return (
      positions: positions.map(RawPosition.fromJson).toList(),
      ethPriceUsd: ethPriceUsd,
    );
  }

  /// Histórico de fees da POOL (não da posição — ver nota de aproximação em
  /// `LivePoolFeesRepository`), em buckets horários.
  Future<List<RawFeeBucket>> fetchPoolHourData(
    String poolId,
    DateTime since,
  ) async {
    const query = r'''
      query PoolHourData($poolId: String!, $since: Int!) {
        poolHourDatas(
          where: { pool: $poolId, periodStartUnix_gte: $since }
          orderBy: periodStartUnix
          first: 1000
        ) {
          periodStartUnix
          feesUSD
          liquidity
        }
      }
    ''';
    final data = await _post(query, {
      'poolId': poolId,
      'since': since.millisecondsSinceEpoch ~/ 1000,
    });
    final buckets = (data['poolHourDatas'] as List)
        .cast<Map<String, dynamic>>();
    return buckets
        .map((b) => RawFeeBucket.fromJson(b, startField: 'periodStartUnix'))
        .toList();
  }

  /// O mesmo, mas em buckets diários — usado para intervalos mais longos
  /// (30D/90D/ALL) para não pedir milhares de pontos horários.
  Future<List<RawFeeBucket>> fetchPoolDayData(
    String poolId,
    DateTime since,
  ) async {
    const query = r'''
      query PoolDayData($poolId: String!, $since: Int!) {
        poolDayDatas(
          where: { pool: $poolId, date_gte: $since }
          orderBy: date
          first: 1000
        ) {
          date
          feesUSD
          liquidity
        }
      }
    ''';
    final data = await _post(query, {
      'poolId': poolId,
      'since': since.millisecondsSinceEpoch ~/ 1000,
    });
    final buckets = (data['poolDayDatas'] as List).cast<Map<String, dynamic>>();
    return buckets
        .map((b) => RawFeeBucket.fromJson(b, startField: 'date'))
        .toList();
  }

  /// Eventos (mint, collect, burn) de uma posição, aproximados por
  /// `pool + owner + tickLower + tickUpper` — o subgraph não liga estes
  /// eventos diretamente ao tokenId do NFT (esse mapeamento só existe no
  /// `NonfungiblePositionManager`, fora do subgraph de pools). Isto é
  /// preciso quando o par (owner, tickLower, tickUpper) é único para essa
  /// pool, o que é o caso normal; se o mesmo dono abrir duas posições
  /// exatamente no mesmo range na mesma pool, os eventos das duas
  /// aparecem misturados.
  Future<List<RawPositionEvent>> fetchPositionEvents({
    required String poolId,
    required String owner,
    required int tickLower,
    required int tickUpper,
  }) async {
    const query = r'''
      query PositionEvents($pool: String!, $owner: String!, $tickLower: Int!, $tickUpper: Int!) {
        mints(
          where: { pool: $pool, owner: $owner, tickLower: $tickLower, tickUpper: $tickUpper }
          orderBy: timestamp, orderDirection: desc, first: 50
        ) {
          timestamp
          amountUSD
          transaction { id }
        }
        collects(
          where: { pool: $pool, owner: $owner, tickLower: $tickLower, tickUpper: $tickUpper }
          orderBy: timestamp, orderDirection: desc, first: 50
        ) {
          timestamp
          amountUSD
          transaction { id }
        }
        burns(
          where: { pool: $pool, owner: $owner, tickLower: $tickLower, tickUpper: $tickUpper }
          orderBy: timestamp, orderDirection: desc, first: 50
        ) {
          timestamp
          amountUSD
          transaction { id }
        }
      }
    ''';
    final data = await _post(query, {
      'pool': poolId,
      'owner': owner.toLowerCase(),
      'tickLower': tickLower,
      'tickUpper': tickUpper,
    });

    final events = <RawPositionEvent>[
      for (final m in (data['mints'] as List).cast<Map<String, dynamic>>())
        RawPositionEvent.fromJson(m, RawEventKind.mint),
      for (final c in (data['collects'] as List).cast<Map<String, dynamic>>())
        RawPositionEvent.fromJson(c, RawEventKind.collect),
      for (final b in (data['burns'] as List).cast<Map<String, dynamic>>())
        RawPositionEvent.fromJson(b, RawEventKind.burn),
    ];
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  void dispose() => _httpClient.close();
}
