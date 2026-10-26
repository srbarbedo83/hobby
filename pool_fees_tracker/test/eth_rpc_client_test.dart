import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pool_fees_tracker/data/remote/eth_rpc_client.dart';

void main() {
  group('EthRpcClient retry em HTTP 429', () {
    test('repete automaticamente e devolve o resultado da tentativa seguinte', () async {
      var attempts = 0;
      final mockClient = MockClient((request) async {
        attempts++;
        if (attempts == 1) {
          return http.Response('rate limited', 429);
        }
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': '0x1'}),
          200,
        );
      });

      final client = EthRpcClient(
        rpcUrl: 'https://example.invalid/rpc',
        httpClient: mockClient,
      );

      final result = await client.ethCall(to: '0xabc', data: '0x123');
      expect(result, '0x1');
      expect(attempts, 2);
    });

    test('um erro não-429 não é repetido', () async {
      var attempts = 0;
      final mockClient = MockClient((request) async {
        attempts++;
        return http.Response('server error', 500);
      });

      final client = EthRpcClient(
        rpcUrl: 'https://example.invalid/rpc',
        httpClient: mockClient,
      );

      await expectLater(
        client.ethCall(to: '0xabc', data: '0x123'),
        throwsA(isA<EthRpcException>()),
      );
      expect(attempts, 1);
    });
  });

  group('EthRpcClient retry em falha de ligação (ClientException)', () {
    test(
      'uma quebra de ligação a meio do pedido repete em vez de desistir '
      'logo (confirmado ao vivo: "Software caused connection abort" no '
      'alchemy_getAssetTransfers do Arbitrum, que não é um 429 e por '
      'isso não entrava no retry antigo)',
      () async {
        var attempts = 0;
        final mockClient = MockClient((request) async {
          attempts++;
          if (attempts == 1) {
            throw http.ClientException('Software caused connection abort');
          }
          return http.Response(
            jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': '0x1'}),
            200,
          );
        });

        final client = EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        );

        final result = await client.ethCall(to: '0xabc', data: '0x123');
        expect(result, '0x1');
        expect(attempts, 2);
      },
    );

    test(
      'desiste depois de esgotar as tentativas, não fica pendurado para '
      'sempre',
      () async {
        var attempts = 0;
        final mockClient = MockClient((request) async {
          attempts++;
          throw http.ClientException('Software caused connection abort');
        });

        final client = EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        );

        await expectLater(
          client.ethCall(to: '0xabc', data: '0x123'),
          throwsA(isA<EthRpcException>()),
        );
        expect(attempts, 4);
      },
    );
  });

  group('EthRpcClient espaçamento mínimo entre pedidos', () {
    test(
      'pedidos concorrentes saem espaçados no tempo, não todos de uma vez '
      '(ver nota: limitar só a concorrência não chegou para o rate limit '
      'da Alchemy, confirmado ao vivo)',
      () async {
        final requestTimes = <DateTime>[];
        final mockClient = MockClient((request) async {
          requestTimes.add(DateTime.now());
          return http.Response(
            jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': '0x1'}),
            200,
          );
        });

        final client = EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        );

        await Future.wait([
          client.ethCall(to: '0xa', data: '0x1'),
          client.ethCall(to: '0xb', data: '0x2'),
          client.ethCall(to: '0xc', data: '0x3'),
        ]);

        expect(requestTimes.length, 3);
        requestTimes.sort();
        expect(
          requestTimes[1].difference(requestTimes[0]).inMilliseconds,
          greaterThanOrEqualTo(250),
        );
        expect(
          requestTimes[2].difference(requestTimes[1]).inMilliseconds,
          greaterThanOrEqualTo(250),
        );
      },
    );
  });
}
