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
}
