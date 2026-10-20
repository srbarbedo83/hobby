import 'eth_abi.dart';
import 'eth_rpc_client.dart';

const _selectorSymbol = '0x95d89b41'; // symbol(), confirmado via keccak256 local
const _selectorDecimals = '0x313ce567'; // decimals(), idem

class Erc20Metadata {
  final String symbol;
  final int decimals;

  Erc20Metadata({required this.symbol, required this.decimals});
}

/// Lê `symbol()`/`decimals()` diretamente do contrato ERC-20 via
/// `eth_call` — evita depender de uma entidade `Token` indexada por um
/// subgraph (ver nota em `uniswap_v4_pool_state_client.dart`: o subgraph
/// v4 mostrou-se globalmente não fiável nesta sessão). Funciona para
/// qualquer ERC-20 standard, mesmo um que o subgraph nunca tenha indexado.
class Erc20MetadataClient {
  final EthRpcClient rpcClient;

  Erc20MetadataClient({required this.rpcClient});

  Future<Erc20Metadata> fetch(String tokenAddress) async {
    final symbolData = await rpcClient.ethCall(
      to: tokenAddress,
      data: _selectorSymbol,
    );
    final decimalsData = await rpcClient.ethCall(
      to: tokenAddress,
      data: _selectorDecimals,
    );
    final decimalsWords = splitAbiWords(decimalsData);
    return Erc20Metadata(
      symbol: decodeDynamicString(symbolData),
      decimals: decimalsWords.isEmpty
          ? 18
          : decodeUint(decimalsWords[0]).toInt(),
    );
  }
}
