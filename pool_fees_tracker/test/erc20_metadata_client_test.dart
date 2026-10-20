import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pool_fees_tracker/data/remote/erc20_metadata_client.dart';
import 'package:pool_fees_tracker/data/remote/eth_rpc_client.dart';

void main() {
  group('Erc20MetadataClient.fetch', () {
    test('lê symbol() e decimals() via eth_call', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final params = body['params'] as List;
        final data = (params[0] as Map)['data'] as String;
        if (data == '0x95d89b41') {
          // offset=0x20, length=4, "USDC" padded.
          final offset = '20'.padLeft(64, '0');
          final length = '4'.padLeft(64, '0');
          final payload = '55534443'.padRight(64, '0');
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': '0x$offset$length$payload',
            }),
            200,
          );
        }
        if (data == '0x313ce567') {
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': '0x${'0' * 63}6',
            }),
            200,
          );
        }
        throw StateError('selector inesperado: $data');
      });

      final client = Erc20MetadataClient(
        rpcClient: EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        ),
      );

      final metadata = await client.fetch(
        '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
      );
      expect(metadata.symbol, 'USDC');
      expect(metadata.decimals, 6);
    });
  });
}
