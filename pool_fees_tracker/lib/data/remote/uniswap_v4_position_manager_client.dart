import '../../core/concurrency.dart';
import 'eth_abi.dart';
import 'eth_rpc_client.dart';

const _zeroAddress = '0x0000000000000000000000000000000000000000';

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

class V4OwnedToken {
  final BigInt tokenId;
  final DateTime createdAt;

  V4OwnedToken({required this.tokenId, required this.createdAt});
}

/// Lê posições Uniswap v4 diretamente do contrato `PositionManager` via
/// `eth_call` — não há subgraph fiável para isto (o subgraph v4 mostrou-se
/// globalmente não fiável nesta sessão, mesmo só para tokenIds: "bad
/// indexers" ou timeout, para TODAS as posições testadas da wallet real do
/// utilizador), por isso range/liquidez e a descoberta de tokenIds vêm
/// todos on-chain. Os selectors e o layout de bits do `PositionInfo`
/// empacotado vêm diretamente do código-fonte oficial
/// (`Uniswap/v4-periphery/src/libraries/PositionInfoLibrary.sol` e
/// `PositionManager.sol`), não de documentação de terceiros.
class UniswapV4PositionManagerClient {
  static const _selectorGetPoolAndPositionInfo = '0x7ba03aad';
  static const _selectorGetPositionLiquidity = '0x1efeed33';
  static const _selectorOwnerOf = '0x6352211e';

  final EthRpcClient rpcClient;
  final String positionManagerAddress;

  UniswapV4PositionManagerClient({
    required this.rpcClient,
    required this.positionManagerAddress,
  });

  /// Descobre os NFTs de posição v4 que `owner` detém atualmente, via
  /// `alchemy_getAssetTransfers` — sem depender do subgraph v4 (que se
  /// mostrou pouco fiável: indexadores sem atestação, ou schema errado
  /// noutro deployment) nem de `eth_getLogs` (o plano gratuito da Alchemy
  /// limita-o a 10 blocos por pedido, inviável para meses de histórico).
  ///
  /// O `PositionManager` não implementa `ERC721Enumerable` (ver nota em
  /// `Uniswap/v4-sdk`), por isso não há como listar tokenIds sem olhar
  /// para o histórico de transferências dalguma forma.
  Future<List<V4OwnedToken>> fetchOwnedTokenIds(String owner) async {
    final transfers = await rpcClient.getAssetTransfers(
      toAddress: owner,
      contractAddresses: [positionManagerAddress],
    );

    // Pode haver mais do que uma transferência recebida para o mesmo
    // tokenId (ex.: comprado em 2ª mão) — fica só o bloco mais antigo,
    // como aproximação da data de "abertura" da posição (a mesma
    // aproximação que o resto da app já assume quando a info exata não
    // está disponível).
    final earliestBlockByTokenId = <BigInt, BigInt>{};
    for (final transfer in transfers) {
      final tokenIdHex =
          (transfer['tokenId'] ?? transfer['erc721TokenId']) as String?;
      final blockNumHex = transfer['blockNum'] as String?;
      if (tokenIdHex == null || blockNumHex == null) continue;
      final tokenId = BigInt.parse(tokenIdHex.substring(2), radix: 16);
      final blockNumber = BigInt.parse(blockNumHex.substring(2), radix: 16);
      final current = earliestBlockByTokenId[tokenId];
      if (current == null || blockNumber < current) {
        earliestBlockByTokenId[tokenId] = blockNumber;
      }
    }

    // Um token recebido pode ter sido transferido para fora entretanto —
    // confirma a posse atual (e obtém a data) em paralelo, por tokenId. Com
    // concorrência limitada: uma wallet com muitas posições (confirmado ao
    // vivo com 81 no Arbitrum) dispararia centenas de pedidos de uma vez
    // num `Future.wait` normal, o que a Alchemy (plano gratuito) recusa
    // com HTTP 429 ("compute units per second" excedido) — ver
    // `mapWithConcurrency`.
    final verified = await mapWithConcurrency(
      earliestBlockByTokenId.entries.toList(),
      (entry) async {
        final currentOwner = await _ownerOf(entry.key);
        if (currentOwner.toLowerCase() != owner.toLowerCase()) return null;
        final createdAt = await rpcClient.getBlockTimestamp(entry.value);
        return V4OwnedToken(tokenId: entry.key, createdAt: createdAt);
      },
    );
    return verified.whereType<V4OwnedToken>().toList();
  }

  Future<String> _ownerOf(BigInt tokenId) async {
    final data = await rpcClient.ethCall(
      to: positionManagerAddress,
      data: encodeUint256Call(_selectorOwnerOf, tokenId),
    );
    final words = splitAbiWords(data);
    if (words.isEmpty) return _zeroAddress;
    return decodeAddress(words[0]);
  }

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
