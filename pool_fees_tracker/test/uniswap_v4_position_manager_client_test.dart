import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pool_fees_tracker/data/remote/eth_rpc_client.dart';
import 'package:pool_fees_tracker/data/remote/uniswap_v4_position_manager_client.dart';

const _currency0 = '0x0000000000000000000000000000000000000000';
const _currency1 = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
const _hooks = '0x0000000000000000000000000000000000000000';

/// Palavra de 32 bytes (64 hex) para um endereço: 24 zeros + 40 hex chars.
String _addrWord(String addr) =>
    '${'0' * 24}${addr.substring(2).toLowerCase()}';

String _uintWord(int value) => value.toRadixString(16).padLeft(64, '0');

/// `tickUpper(24b) << 32 | tickLower(24b) << 8` — mesmo layout de
/// `PositionInfoLibrary.sol`, construído por fora da classe testada para
/// não repetir a lógica que está a ser validada.
String _packedPositionInfoWord({
  required int tickLower,
  required int tickUpper,
}) {
  final packed = ((tickUpper & 0xFFFFFF) << 32) | ((tickLower & 0xFFFFFF) << 8);
  return packed.toRadixString(16).padLeft(64, '0');
}

void main() {
  group('UniswapV4PositionManagerClient.getPoolAndPositionInfo', () {
    test(
      'descodifica PoolKey e range (incl. ticks negativos, sign-extended)',
      () async {
        final resultHex =
            '0x${[
              _addrWord(_currency0),
              _addrWord(_currency1),
              _uintWord(3000), // fee
              _uintWord(60), // tickSpacing
              _addrWord(_hooks),
              _packedPositionInfoWord(tickLower: -120, tickUpper: 120),
            ].join()}';

        final mockClient = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['method'], 'eth_call');
          return http.Response(
            jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': resultHex}),
            200,
          );
        });

        final rpcClient = EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        );
        final client = UniswapV4PositionManagerClient(
          rpcClient: rpcClient,
          positionManagerAddress: '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e',
        );

        final info = await client.getPoolAndPositionInfo(BigInt.from(123));

        expect(info.poolKey.currency0, _currency0);
        expect(info.poolKey.currency1, _currency1);
        expect(info.poolKey.fee, 3000);
        expect(info.poolKey.tickSpacing, 60);
        expect(info.poolKey.hooks, _hooks);
        expect(info.tickLower, -120);
        expect(info.tickUpper, 120);
      },
    );

    test('range totalmente positivo (sem sign extension)', () async {
      final resultHex =
          '0x${[_addrWord(_currency0), _addrWord(_currency1), _uintWord(500), _uintWord(10), _addrWord(_hooks), _packedPositionInfoWord(tickLower: 1000, tickUpper: 5000)].join()}';

      final mockClient = MockClient(
        (request) async => http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': resultHex}),
          200,
        ),
      );
      final client = UniswapV4PositionManagerClient(
        rpcClient: EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        ),
        positionManagerAddress: '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e',
      );

      final info = await client.getPoolAndPositionInfo(BigInt.from(1));
      expect(info.tickLower, 1000);
      expect(info.tickUpper, 5000);
    });
  });

  group('UniswapV4PositionManagerClient.getPositionLiquidity', () {
    test('descodifica um uint128 de uma única palavra', () async {
      final mockClient = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': '0x${_uintWord(123456789)}',
          }),
          200,
        ),
      );
      final client = UniswapV4PositionManagerClient(
        rpcClient: EthRpcClient(
          rpcUrl: 'https://example.invalid/rpc',
          httpClient: mockClient,
        ),
        positionManagerAddress: '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e',
      );

      final liquidity = await client.getPositionLiquidity(BigInt.from(1));
      expect(liquidity, BigInt.from(123456789));
    });
  });
}
