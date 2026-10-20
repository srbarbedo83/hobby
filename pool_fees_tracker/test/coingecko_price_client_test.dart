import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pool_fees_tracker/data/remote/coingecko_price_client.dart';

void main() {
  group('CoinGeckoPriceClient.fetchTokenPricesUsd', () {
    test('devolve o mapa endereço (minúsculas) -> preço USD', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v3/simple/token_price/ethereum');
        expect(
          request.url.queryParameters['contract_addresses'],
          '0xA0b86991c6218b36c1D19D4a2e9Eb0cE3606EB48',
        );
        return http.Response(
          jsonEncode({
            '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48': {'usd': 1.0001},
          }),
          200,
        );
      });

      final client = CoinGeckoPriceClient(httpClient: mockClient);
      final prices = await client.fetchTokenPricesUsd(
        platformId: 'ethereum',
        contractAddresses: ['0xA0b86991c6218b36c1D19D4a2e9Eb0cE3606EB48'],
      );

      expect(prices['0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'], 1.0001);
    });

    test('lista de endereços vazia não faz nenhum pedido', () async {
      final client = CoinGeckoPriceClient(
        httpClient: MockClient((request) async {
          throw StateError('não devia ter feito nenhum pedido');
        }),
      );
      final prices = await client.fetchTokenPricesUsd(
        platformId: 'ethereum',
        contractAddresses: [],
      );
      expect(prices, isEmpty);
    });
  });

  group('CoinGeckoPriceClient.fetchNativeEthPriceUsd', () {
    test('devolve o preço do ETH', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v3/simple/price');
        expect(request.url.queryParameters['ids'], 'ethereum');
        return http.Response(
          jsonEncode({
            'ethereum': {'usd': 2500.5},
          }),
          200,
        );
      });

      final client = CoinGeckoPriceClient(httpClient: mockClient);
      final price = await client.fetchNativeEthPriceUsd();
      expect(price, 2500.5);
    });
  });
}
