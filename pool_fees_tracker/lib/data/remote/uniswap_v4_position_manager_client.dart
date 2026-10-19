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
/// `eth_call` — o subgraph v4 não guarda range/liquidez por posição (ver
/// nota em `uniswap_v4_subgraph_client.dart`), só o `PositionManager`
/// on-chain sabe isto. Os selectors e o layout de bits do `PositionInfo`
/// empacotado vêm diretamente do código-fonte oficial
/// (`Uniswap/v4-periphery/src/libraries/PositionInfoLibrary.sol` e
/// `PositionManager.sol`), não de documentação de terceiros.
class UniswapV4PositionManagerClient {
  static const _selectorGetPoolAndPositionInfo = '0x7ba03aad';
  static const _selectorGetPositionLiquidity = '0x1efeed33';
  static const _selectorOwnerOf = '0x6352211e';

  /// `keccak256("Transfer(address,address,uint256)")` — o mesmo evento
  /// ERC-721 standard em qualquer NFT, não específico da Uniswap.
  /// Verificado localmente (não copiado de uma fonte terceira) durante o
  /// desenvolvimento desta funcionalidade.
  static const _transferEventTopic =
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

  /// Bloco a partir do qual vale a pena procurar — bastante antes do
  /// lançamento do v4 em mainnet (~janeiro 2025), só para não percorrer a
  /// chain toda desde o genesis. Sobrestimar não tem custo, só devolve
  /// blocos vazios mais depressa.
  static final _searchFromBlock = BigInt.from(21000000);

  final EthRpcClient rpcClient;
  final String positionManagerAddress;

  UniswapV4PositionManagerClient({
    required this.rpcClient,
    required this.positionManagerAddress,
  });

  /// Descobre os NFTs de posição v4 que `owner` detém atualmente,
  /// diretamente on-chain via `eth_getLogs` — sem depender do subgraph v4
  /// (ver nota no topo da classe: o subgraph v4 tem-se mostrado pouco
  /// fiável em produção — deployments sem indexadores saudáveis, ou com o
  /// schema errado). Mais lento à primeira vez (percorre o histórico de
  /// blocos em pedaços), mas não depende de nenhum serviço terceiro.
  ///
  /// Não implementa `ERC721Enumerable` (nem o `PositionManager` o faz —
  /// ver nota em `Uniswap/v4-sdk`), por isso a única forma de descobrir
  /// tokenIds sem um indexador é via o histórico de eventos `Transfer`.
  Future<List<V4OwnedToken>> fetchOwnedTokenIds(String owner) async {
    final latest = await rpcClient.blockNumber();
    final paddedOwner =
        '0x${owner.toLowerCase().substring(2).padLeft(64, '0')}';

    // Pedaços em paralelo (não sequenciais) para não demorar minutos numa
    // chain com ~1-2 anos de histórico desde o lançamento do v4.
    const chunkBlocks = 100000;
    final chunks = <({BigInt from, BigInt to})>[];
    var from = _searchFromBlock;
    while (from <= latest) {
      final to = (from + BigInt.from(chunkBlocks)) > latest
          ? latest
          : from + BigInt.from(chunkBlocks);
      chunks.add((from: from, to: to));
      from = to + BigInt.one;
    }

    final chunkResults = await Future.wait(
      chunks.map(
        (c) => rpcClient.getLogs(
          address: positionManagerAddress,
          // [evento, from (qualquer), to (o owner), tokenId (qualquer)]
          topics: [_transferEventTopic, null, paddedOwner, null],
          fromBlock: c.from,
          toBlock: c.to,
        ),
      ),
    );
    final logs = chunkResults.expand((l) => l).toList();

    // Pode haver mais do que um `Transfer` para o mesmo tokenId (ex.:
    // comprado em 2ª mão) — fica só o bloco mais antigo em que este
    // endereço o recebeu, como aproximação da data de "abertura" da
    // posição (a mesma aproximação que o resto da app já assume quando a
    // info exata não está disponível).
    final earliestBlockByTokenId = <BigInt, BigInt>{};
    for (final log in logs) {
      final topics = (log['topics'] as List).cast<String>();
      final tokenId = BigInt.parse(topics[3].substring(2), radix: 16);
      final blockNumber = BigInt.parse(
        (log['blockNumber'] as String).substring(2),
        radix: 16,
      );
      final current = earliestBlockByTokenId[tokenId];
      if (current == null || blockNumber < current) {
        earliestBlockByTokenId[tokenId] = blockNumber;
      }
    }

    // Um token recebido pode ter sido transferido para fora entretanto —
    // confirma a posse atual (e obtém a data) em paralelo, por tokenId.
    final verified = await Future.wait(
      earliestBlockByTokenId.entries.map((entry) async {
        final currentOwner = await _ownerOf(entry.key);
        if (currentOwner.toLowerCase() != owner.toLowerCase()) return null;
        final createdAt = await rpcClient.getBlockTimestamp(entry.value);
        return V4OwnedToken(tokenId: entry.key, createdAt: createdAt);
      }),
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
