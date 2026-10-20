import 'dart:typed_data';

import 'eth_abi.dart';
import 'eth_rpc_client.dart';
import 'keccak.dart';
import 'uniswap_v4_position_manager_client.dart' show V4PoolKey;

const _selectorGetSlot0 = '0xc815641c'; // getSlot0(bytes32), confirmado via keccak256 local

/// Lê o tick atual de uma pool v4 diretamente do contrato `StateView` da
/// Uniswap — substitui por completo o subgraph v4 para isto (ver nota em
/// `uniswap_v4_position_manager_client.dart`: mostrou-se globalmente não
/// fiável nesta sessão, para TODAS as posições testadas da wallet real do
/// utilizador, não um caso raro — "bad indexers" nalgumas, timeout
/// noutras, sempre sem sucesso).
///
/// O `poolId` (identificador interno da Uniswap para cada pool) não vem de
/// lado nenhum: é `keccak256(abi.encode(poolKey))` — calculado aqui a
/// partir do `PoolKey` já lido do `PositionManager`. `abi.encode` de um
/// struct só com campos estáticos equivale a concatenar cada campo, cada
/// um ocupando uma palavra de 32 bytes (right-aligned, left-padded com
/// zeros) — ver `PoolIdLibrary.toId` em `Uniswap/v4-core`.
class UniswapV4PoolStateClient {
  final EthRpcClient rpcClient;
  final String stateViewAddress;

  UniswapV4PoolStateClient({
    required this.rpcClient,
    required this.stateViewAddress,
  });

  Future<int> getCurrentTick(V4PoolKey poolKey) async {
    final poolId = computePoolId(poolKey);
    final data = await rpcClient.ethCall(
      to: stateViewAddress,
      data: encodeUint256Call(_selectorGetSlot0, poolId),
    );
    final words = splitAbiWords(data);
    // getSlot0 devolve 4 valores estáticos (sqrtPriceX96, tick,
    // protocolFee, lpFee), cada um na sua própria palavra — só o tick
    // (2ª palavra) interessa por agora.
    if (words.length < 2) {
      throw FormatException(
        'getSlot0: resposta curta demais (${words.length} palavras)',
      );
    }
    return decodeInt24(words[1]);
  }

  static BigInt computePoolId(V4PoolKey key) {
    final bytes = <int>[
      ...encodeAddressWord(key.currency0),
      ...encodeAddressWord(key.currency1),
      ...encodeUintWord(BigInt.from(key.fee)),
      ...encodeUintWord(BigInt.from(key.tickSpacing)),
      ...encodeAddressWord(key.hooks),
    ];
    final digest = keccak256(Uint8List.fromList(bytes));
    return BigInt.parse(bytesToHex(digest), radix: 16);
  }
}
