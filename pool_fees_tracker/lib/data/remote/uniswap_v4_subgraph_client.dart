import 'dart:convert';

import 'package:http/http.dart' as http;

import '../local/chain.dart';
import 'uniswap_subgraph_client.dart' show SubgraphException;

class RawV4Position {
  final String tokenId;
  final String owner;
  final DateTime createdAt;

  RawV4Position({
    required this.tokenId,
    required this.owner,
    required this.createdAt,
  });

  factory RawV4Position.fromJson(Map<String, dynamic> json) {
    return RawV4Position(
      tokenId: json['tokenId'] as String,
      owner: json['owner'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['createdAtTimestamp'] as String) * 1000,
      ),
    );
  }
}

class RawV4Token {
  final String symbol;
  final int decimals;
  final double derivedEth;

  RawV4Token({
    required this.symbol,
    required this.decimals,
    required this.derivedEth,
  });

  factory RawV4Token.fromJson(Map<String, dynamic> json) {
    return RawV4Token(
      symbol: json['symbol'] as String,
      decimals: int.parse(json['decimals'] as String),
      derivedEth: double.parse(json['derivedETH'] as String),
    );
  }

  double priceUsd(double ethPriceUsd) => derivedEth * ethPriceUsd;
}

class RawV4Pool {
  final int tick;

  RawV4Pool({required this.tick});

  factory RawV4Pool.fromJson(Map<String, dynamic> json) {
    return RawV4Pool(tick: int.parse(json['tick'] as String));
  }
}

/// Cliente para o subgraph Uniswap v4 — ao contrário do v3
/// (`UniswapSubgraphClient`), este subgraph só diz *que tokenIds* uma
/// wallet tem (`positions`), não o range/liquidez/fees de cada um: isso só
/// existe on-chain, no contrato `PositionManager` (ver
/// `uniswap_v4_position_manager_client.dart`). Este cliente só serve para:
/// 1) descobrir os tokenIds de uma wallet, e
/// 2) dado um par+fee+hooks (que vem do `PositionManager`), obter o estado
///    atual da pool (tick, preço dos tokens) para calcular o valor da
///    posição e se está dentro do range.
class UniswapV4SubgraphClient {
  final Chain chain;
  final String apiKey;
  final String? subgraphIdOverride;
  final http.Client _httpClient;

  UniswapV4SubgraphClient({
    required this.chain,
    required this.apiKey,
    this.subgraphIdOverride,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Uri get _endpoint {
    final subgraphId = (subgraphIdOverride != null && subgraphIdOverride!.isNotEmpty)
        ? subgraphIdOverride
        : chain.uniswapV4SubgraphId;
    if (subgraphId == null) {
      throw SubgraphException(
        'No Uniswap v4 subgraph known for ${chain.displayName}',
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
    final response = await _httpClient
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'query': query, 'variables': variables}),
        )
        // Ver nota equivalente em `uniswap_subgraph_client.dart` — sem
        // isto, um pedido pendurado deixava o refresh v4 preso para
        // sempre, sem nunca mostrar posições NEM o banner de erro.
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw SubgraphException('HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['errors'] != null) {
      throw SubgraphException(decoded['errors'].toString());
    }
    return decoded['data'] as Map<String, dynamic>;
  }

  /// Todos os NFTs de posição v4 (tokenId) que um conjunto de endereços
  /// detém atualmente. Não diz nada sobre o range/liquidez/pool — isso vem
  /// depois do `PositionManager`, por tokenId.
  Future<List<RawV4Position>> fetchPositionTokenIds(
    List<String> owners,
  ) async {
    if (owners.isEmpty) return const [];
    const query = r'''
      query V4Positions($owners: [String!]!) {
        positions(where: { owner_in: $owners }, first: 500) {
          tokenId
          owner
          createdAtTimestamp
        }
      }
    ''';
    final data = await _post(query, {
      'owners': owners.map((o) => o.toLowerCase()).toList(),
    });
    final positions = (data['positions'] as List).cast<Map<String, dynamic>>();
    return positions.map(RawV4Position.fromJson).toList();
  }

  /// Estado atual da pool identificada por `token0/token1/feeTier/hooks`
  /// (o `PoolKey` que vem de `getPoolAndPositionInfo`) — `null` se essa pool
  /// ainda não estiver indexada pelo subgraph (raro, mas uma pool pode
  /// existir on-chain antes do subgraph a indexar).
  ///
  /// De propósito NÃO pede `token0 { ... }`/`token1 { ... }` aninhado dentro
  /// de `pools` (como no v3): no v4, uma pool pode ter ETH nativo como
  /// `currency0`/`currency1` (endereço `0x000...000`), e nem todo indexador
  /// cria uma entidade `Token` sintética para esse endereço — pedir esse
  /// campo aninhado como não-nulo rebentaria a query toda. Em vez disso,
  /// [fetchToken] é chamado à parte, por endereço, onde `null` é um
  /// resultado válido (ver `_mapV4Position`).
  Future<({RawV4Pool pool, double ethPriceUsd})?> fetchPoolByKey({
    required String token0,
    required String token1,
    required int feeTier,
    required String hooks,
  }) async {
    const query = r'''
      query V4Pool($token0: String!, $token1: String!, $feeTier: BigInt!, $hooks: String!) {
        pools(
          where: { token0: $token0, token1: $token1, feeTier: $feeTier, hooks: $hooks }
          first: 1
        ) {
          tick
        }
        bundle(id: "1") { ethPriceUSD }
      }
    ''';
    final data = await _post(query, {
      'token0': token0.toLowerCase(),
      'token1': token1.toLowerCase(),
      'feeTier': feeTier.toString(),
      'hooks': hooks.toLowerCase(),
    });
    final pools = (data['pools'] as List).cast<Map<String, dynamic>>();
    if (pools.isEmpty) return null;
    final ethPriceUsd = double.parse(
      (data['bundle']?['ethPriceUSD'] as String?) ?? '0',
    );
    return (pool: RawV4Pool.fromJson(pools.first), ethPriceUsd: ethPriceUsd);
  }

  /// `null` se o endereço não tiver uma entidade `Token` indexada — o caso
  /// mais comum é o endereço zero (ETH nativo numa pool v4), que o
  /// chamador deve tratar à parte (símbolo/decimais da native currency da
  /// chain, preço = `ethPriceUsd`).
  Future<RawV4Token?> fetchToken(String address) async {
    const query = r'''
      query V4Token($id: ID!) {
        token(id: $id) { symbol decimals derivedETH }
      }
    ''';
    final data = await _post(query, {'id': address.toLowerCase()});
    final token = data['token'] as Map<String, dynamic>?;
    return token == null ? null : RawV4Token.fromJson(token);
  }

  void dispose() => _httpClient.close();
}
