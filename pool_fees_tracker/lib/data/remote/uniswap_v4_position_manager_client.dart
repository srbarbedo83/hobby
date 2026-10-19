import 'eth_abi.dart';
import 'eth_rpc_client.dart';

/// `PoolKey` da Uniswap v4: identifica uma pool sem precisar de um
/// contrato dedicado (ao contrário do v3) — é o par de tokens + fee tier +
/// tick spacing + endereço do hook (`0x000...000` = sem hook).
class V4PoolKey {
  final String currency0;
  final String currency1;
  final int fee;
  final int tickSpacing;
  final String hooks;

  V4PoolKey({
    required this.currency0,
    required this.currency1,
    required this.fee,
    required this.tickSpacing,
    required this.hooks,
  });
}

class V4PositionInfo {
  final V4PoolKey poolKey;
  final int tickLower;
  final int tickUpper;

  V4PositionInfo({
    required this.poolKey,
    required this.tickLower,
    required this.tickUpper,
  });
}

/// Lê posições Uniswap v4 diretamente do contrato `PositionManager` via
/// `eth_call` — o subgraph v4 não guarda range/liquidez por posição (ver
/// nota em `uniswap_v4_subgraph_client.dart`), só o `PositionManager`
/// on-chain sabe isto. Os selectors e o layout de bits do `PositionInfo`
/// empacotado vêm diretamente do código-fonte oficial
/// (`Uniswap/v4-periphery/src/libraries/PositionInfoLibrary.sol` e
/// `PositionManager.sol`), não de documentação de terceiros.
class UniswapV4PositionManagerClient {
  static const _selectorGetPoolAndPositionInfo = '0x7ba03aad';
  static const _selectorGetPositionLiquidity = '0x1efeed33';

  final EthRpcClient rpcClient;
  final String positionManagerAddress;

  UniswapV4PositionManagerClient({
    required this.rpcClient,
    required this.positionManagerAddress,
  });

  Future<V4PositionInfo> getPoolAndPositionInfo(BigInt tokenId) async {
    final data = await rpcClient.ethCall(
      to: positionManagerAddress,
      data: encodeUint256Call(_selectorGetPoolAndPositionInfo, tokenId),
    );
    final words = splitAbiWords(data);
    // PoolKey (currency0, currency1, fee, tickSpacing, hooks) é todo
    // estático, por isso vem inline como 5 palavras, seguido da 6ª palavra
    // com o PositionInfo empacotado — sem offsets/ponteiros ABI.
    if (words.length < 6) {
      throw FormatException(
        'getPoolAndPositionInfo: resposta curta demais (${words.length} palavras)',
      );
    }
    final poolKey = V4PoolKey(
      currency0: decodeAddress(words[0]),
      currency1: decodeAddress(words[1]),
      fee: decodeUint(words[2]).toInt(),
      tickSpacing: decodeInt24(words[3]),
      hooks: decodeAddress(words[4]),
    );
    final packed = decodeUint(words[5]);
    return V4PositionInfo(
      poolKey: poolKey,
      // Layout (Uniswap/v4-periphery PositionInfoLibrary.sol):
      // 200 bits poolId | 24 bits tickUpper | 24 bits tickLower | 8 bits hasSubscriber
      tickLower: _signExtend24((packed >> 8) & BigInt.from(0xFFFFFF)),
      tickUpper: _signExtend24((packed >> 32) & BigInt.from(0xFFFFFF)),
    );
  }

  Future<BigInt> getPositionLiquidity(BigInt tokenId) async {
    final data = await rpcClient.ethCall(
      to: positionManagerAddress,
      data: encodeUint256Call(_selectorGetPositionLiquidity, tokenId),
    );
    final words = splitAbiWords(data);
    if (words.isEmpty) return BigInt.zero;
    return decodeUint(words[0]);
  }

  static int _signExtend24(BigInt raw) {
    final signBit = BigInt.from(0x800000);
    final full = BigInt.from(0x1000000);
    return (raw & signBit) != BigInt.zero ? (raw - full).toInt() : raw.toInt();
  }
}
