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

  group('UniswapV4PoolStateClient.getFeeGrowthInside', () {
    test(
      'envia o selector certo com poolId/tickLower/tickUpper e descodifica as 2 palavras',
      () async {
        final key = V4PoolKey(
          currency0: '0x0000000000000000000000000000000000000000',
          currency1: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
          fee: 3000,
          tickSpacing: 60,
          hooks: '0x0000000000000000000000000000000000000000',
        );

        final mockClient = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final params = body['params'] as List;
          final data = (params[0] as Map)['data'] as String;
          expect(data.startsWith('0x53e9c1fb'), true);
          // selector (10) + 3 palavras de 64 = 202 carateres.
          expect(data.length, 10 + 64 * 3);
          final tickLowerWord = data.substring(10 + 64, 10 + 64 * 2);
          final tickUpperWord = data.substring(10 + 64 * 2, 10 + 64 * 3);
          expect(
            tickLowerWord,
            BigInt.from(-120).toUnsigned(256).toRadixString(16).padLeft(64, '0'),
          );
          expect(
            tickUpperWord,
            BigInt.from(120).toUnsigned(256).toRadixString(16).padLeft(64, '0'),
          );
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result':
                  '0x${'1'.padLeft(64, '0')}${'2'.padLeft(64, '0')}',
            }),
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

        final result = await client.getFeeGrowthInside(
          key,
          tickLower: -120,
          tickUpper: 120,
        );
        expect(result.inside0, BigInt.one);
        expect(result.inside1, BigInt.two);
      },
    );
  });

  group('UniswapV4PoolStateClient.getPositionInfo', () {
    test(
      'envia owner e salt corretos e descodifica liquidez + feeGrowthInside...Last',
      () async {
        final key = V4PoolKey(
          currency0: '0x0000000000000000000000000000000000000000',
          currency1: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
          fee: 3000,
          tickSpacing: 60,
          hooks: '0x0000000000000000000000000000000000000000',
        );
        const owner = '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e';

        final mockClient = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final params = body['params'] as List;
          final data = (params[0] as Map)['data'] as String;
          expect(data.startsWith('0xdacf1d2f'), true);
          final ownerWord = data.substring(10 + 64, 10 + 64 * 2);
          expect(ownerWord, '${'0' * 24}${owner.substring(2)}');
          final saltWord = data.substring(10 + 64 * 4, 10 + 64 * 5);
          expect(saltWord, BigInt.from(42).toRadixString(16).padLeft(64, '0'));
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result':
                  '0x${'3'.padLeft(64, '0')}${'4'.padLeft(64, '0')}${'5'.padLeft(64, '0')}',
            }),
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

        final result = await client.getPositionInfo(
          poolKey: key,
          owner: owner,
          tickLower: -120,
          tickUpper: 120,
          salt: BigInt.from(42),
        );
        expect(result.liquidity, BigInt.from(3));
        expect(result.feeGrowthInside0Last, BigInt.from(4));
        expect(result.feeGrowthInside1Last, BigInt.from(5));
      },
    );
  });
}
