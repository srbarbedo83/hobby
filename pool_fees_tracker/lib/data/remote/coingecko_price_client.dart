import 'dart:convert';

import 'package:http/http.dart' as http;

class CoinGeckoPriceException implements Exception {
  final String message;

  CoinGeckoPriceException(this.message);

  @override
  String toString() => 'CoinGeckoPriceException: $message';
}

/// Preço USD dos tokens de posições v4, via API pública da CoinGecko — não
/// depende em nada do subgraph Uniswap (que se mostrou globalmente não
/// fiável nesta sessão, mesmo só para o preço/estado da pool: "bad
/// indexers" ou timeout, em todas as posições testadas da wallet real do
/// utilizador). Chamada pelo endereço do contrato, funciona para qualquer
/// ERC-20 — mesmo um que a Uniswap nunca tenha indexado — sem precisar de
/// API key.
///
/// O tier gratuito recusa mais que 1 endereço por pedido ("Number of
/// contract addresses in the request exceeds the allowed limit of 1
/// contract address" — confirmado ao vivo, não documentado antecipadamente)
/// e tem rate limit por minuto, por isso: um pedido por endereço, com um
/// pequeno atraso entre eles; um endereço que falhe (rate limit, token
/// desconhecido, rede) não bloqueia os outros, só fica de fora do mapa
/// devolvido. O chamador deve também cachear os preços durante alguns
/// minutos (ver `LivePoolFeesRepository`) — sem isso, vários refreshes
/// seguidos (ex.: pull-to-refresh a seguir ao carregamento inicial) batem
/// no rate limit com uma rapidez surpreendente.
class CoinGeckoPriceClient {
  final http.Client _httpClient;

  CoinGeckoPriceClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Preços em USD de vários ERC-20 na plataforma `platformId` (ex.
  /// "ethereum") — um endereço sem preço conhecido (ou cuja chamada falhe)
  /// fica de fora do mapa devolvido, não é um erro que aborte os outros.
  Future<Map<String, double>> fetchTokenPricesUsd({
    required String platformId,
    required List<String> contractAddresses,
  }) async {
    final prices = <String, double>{};
    for (var i = 0; i < contractAddresses.length; i++) {
      try {
        final uri = Uri.https(
          'api.coingecko.com',
          '/api/v3/simple/token_price/$platformId',
          {
            'contract_addresses': contractAddresses[i],
            'vs_currencies': 'usd',
          },
        );
        final response = await _httpClient
            .get(uri)
            .timeout(const Duration(seconds: 20));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          for (final entry in decoded.entries) {
            final usd = (entry.value as Map<String, dynamic>)['usd'];
            if (usd is num) prices[entry.key.toLowerCase()] = usd.toDouble();
          }
        }
      } catch (_) {
        // Ver nota da classe — um endereço de cada vez, nenhum bloqueia
        // os outros.
      }
      if (i != contractAddresses.length - 1) {
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }
    return prices;
  }

  /// Preço USD do ETH nativo — não tem endereço de contrato, por isso usa
  /// o endpoint "by id" da CoinGecko em vez do "by contract address".
  Future<double?> fetchNativeEthPriceUsd() async {
    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': 'ethereum',
      'vs_currencies': 'usd',
    });
    final response = await _httpClient
        .get(uri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw CoinGeckoPriceException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final usd = (decoded['ethereum'] as Map<String, dynamic>?)?['usd'];
    return usd is num ? usd.toDouble() : null;
  }

  void dispose() => _httpClient.close();
}
