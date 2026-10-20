import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pool_fees_tracker/data/remote/eth_rpc_client.dart';
import 'package:pool_fees_tracker/data/remote/uniswap_v4_pool_state_client.dart';
import 'package:pool_fees_tracker/data/remote/uniswap_v4_position_manager_client.dart';

void main() {
  group('UniswapV4PoolStateClient.computePoolId', () {
    test(
      'keccak256(abi.encode(poolKey)) bate com o valor calculado à parte (Python)',
      () {
        final key = V4PoolKey(
          currency0: '0x0000000000000000000000000000000000000000',
          currency1: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
          fee: 3000,
          tickSpacing: 60,
          hooks: '0x0000000000000000000000000000000000000000',
        );

        final poolId = UniswapV4PoolStateClient.computePoolId(key);

        expect(
          poolId.toRadixString(16).padLeft(64, '0'),
          'dce6394339af00981949f5f3baf27e3610c76326a700af57e4b3e3ae4977f78d'
              .padLeft(64, '0'),
        );
      },
    );
  });

  group('UniswapV4PoolStateClient.getCurrentTick', () {
    test('descodifica o tick (2ª palavra) da resposta de getSlot0', () async {
      final key = V4PoolKey(
        currency0: '0x0000000000000000000000000000000000000000',
        currency1: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
        fee: 3000,
        tickSpacing: 60,
        hooks: '0x0000000000000000000000000000000000000000',
      );

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['method'], 'eth_call');
        final params = body['params'] as List;
        final to = (params[0] as Map)['to'] as String;
        expect(to, '0x7ffe42c4a5deea5b0fec41c94c136cf115597227');
        // sqrtPriceX96, tick=-201080, protocolFee=0, lpFee=0
        final tickHex = (-201080 & 0xFFFFFF).toRadixString(16).padLeft(
          64,
          '0',
        );
        final resultHex =
            '0x${'0' * 64}$tickHex${'0' * 64}${'0' * 64}';
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': resultHex}),
          200,
        );
      });

      final client = UniswapV4PoolStateClient(
        rpcClient: EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        ),
        stateViewAddress: '0x7ffe42c4a5deea5b0fec41c94c136cf115597227',
      );

      final tick = await client.getCurrentTick(key);
      expect(tick, -201080);
    });
  });
}
